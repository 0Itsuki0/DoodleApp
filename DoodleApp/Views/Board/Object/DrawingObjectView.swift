//
//  DrawingObjectView.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/09.
//

import SwiftUI
import PencilKit


struct DrawingObjectView: View {
    @Environment(BoardViewModel.self) private var boardViewModel: BoardViewModel

    let drawingModel: DrawingModel
    
    var body: some View {
        
        let bounds = drawingModel.drawing.bounds
        if !bounds.isInfinite && !bounds.isNull && !bounds.isEmpty {
            let image = drawingModel.drawing.image(from: bounds, scale: self.boardViewModel.doodleModel.previousZoomScale)
            Image(uiImage: image)
                .renderingMode(.original)
                .resizable()
        }
    }
}



