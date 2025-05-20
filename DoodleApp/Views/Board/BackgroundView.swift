//
//  BackgroundView.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/07.
//

import SwiftUI

struct BackgroundView: View {
    @Environment(BoardViewModel.self) private var boardViewModel: BoardViewModel
   
    var body: some View {
        
        ZStack {
            if self.boardViewModel.doodleModel.showBackgroundGrid {
                GeometryReader { proxy in
                    
                    Image("background/dot")
                        .renderingMode(.original)
                        .resizable(capInsets: .init(top: 0, leading: 0, bottom: 0, trailing: 0), resizingMode: .tile)
                        .foregroundStyle(.gray.opacity(0.2))
                        .frame(width: Constants.canvasSize.width, height: Constants.canvasSize.height)
                        .scaleEffect(self.boardViewModel.doodleModel.previousZoomScale, anchor: .topLeading)
                        .offset(x: -self.boardViewModel.doodleModel.previousOffset.x, y: -self.boardViewModel.doodleModel.previousOffset.y)
                }
                
            }
            Color.yellow.opacity(0.1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            EmptyScrollView()
                .allowsHitTesting(!boardViewModel.allowCanvasHitTest)

        }
    }
}

