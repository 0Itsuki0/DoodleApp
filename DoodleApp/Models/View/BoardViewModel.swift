//
//  BoardViewModel.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/10.
//

import SwiftUI
import PencilKit
import LinkPresentation
import PhotosUI

@Observable
class BoardViewModel {

    init(doodleModel: DoodleModel) {
        self.doodleModel = doodleModel
        let undoManager = UndoManager()
        undoManager.groupsByEvent = false
        self.otherUndoManager = undoManager
        self.registerForNotifications()
    }
    
    let doodleModel: DoodleModel
    var error: String? = nil {
        didSet {
            if let error = self.error {
                print(error)
            }
        }
    }
    
    var undoManager: UndoManager? {
        return self.allowCanvasHitTest ? self.canvasUndoManager : self.otherUndoManager
    }
    
    private var otherUndoManager: UndoManager
    private var canvasUndoManager: UndoManager?
    
    var canUndo: Bool {
        return self.allowCanvasHitTest ? self.canUndoDrawing : self.canUndoOther
    }
    
    var canRedo: Bool {
        return self.allowCanvasHitTest ? canRedoDrawing : self.canRedoOther
    }
    
    private var canUndoDrawing: Bool = false
    private var canRedoDrawing: Bool = false
    
    private var canUndoOther: Bool = false
    private var canRedoOther: Bool = false
    
    var scrollToRect: CGRect? = nil
    
    var showRenameAlert: Bool = false
    var showLinkEntryAlert: Bool = false


    var drawingPolicy: PKCanvasViewDrawingPolicy {
        get {
            UserDefaults.standard.bool(forKey: "drawingPolicy") ? .pencilOnly : .anyInput
        }
        set {
            UserDefaults.standard.set(newValue == .pencilOnly, forKey: "drawingPolicy")
        }
    }
    

    var showZoom: Bool = false

    var selectedObject: Selection? = nil {
        didSet(oldValue) {
            guard let previousSelected = oldValue else { return }
            if previousSelected.enableEditing && self.isDrawingObject(previousSelected.id) {
                self.canUndoDrawing = false
                self.canRedoDrawing = false
                self.canvasUndoManager = nil
            }
        }
    }

    
    var allowCanvasHitTest: Bool {
        guard let selectedObject else { return false }
        if !self.isDrawingObject(selectedObject.id) {
            return false
        }
        return selectedObject.enableEditing
    }
    
    
    var showPhotosPicker: Bool = false
    var showImageImporter: Bool = false

}


// MARK: Selection
extension BoardViewModel {
    struct Selection: Identifiable, Equatable {
        var objectId: DoodleObject.ID
        var enableEditing: Bool
        
        var id: UUID { objectId }
    }
    
    var selectedNonDrawingModel: NonDrawingModel? {
        return self.doodleModel.nonDrawings.first(where: {$0.id == selectedObject?.id})
    }
    
    var isSelectionImage: Bool {
        guard let first = self.selectedNonDrawingModel else {
            return false
        }
        
        return self.isDrawingObject(first)
    }
    
    var isSelectionLink: Bool {
        guard let first = self.selectedNonDrawingModel else {
            return false
        }
        
        return self.isLinkObject(first)
    }
    
    var selectedLinkObject: LinkObject? {
        guard let first = self.selectedNonDrawingModel else {
            return nil
        }
        
        if case .link(let object) = first.object {
            return object
        }

        return nil
        
    }
}


// MARK: Undo and Redo Notifications
extension BoardViewModel {
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNonDrawingUndoRedo(_:)), name: NSNotification.Name.NSUndoManagerDidUndoChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNonDrawingUndoRedo(_:)), name: NSNotification.Name.NSUndoManagerDidRedoChange, object: nil)
    }
    
    
    @objc private func handleNonDrawingUndoRedo(_ notification: Notification) {
        guard let undoManager = notification.object as? UndoManager else {
            return
        }
        
        guard !allowCanvasHitTest else {
            return
        }

        self.canUndoOther = undoManager.canUndo
        self.canRedoOther = undoManager.canRedo
    }
}


// MARK: Private Helper Functions
extension BoardViewModel {
    private func isDrawingObject(_ id: DoodleObject.ID) -> Bool {
        return self.doodleModel.drawings.first(where: {$0.id == id}) != nil
    }

    
    private func isDrawingObject(_ model: NonDrawingModel) -> Bool {
        if case .image(_) = model.object {
            return true
        }
        return false
    }
    
    private func isLinkObject(_ model: NonDrawingModel) -> Bool {
        if case .link(_) = model.object {
            return true
        }
        return false
    }
}



// MARK: update model properties: position/size/angle with undo and redo
extension BoardViewModel {
    
    func updatePositionWithUndo(object: DoodleObject, oldValue: CGPoint, newValue: CGPoint) {
        undoManager?.beginUndoGrouping()
        self.registerUndo(withTarget: self) { target in
            target.updatePositionWithUndo(object: object, oldValue: newValue, newValue: oldValue)
        }
        undoManager?.endUndoGrouping()
    
            object.setPosition(newValue)
            self.updateLastModified()
            self.canUndoOther = true
    }
    
    func updateSizeWithUndo(object: DoodleObject, oldValue: (CGSize, CGPoint), newValue: (CGSize, CGPoint)) {
        
        self.registerUndo(withTarget: self) { target in
            target.updateSizeWithUndo(object: object, oldValue: newValue, newValue: oldValue)
        }
        
            object.setPosition(newValue.1)
            object.setSize(newValue.0)
            self.updateLastModified()
            self.canUndoOther = true
    }
    
    func updateAngleWithUndo(object: DoodleObject, oldValue: CGFloat, newValue: CGFloat) {
        self.registerUndo(withTarget: self) { target in
            target.updateAngleWithUndo(object: object, oldValue: newValue, newValue: oldValue)
        }
        
            object.setAngle(newValue)
            self.updateLastModified()
            self.canUndoOther = true
        
    }
    
   
}


// MARK: update model order with undo and redo
extension BoardViewModel {
    
    func moveObjectForward(_ object: DoodleObject) {
        let currentOrder = self.doodleModel.orderForObject(object)
        guard currentOrder < self.doodleModel.allObjects.count - 1 else { return }
        self.updateOrderWithUndo(object: object, from: currentOrder, to: currentOrder + 1)
    }
    
    // todo: finish up
    func moveObjectToFront() {
        
    }
    
    func moveObjectBackward(_ object: DoodleObject) {
        let currentOrder = self.doodleModel.orderForObject(object)
        guard currentOrder > 0 else { return }
        self.updateOrderWithUndo(object: object, from: currentOrder, to: currentOrder - 1)
    }
    
    func moveObjectToBack() {
        
    }
    
    private func updateOrderWithUndo(object: DoodleObject, from: Int, to: Int) {
        self.registerUndo(withTarget: self) { target in
            target.updateOrderWithUndo(object: object, from: from, to: to)
        }
        
        self.doodleModel.changeObjectOrder(from: from, to: to)
        self.updateLastModified()
        self.canUndoOther = true
    }
}


// MARK: Add/Update Drawing
extension BoardViewModel {
    func addNewDrawing() {
        let drawing = DrawingModel(drawing: PKDrawing())
        self.addDrawingWithUndo(drawing)
    }
    
    func updateDrawing(drawingModel: DrawingModel, canvasView: PKCanvasView) {
        self.canvasUndoManager = canvasView.undoManager
        self.canUndoDrawing = canvasView.undoManager?.canUndo ?? false
        self.canRedoDrawing = canvasView.undoManager?.canRedo ?? false

        drawingModel.drawing = canvasView.drawing
        self.updateLastModified()
    
    }
}


// MARK: Add/Update Images
extension BoardViewModel {
    
    // Image chosen with photo picker
    func onImagePicked(_ pickerItems: [PhotosPickerItem]) async {
        
        for (index, item) in pickerItems.enumerated() {
            do {
                if let data = try await item.loadTransferable(type: Data.self), let image = UIImage(data: data)  {
                    self.addImage(image, at: index)
                }
            } catch (let error) {
                self.error = "Failed to load image: \(error.localizedDescription)"
                break
            }
        }
    }
    

    // image imported from Files
    func onImageImportComplete(_ result: Result<[URL], any Error>) {
        switch result {
        case .success(let urls):
            for (index, url) in urls.enumerated() {
                do {
                    let data = try Data(contentsOf: url)
                    if let image = UIImage(data: data) {
                        self.addImage(image, at: index)
                    }
                } catch (let error) {
                    self.error = "Failed to import image: \(error.localizedDescription)"
                    break
                }
            }
        case .failure(let error):
            self.error = "Failed to import image: \(error.localizedDescription)"
            break
        }
    }
    
    
    
    private func addImage(_ uiImage: UIImage, at index: Int) {
        if self.isSelectionImage, let selectedModel = self.selectedNonDrawingModel {
            self.updateNonDrawingObjectWithUndo(selectedModel, oldValue: selectedModel.object, newValue: .image(ImageObject(image: uiImage)))
        } else {
            let imageRatio: CGFloat = uiImage.size.height / uiImage.size.width
            let imageSize = CGSize(width: Constants.initialImageWidth, height: imageRatio * Constants.initialImageWidth)
            let nonDrawingModel = NonDrawingModel(object: .image(ImageObject(image: uiImage)), position: self.locationForNewObject(at: index), size: imageSize, angleDegree: 0.0)
            
            self.addNonDrawingWithUndo(nonDrawingModel, index: nil)

        }

//        let imageRatio: CGFloat = uiImage.size.height / uiImage.size.width
//        let imageSize = CGSize(width: Constants.initialImageWidth, height: imageRatio * Constants.initialImageWidth)
//        let nonDrawingModel = NonDrawingModel(object: .image(ImageObject(image: uiImage)), position: self.locationForNewObject(at: index), size: imageSize, angleDegree: 0.0)
//        
//        self.addNonDrawingWithUndo(nonDrawingModel, index: nil)
    }
}


// MARK: Add/Update Links
extension BoardViewModel {
    func onLinkEntered(_ link: String) {
        if self.isSelectionLink, let selectedModel = self.selectedNonDrawingModel {
            self.updateNonDrawingObjectWithUndo(selectedModel, oldValue: selectedModel.object, newValue: .link(LinkObject(link: link, image: nil, title: nil)))
            updateLinkMetadata(link, model: selectedModel)
        } else {
            self.addNewLink(link)
        }

    }
    
    func reloadLinkMetadata() {
        if let link = self.selectedLinkObject, let selectedModel = self.selectedNonDrawingModel {
            updateLinkMetadata(link.link, model: selectedModel)
        }
    }
    
    private func addNewLink(_ link: String) {
        let initialObject = LinkObject(link: link, image: nil, title: nil)
        let nonDrawingModel = NonDrawingModel(object: .link(initialObject), position: self.locationForNewObject(), size: Constants.initialLinkSize, angleDegree: 0.0)
        self.addNonDrawingWithUndo(nonDrawingModel, index: nil)
        
        updateLinkMetadata(link, model: nonDrawingModel)
    }
    
    private func loadLinkMetadata(_ url: URL) async -> (String? , UIImage?)? {
        let metadataProvider = LPMetadataProvider()
        
        do {
            
            let result = try await metadataProvider.startFetchingMetadata(for: url)
            let image = await self.getImageFromProvider(result.imageProvider)
            return (result.title, image)
            
        } catch(let error) {
            
            if let error = error as? LPError {
                self.error = "Error fetching Link Metadata: \(error.string)"
            } else {
                self.error = "Error fetching Link Metadata: \(error.localizedDescription)"
            }
            return nil
        }
    }
    
    
    private func getImageFromProvider(_ itemProvider: NSItemProvider?) async -> UIImage? {
        guard let itemProvider else { return nil }
        let allowedType = UTType.image.identifier
        guard itemProvider.hasItemConformingToTypeIdentifier(allowedType)  else { return nil }
        do {
            let item =  try await itemProvider.loadItem(forTypeIdentifier: allowedType)
            
            if let url = item as? URL, let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                return image
            }
            
            if let image = item as? UIImage {
                return image
            }
            
            if let data = item as? Data, let image = UIImage(data: data) {
                return image
            }
            
            return nil

        } catch (let error) {
            print("error getting image for link: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    private func updateLinkMetadata(_ link: String, model: NonDrawingModel) {
        if let url = URL(string: link) {
            Task {
                if let (title, image) = await self.loadLinkMetadata(url) {
                    let newObject = LinkObject(link: link, image: image, title: title)
                    model.object = .link(newObject)
                }
            }
        }
    }
}



// MARK: duplicate/delete an existing object
extension BoardViewModel {
        
    func duplicateObject(_ object: DoodleObject) {
        let newPosition = CGPoint(x: object.position.x + 80, y: object.position.y - 80)
        
        switch object {
        case .drawing(let drawingModel):
            let duplicate = DrawingModel(drawing: drawingModel.drawing)
            duplicate.position = newPosition
            self.addDrawingWithUndo(duplicate)
            
        case .nonDrawing(let nonDrawingModel):
            let duplicate = NonDrawingModel(object: nonDrawingModel.object, position: newPosition, size: nonDrawingModel.size, angleDegree: nonDrawingModel.angleDegree)
            self.addNonDrawingWithUndo(duplicate)
        }
    }
     
    // MARK: remove an existing object
    func removeObject(_ object: DoodleObject) {
        self.selectedObject = nil
        switch object {
        case .nonDrawing(let model):
            self.removeNonDrawingWithUndo(model)
        case .drawing(let model):
            self.removeDrawingWithUndo(model)
        }
    }
}



// MARK: (Private) Add/delete/update models objects with redo and undo
extension BoardViewModel {
    
    private func addNonDrawingWithUndo(_ model: NonDrawingModel, index: Int? = nil) {
        self.registerUndo(withTarget: self) { target in
            target.removeNonDrawingWithUndo(model)
        }

        // image loaded some times come from background
        DispatchQueue.main.async {
            self.doodleModel.addNonDrawing(model, index: index)
            self.updateLastModified()
            self.canUndoOther = true
            self.selectedObject = .init(objectId: model.id, enableEditing: false)
        }
    }
    
    private func removeNonDrawingWithUndo(_ model: NonDrawingModel) {
        let index = self.doodleModel.nonDrawings.firstIndex(of: model)

        self.registerUndo(withTarget: self) { target in
            target.addNonDrawingWithUndo(model, index: index)
        }

        self.doodleModel.removeObject(model.id)
        self.updateLastModified()
        self.canUndoOther = true
    
    }
    
    
    private func addDrawingWithUndo(_ model: DrawingModel, index: Int? = nil) {
        self.registerUndo(withTarget: self) { target in
            target.removeDrawingWithUndo(model)
        }
        
        self.doodleModel.addDrawing(model, index: index)
        self.updateLastModified()
        self.canUndoOther = true
        self.selectedObject = .init(objectId: model.id, enableEditing: true)
        
    }

    private func removeDrawingWithUndo(_ model: DrawingModel) {
        let index = self.doodleModel.drawings.firstIndex(of: model)
        self.registerUndo(withTarget: self) { target in
            target.addDrawingWithUndo(model, index: index)
        }
        
        self.doodleModel.removeObject(model.id)
        self.updateLastModified()
        self.canUndoOther = true
        
    }
    
    private func updateNonDrawingObjectWithUndo(_ model: NonDrawingModel, oldValue: NonDrawingObjectEnum, newValue: NonDrawingObjectEnum) {
        self.registerUndo(withTarget: self) { target in
            target.updateNonDrawingObjectWithUndo(model, oldValue: newValue, newValue: oldValue)
        }
        
        // image loaded some times come from background
        DispatchQueue.main.async {
            model.object = newValue
            self.updateLastModified()
            self.canUndoOther = true
        }
    }
    
    private func updateLastModified() {
        self.doodleModel.lastModified = Date()
    }
    
    private func locationForNewObject(at index: Int = 0) -> CGPoint {
        let shift: CGFloat = 20
        return CGPoint(
            x: (doodleModel.previousOffset.x + UIScreen.main.bounds.width / 2 + shift * CGFloat(index)) / doodleModel.previousZoomScale,
            y: (doodleModel.previousOffset.y + UIScreen.main.bounds.height / 2 + shift * CGFloat(index)) / doodleModel.previousZoomScale)
    }

    
    private func registerUndo<TargetType>(withTarget target: TargetType, handler: @escaping (TargetType) -> Void) where TargetType : AnyObject {
        undoManager?.beginUndoGrouping()
        undoManager?.registerUndo(withTarget: target) { target in
            handler(target)
        }
        undoManager?.endUndoGrouping()

        
    }

}




private struct TestView: View {
    @State private var boardViewModel: BoardViewModel = .init(doodleModel: DoodleModel.testModel)
    
    var body: some View {

        ZStack {
            ObjectContentView()
        }
        .overlay(alignment: .topTrailing, content: {
            VStack {
                Button(action: {
                    self.boardViewModel.moveObjectForward(boardViewModel.doodleModel.allObjects[1])
                }, label: {
                    Text("forward")
                })
                .padding(.all, 16)

                Button(action: {
                    self.boardViewModel.moveObjectBackward(boardViewModel.doodleModel.allObjects[1])
                }, label: {
                    Text("backward")
                })
                .padding(.all, 16)
            }
        })
        .toolbar(content: {
            BoardViewTopBar(
                isCompact: false
            )
        })
        .overlay(alignment: .bottom, content: {
            BoardViewBottomBar()
        })
        .environment(self.boardViewModel)
        
    }
}



#Preview {
    NavigationStack {
        TestView()
            .modelContainer(for: [DoodleModel.self], inMemory: true)
            
    }
}
