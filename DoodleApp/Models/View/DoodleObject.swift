//
//  DoodleObject.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/07.
//

import SwiftUI

// for view rendering
enum DoodleObject {
    case nonDrawing(NonDrawingModel)
    case drawing(DrawingModel)
}

extension DoodleObject: Identifiable {
    var id: UUID {
        switch self {
        case .drawing(let model):
            return model.id
        case .nonDrawing(let model):
            return model.id
        }
    }
    
//    var order: Int {
//        get {
//            switch self {
//            case .drawing(let model):
//                return model.order
//            case .nonDrawing(let model):
//                return model.order
//            }
//        }
//        set {
//            switch self {
//            case .drawing(let model):
//                model.order = newValue
//            case .nonDrawing(let model):
//                model.order = newValue
//            }
//        }
//    }
    
    var size: CGSize {
        get {
            switch self {
            case .drawing(let model):
                return model.size
            case .nonDrawing(let model):
                return model.size
            }
        }
//        set {
//            switch self {
//            case .drawing(let model):
//                model.size = newValue
//            case .image(let model):
//                model.size = newValue
//            }
//        }
    }
    
    var position: CGPoint {
        get {
            switch self {
            case .drawing(let model):
                return model.position
            case .nonDrawing(let model):
                return model.position
            }
        }
    }
    
    var angleDegree: CGFloat {
        get {
            switch self {
            case .drawing(_):
                return 0.0
            case .nonDrawing(let model):
                return model.angleDegree
            }
        }
    }
    
    func setSize(_ size: CGSize) {
        switch self {
        case .drawing(let model):
            model.size = size
        case .nonDrawing(let model):
            model.size = size
        }
    }
    
    func setPosition(_ position: CGPoint) {
        switch self {
        case .drawing(let model):
            model.position = position
        case .nonDrawing(let model):
            model.position = position
        }
    }
    
    func setAngle(_ angle: CGFloat) {
        switch self {
        case .drawing(_):
            break
        case .nonDrawing(let model):
            model.angleDegree = angle
        }
    }
}


//
//extension DoodleObject {
//    var isDrawingObject: Bool {
//        switch self {
//        case .drawing:
//            return true
//        default:
//            return false
//        }
//    }
//}
