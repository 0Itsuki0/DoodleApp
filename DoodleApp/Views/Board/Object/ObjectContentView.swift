//
//  NonEditingContentView.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/17.
//


import SwiftUI


struct ObjectContentView: View {
    @Environment(BoardViewModel.self) private var boardViewModel: BoardViewModel

    var body: some View {

        ZStack {

            Group {
                ForEach(self.boardViewModel.doodleModel.allObjects) { doodleObject in
                    
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
                    .interactable(doodleObject: doodleObject)
                }
            }
            .scaleEffect(self.boardViewModel.doodleModel.previousZoomScale, anchor: .topLeading)
            .offset(x: -self.boardViewModel.doodleModel.previousOffset.x, y: -self.boardViewModel.doodleModel.previousOffset.y)

            
        }
    }
}



#Preview {
    NavigationStack {
        ObjectContentView()
            .modelContainer(for: [DoodleModel.self], inMemory: true)
            .environment(BoardViewModel(doodleModel: DoodleModel.testModel))

            
    }
    
    
}
