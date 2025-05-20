//
//  ObjectModel.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/08.
//


import SwiftUI
import SwiftData
import PencilKit

enum NonDrawingObjectEnum: Codable {
    case image(ImageObject)
    case link(LinkObject)
//    case shape
//    case hyperlink
//    case text
}

@Model
class NonDrawingModel {
    @Attribute(.unique) var id: UUID = UUID()
    
    var object: NonDrawingObjectEnum
        
    private var positionX: CGFloat
    private var positionY: CGFloat
    
    var position: CGPoint {
        get {
            return CGPoint(x: positionX, y: positionY)
        }
        set {
            positionX = newValue.x
            positionY = newValue.y
        }
    }
    
    private var width: CGFloat
    private var height: CGFloat
    
    var size: CGSize {
        get {
            return CGSize(width: width, height: height)
        }
        set {
            width = newValue.width
            height = newValue.height
        }
    }

    
    var angleDegree: CGFloat
    
    init(object: NonDrawingObjectEnum, position: CGPoint, size: CGSize, angleDegree: CGFloat) {
        self.object = object
        self.positionX = position.x
        self.positionY = position.y
        self.width = size.width
        self.height = size.height
        self.angleDegree = angleDegree
    }
    
}



