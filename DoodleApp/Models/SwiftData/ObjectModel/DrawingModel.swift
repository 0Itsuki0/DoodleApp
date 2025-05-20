//
//  DrawingModel.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/07.
//

import SwiftUI
import SwiftData
import PencilKit


@Model
class DrawingModel {
    @Attribute(.unique) var id: UUID = UUID()
    
    private var drawingData: Data
    
    var drawing: PKDrawing {
        get {
            (try? PKDrawing(data: drawingData)) ?? PKDrawing()
        }
        set {
            drawingData = newValue.dataRepresentation()
        }
    }
    
    
    var size: CGSize {
        get {
            self.drawing.bounds.size
        }
        set {

            let currentSize = self.drawing.bounds.size
                        
            let scaleX = newValue.width/currentSize.width
            let scaleY = newValue.height/currentSize.height

            let previousPosition = self.position
            self.drawing.transform(using: .init(scaleX: scaleX, y: scaleY))
            // scaling anchor will shift the position. Set it back to the previous
            self.position = previousPosition
        }
    }
    
    var position: CGPoint {
        get {
            let bounds = self.drawing.bounds
            return CGPoint(x: bounds.midX, y: bounds.midY)
        }
        set {
            let currentPosition = self.position
            self.drawing.transform(using: .init(translationX: newValue.x - currentPosition.x, y: newValue.y - currentPosition.y))
        }
    }
  

    init(drawing: PKDrawing) {
        self.drawingData = drawing.dataRepresentation()
    }
    
}

