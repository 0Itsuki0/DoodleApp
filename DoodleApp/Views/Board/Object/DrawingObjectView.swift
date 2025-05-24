//
//  DrawingObjectView.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/09.
//

import SwiftUI
import PencilKit


struct DrawingObjectView: View {
    let drawingModel: DrawingModel
    
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        
        let bounds = drawingModel.drawing.bounds
        if bounds.isBounded {
            let image = drawingModel.drawing.image(from: bounds, scale: displayScale)
            Image(uiImage: image)
                .renderingMode(.original)
                .resizable()
        }
    }
}



