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
class DrawingModel {

    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var lastModified: Date
    var isFavorite: Bool

    private var drawingData: Data
    
    var drawing: PKDrawing {
        get {
            (try? PKDrawing(data: drawingData)) ?? PKDrawing()
        }
        set {
            drawingData = newValue.dataRepresentation()
        }
    }

    init(drawing: PKDrawing, name: String, lastModified: Date, isFavorite: Bool) {
        self.name = name
        self.lastModified = lastModified
        self.isFavorite = isFavorite
        self.drawingData = drawing.dataRepresentation()
    }
    
    init() {
        self.name = Self.defaultName
        self.lastModified = Date()
        self.isFavorite = false
        self.drawingData = PKDrawing().dataRepresentation()
    }
}


extension DrawingModel {
    static let defaultName: String = "Untitled"
    
    var duplicate: DrawingModel {
        let new = DrawingModel(drawing: self.drawing, name: self.name + " copy", lastModified: Date(), isFavorite: self.isFavorite)
        return new
    }
    
    static var testModel: DrawingModel {
        let firstPoint: PKStrokePoint = .init(
            location: CGPoint(x: 200, y: 200),
            timeOffset: 0,
            size: .init(width: 20, height: 20),
            opacity: 0.8, force: 10, azimuth: 5, altitude: 5)
        let secondPoint: PKStrokePoint = .init(
            location: CGPoint(x: 450, y: 150),
            timeOffset: 10,
            size: .init(width: 20, height: 20),
            opacity: 0.8, force: 10, azimuth: 0, altitude: 5)
        let stroke = PKStroke(ink: .init(.fountainPen, color: .systemPink), path: .init(controlPoints: [firstPoint, secondPoint], creationDate: Date()))

        let drawing = PKDrawing(strokes: [stroke])

        return DrawingModel(drawing: drawing, name: "Test", lastModified: Date(), isFavorite: true)
    }
}

