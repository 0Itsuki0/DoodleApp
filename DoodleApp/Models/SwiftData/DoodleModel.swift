//
//  DrawingModel.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/04.
//

import SwiftUI
import PencilKit
import SwiftData


@Model
class DoodleModel {

    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var lastModified: Date
    var isFavorite: Bool

    var showBackgroundGrid: Bool
    var previousZoomScale: CGFloat
    
    var imageData: Data?

    private var previousContentOffsetX: CGFloat
    private var previousContentOffsetY: CGFloat
    
    var previousOffset: CGPoint {
        get {
            CGPoint(x: previousContentOffsetX, y: previousContentOffsetY)
        }
        set {
            self.previousContentOffsetX = newValue.x
            self.previousContentOffsetY = newValue.y
        }
    }
    
    var nonDrawings: [NonDrawingModel]
    var drawings: [DrawingModel]
    
    private var objectOrder: [_UUID]

    
    init(name: String, lastModified: Date, isFavorite: Bool, showBackgroundGrid: Bool, previousZoomScale: CGFloat, imageData: Data?, previousOffset: CGPoint, drawings: [DrawingModel], nonDrawings: [NonDrawingModel], objectOrder: [UUID]) {
        self.name = name
        self.lastModified = lastModified
        self.isFavorite = isFavorite
        
        self.showBackgroundGrid = showBackgroundGrid
        self.previousZoomScale = previousZoomScale
        
        self.imageData = imageData
        
        self.previousContentOffsetX = previousOffset.x
        self.previousContentOffsetY = previousOffset.y
        self.drawings = drawings
        self.nonDrawings = nonDrawings
        self.objectOrder = objectOrder.map(\._uuid)
        // to clean up
        self.removeEmptyDrawings()
    }
    
    
    init() {
        self.name = Constants.defaultDoodleName
        self.lastModified = Date()
        self.isFavorite = false
        self.showBackgroundGrid = true
        self.previousZoomScale = 1
        self.previousContentOffsetX = (Constants.canvasSize.width - UIScreen.main.bounds.width) / 2
        self.previousContentOffsetY = (Constants.canvasSize.height - UIScreen.main.bounds.height) / 2
        self.drawings = []
        self.nonDrawings = []
        self.objectOrder = []
    }
}

private struct _UUID: Codable, Equatable, Hashable, Identifiable {
    var id: UUID
}

private extension _UUID {
    var uuid: UUID { self.id }
}

private extension UUID {
    var _uuid: _UUID { .init(id: self) }
}



// MARK: calculated properties
extension DoodleModel {
    
    var duplicate: DoodleModel {
        var duplicatedDrawing: [DrawingModel] = []
        var duplicatedNonDrawing: [NonDrawingModel] = []
        var objectOrder: [UUID] = []
        for object in self.allObjects {
            switch object {
            case .nonDrawing(let model):
                let duplicate = model.duplicate
                duplicatedNonDrawing.append(duplicate)
                objectOrder.append(duplicate.id)
            case .drawing(let model):
                let duplicate = model.duplicate
                duplicatedDrawing.append(duplicate)
                objectOrder.append(duplicate.id)
            }
        }

        let new = DoodleModel(
            name: self.name + " copy",
            lastModified: Date(),
            isFavorite: self.isFavorite,
            showBackgroundGrid: true,
            previousZoomScale: self.previousZoomScale,
            imageData: self.imageData,
            previousOffset: .init(x: self.previousContentOffsetX, y: self.previousContentOffsetY),
            drawings: duplicatedDrawing,
            nonDrawings: duplicatedNonDrawing,
            objectOrder: objectOrder
        )
        
        return new
    }
    
    var allObjects: [DoodleObject] {
        let drawing: [DoodleObject] = self.drawings.map({DoodleObject.drawing($0)})
        let images: [DoodleObject] = self.nonDrawings.map({DoodleObject.nonDrawing($0)})

        let all: [DoodleObject] = drawing + images
        return all.sorted { self.orderForId($0.id) < self.orderForId($1.id) }
    }
    
    var bounds: CGRect {
        var bounds: CGRect? = nil
        for doodleObject in self.allObjects {
            let objectRect = CGRect(origin: CGPoint(x: doodleObject.position.x - doodleObject.size.width/2, y: doodleObject.position.y - doodleObject.size.height/2), size: doodleObject.size)
            if bounds == nil {
                bounds = objectRect
            } else {
                bounds = bounds?.union(objectRect)
            }
        }
        return bounds ?? .zero
    }
    
    var zoomThatFits: CGFloat {
        let heightScale = self.bounds.width / UIScreen.main.bounds.width
        let widthScale = self.bounds.height / UIScreen.main.bounds.height

        return min(max(min(widthScale, heightScale) * 0.8, Constants.minZoom), Constants.maxZoom)
    }

}


extension DoodleModel {
    
    @MainActor
    func getThumbnailImage() -> UIImage? {
        if let imageData = self.imageData {
            print("previous data exists")
            return UIImage(data: imageData)
        }
        
        print("generating new image")
        
        var view: some View {
            ZStack {
                Group {
                    ForEach(self.allObjects) { doodleObject in
                        Group {
                            switch doodleObject {
                            case .drawing(let drawingModel):
                                DrawingObjectView(
                                    drawingModel: drawingModel
                                )
                            case .nonDrawing(let nonDrawingModel):
                                Group {
                                    switch nonDrawingModel.object {
                                    case .image(let imageObject):
                                        ImageObjectView(imageObject: imageObject)
                                        
                                    case .link(let linkObject):
                                        LinkObjectView(linkObject: linkObject)
                                        
                                    }
                                }
                            }
                        }
                        .frame(width: doodleObject.size.width, height: doodleObject.size.height)
                        .padding(.horizontal, doodleObject.size.width/2)
                        .padding(.vertical, doodleObject.size.height/2)
                        .rotationEffect(.degrees(doodleObject.angleDegree))
                        .position(doodleObject.position)

                    }
                }
                .frame(width: self.bounds.width, height: self.bounds.height)
                .offset(x: -self.bounds.origin.x, y: -self.bounds.origin.y)

            }
            
        }
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        
        let uiImage = renderer.uiImage
        if let compressed = uiImage?.pngData()?.compressedImage(to: .init(width: UIScreen.main.bounds.width/4, height: UIScreen.main.bounds.height/4)) {
            self.imageData = compressed.pngData()
        } else {
            self.imageData = uiImage?.pngData()
        }
        
        return uiImage
    }
    
    func removeEmptyDrawings() {
        let emptyIds = self.drawings.filter({ $0.drawing.strokes.isEmpty}).map { $0.id }
        for id in emptyIds {
            self.removeObject(id)
        }
    }
    
    
    func orderForObject(_ object: DoodleObject) -> Int {
        return self.orderForId(object.id)
    }
    
    func changeObjectOrder(from: Int, to: Int) {
        guard from != to else { return }
        guard (0...self.objectOrder.count).contains(to) else { return }
        self.objectOrder.move(fromOffsets: .init(integer: from), toOffset: to > from ? to + 1 : to)

    }
    
    func removeObject(_ id: DoodleObject.ID) {
        self.drawings.removeAll { $0.id == id }
        self.nonDrawings.removeAll { $0.id == id }
        self.objectOrder.removeAll { $0.id == id }
    }


    func addDrawing(_ drawing: DrawingModel, index: Int? = nil) {
        if let index, index < self.drawings.count {
            self.objectOrder.insert(drawing.id._uuid, at: index)
            self.drawings.insert(drawing, at: index)
        } else {
            self.objectOrder.append(drawing.id._uuid)
            self.drawings.append(drawing)
        }
    }
    
    func addNonDrawing(_ nonDrawing: NonDrawingModel, index: Int? = nil) {
        if let index, index < self.nonDrawings.count {
            self.objectOrder.insert(nonDrawing.id._uuid, at: index)
            self.nonDrawings.insert(nonDrawing, at: index)
        } else {
            self.objectOrder.append(nonDrawing.id._uuid)
            self.nonDrawings.append(nonDrawing)
        }
    }
    
    private func orderForId(_ id: UUID) -> Int {
        return self.objectOrder.firstIndex(of: id._uuid) ?? 0
    }
}


// MARK: for testing
extension DoodleModel {
    static var testModel: DoodleModel {
        let firstPoint: PKStrokePoint = .init(
            location: CGPoint(x: 50, y: 50),
            timeOffset: 0,
            size: .init(width: 20, height: 20),
            opacity: 0.8, force: 10, azimuth: 5, altitude: 5)
        let secondPoint: PKStrokePoint = .init(
            location: CGPoint(x: 450, y: 800),
            timeOffset: 10,
            size: .init(width: 20, height: 20),
            opacity: 0.8, force: 10, azimuth: 0, altitude: 5)
        let stroke = PKStroke(ink: .init(.fountainPen, color: .systemPink), path: .init(controlPoints: [firstPoint, secondPoint], creationDate: Date()))

        let drawing = PKDrawing(strokes: [stroke])
        let drawingModel = DrawingModel(drawing: drawing)

        let imageObject = ImageObject(image: UIImage(systemName: "heart.fill")!)
        let imageModel = NonDrawingModel(object: .image(imageObject), position: .init(x: 200, y: 200), size: .init(width: 200, height: 200), angleDegree: 20)
        
        let linkObject = LinkObject(link: "https://www.google.com", image: nil, title: nil)
        let linkModel = NonDrawingModel(object: .link(linkObject), position: .init(x: 250, y: 250), size: .init(width: 200, height: 200), angleDegree: 20)

        return DoodleModel(name: "Test", lastModified: Date(), isFavorite: true, showBackgroundGrid: true, previousZoomScale: 0.75, imageData: nil, previousOffset: .zero, drawings: [drawingModel], nonDrawings: [imageModel, linkModel], objectOrder: [drawingModel.id, imageModel.id, linkModel.id])
    }

}

