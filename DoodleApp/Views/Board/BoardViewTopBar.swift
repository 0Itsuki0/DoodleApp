//
//  BoardViewTopBar.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/09.
//


import SwiftUI
import PencilKit


struct BoardViewTopBar: ToolbarContent {
    @Environment(BoardViewModel.self) private var boardViewModel: BoardViewModel

//    let doodleModel: DoodleModel
//    
//    @Binding var canUndo: Bool
//    @Binding var canRedo: Bool
//    @Binding var selectedObject: BoardView.Selection?
//    @Binding var showRenameAlert: Bool

    var isCompact: Bool

    
    @Environment(\.dismiss) private var dismiss
//    @Environment(\.undoManager) private var undoManager

//    @AppStorage("drawingPolicy") private var pencilOnly: Bool = true

    
    var body: some ToolbarContent {
        let doodleModel = boardViewModel.doodleModel
        @Bindable var boardViewModel = boardViewModel
        
        ToolbarItem(placement: .topBarLeading, content: {
            HStack(spacing: 8) {
                Button(action: {
                    dismiss()
                }, label: {
                    HStack {
                        ToolBarImage(systemName: "chevron.left")
                            .fontWeight(.bold)
                            .scaleEffect(0.8)

                        if !isCompact {
                            Text("Drawings")
                        }
                    }
                })
                
                    HStack(spacing: 8)  {
                        Button(action: {
                            self.boardViewModel.undoManager?.undo()
                        }, label: {
                            ToolBarImage(systemName: "arrow.uturn.backward.circle")
                        })
                        .disabled(!boardViewModel.canUndo)

                        Button(action: {
                        
                            self.boardViewModel.undoManager?.redo()

                        }, label: {
                            ToolBarImage(systemName: "arrow.uturn.forward.circle")
                        })
                        .disabled(!boardViewModel.canRedo)

                    }
                    .padding(.leading, 8)

            }
        })

        ToolbarItem(placement: .topBarTrailing, content: {
//                    let image = Image(uiImage: doodleModel.drawing.image(from: doodleModel.drawing.bounds, scale: 1.0))

            HStack(spacing: 8) {

//                        ShareLink(item: image, preview: SharePreview(doodleModel.name, image: image), label: {
//                            ToolBarImage(systemName: "square.and.arrow.up")
//                        })
//                        .simultaneousGesture(TapGesture()
//                            .onEnded({
//                                showTools = false
//                            }))

                
                if self.boardViewModel.selectedObject != nil {
                    Button(action: {
                        // remove drawing if it is empty
                        if let selectedObject = boardViewModel.selectedObject, selectedObject.enableEditing, let drawingModel = self.boardViewModel.doodleModel.drawings.first(where: {$0.id == selectedObject.id}) {
                            if drawingModel.drawing.strokes.isEmpty {
                                // not allow undoing
                                self.boardViewModel.doodleModel.removeObject(drawingModel.id)
                            }
                        }

                        self.boardViewModel.selectedObject = nil

                    }, label: {
                        Text("Done")
                            .fontWeight(.semibold)
                            .contentShape(Rectangle())
                    })
                }
                
                Menu(content: {
                    Section {
                        MenuButton("Rename", "pencil", {
                            boardViewModel.showRenameAlert = true
                        })

                        MenuButton(doodleModel.isFavorite ? "Unfavorite" :"Favorite", doodleModel.isFavorite ? "heart.slash" : "heart", {
                            doodleModel.isFavorite.toggle()
                        })

                    }
                    
                    Section("Drawing Input") {
                        Picker(selection: $boardViewModel.drawingPolicy, content: {
                            Text("Apple Pencil Only")
                                .tag(PKCanvasViewDrawingPolicy.pencilOnly)
                            Text("Any Input")
                                .tag(PKCanvasViewDrawingPolicy.anyInput)
                        }, label: {
                            Text("Drawing Input")
                        })
                        
                    }
                    
                    
                    Section {
                        MenuButton("Show Grid", doodleModel.showBackgroundGrid ? "checkmark" : nil, {
                            doodleModel.showBackgroundGrid.toggle()
                        })
                        
                    }
                    

                }, label: {
                    ToolBarImage(systemName: "ellipsis.circle")
                })
                    
            }

        })

    }
    
}


//#Preview {
//    NavigationStack {
//        VStack {
//            Text("test")
//        }
//        .toolbar(content: {
//            BoardViewTopBar(
//                doodleModel: DoodleModel.testModel,
//                canUndo: .constant(true),
//                canRedo: .constant(true),
//                selectedObject: .constant(nil),
//                showRenameAlert: .constant(false),
//                isCompact: true
//            )
//        })
//    }
//
//}
