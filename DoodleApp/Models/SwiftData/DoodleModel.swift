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

    
    init(name: String, lastModified: Date, isFavorite: Bool, showBackgroundGrid: Bool, previousZoomScale: CGFloat, previousOffset: CGPoint, drawings: [DrawingModel], nonDrawings: [NonDrawingModel], objectOrder: [UUID]) {
        self.name = name
        self.lastModified = lastModified
        self.isFavorite = isFavorite
        self.showBackgroundGrid = showBackgroundGrid
        self.previousZoomScale = previousZoomScale
        self.previousContentOffsetX = previousOffset.x
        self.previousContentOffsetY = previousOffset.y
        self.drawings = drawings
        self.nonDrawings = nonDrawings
        self.objectOrder = objectOrder.map(\._uuid)
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


// MARK: calculated properties
extension DoodleModel {
    
    var duplicate: DoodleModel {
        let new = DoodleModel(name: self.name + " copy", lastModified: Date(), isFavorite: self.isFavorite, showBackgroundGrid: true, previousZoomScale: self.previousZoomScale, previousOffset: .init(x: self.previousContentOffsetX, y: self.previousContentOffsetY), drawings: self.drawings, nonDrawings: self.nonDrawings, objectOrder: self.objectOrder.map(\.id))
        return new
    }
    
    var allObjects: [DoodleObject] {
        let drawing: [DoodleObject] = self.drawings.map({DoodleObject.drawing($0)})
        let images: [DoodleObject] = self.nonDrawings.map({DoodleObject.nonDrawing($0)})

        let all: [DoodleObject] = drawing + images
        return all.sorted { self.orderForId($0.id) < self.orderForId($1.id) }
    }

}


extension DoodleModel {
    
    func orderForObject(_ object: DoodleObject) -> Int {
        return self.orderForId(object.id)
    }
    
    func changeObjectOrder(from: Int, to: Int) {
        print("change object order from \(from) to \(to)")
        guard from != to else { return }
        print("order before move: \(self.objectOrder)")
        guard (0...self.objectOrder.count).contains(to) else { return }
        self.objectOrder.move(fromOffsets: .init(integer: from), toOffset: to > from ? to + 1 : to)
        print("order after move: \(self.objectOrder)")

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

        return DoodleModel(name: "Test", lastModified: Date(), isFavorite: true, showBackgroundGrid: true, previousZoomScale: 0.75, previousOffset: .zero, drawings: [drawingModel], nonDrawings: [imageModel, linkModel], objectOrder: [drawingModel.id, imageModel.id, linkModel.id])
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
