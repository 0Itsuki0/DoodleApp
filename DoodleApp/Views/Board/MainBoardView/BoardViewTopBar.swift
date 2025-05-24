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

    var isCompact: Bool
    
    @Environment(\.dismiss) private var dismiss

    
    var body: some ToolbarContent {
        let doodleModel = boardViewModel.doodleModel
        @Bindable var boardViewModel = boardViewModel
        
        ToolbarItem(placement: .topBarLeading, content: {
            HStack(spacing: 8) {
                Button(action: {
                    doodleModel.removeEmptyDrawings()
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

            HStack(spacing: 8) {

                
                if self.boardViewModel.selectedObject != nil {
                    Button(action: {
                        self.boardViewModel.selectedObject = nil
                        // remove drawing if it is empty
                        doodleModel.removeEmptyDrawings()

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
                    
                    Section {
                        
                        let transferable = ImageTransferable(generateImage: doodleModel.getThumbnailImage)

                        ShareLink(item: transferable, preview: SharePreview(doodleModel.name, image: transferable), label: {
                            HStack {
                                Text("Share")
                                Spacer()
                                ToolBarImage(systemName: "square.and.arrow.up")
                            }
                        })
                        .onLongPressGesture(minimumDuration: 0.01) {
                            print("sharelink pressed")
                        }


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
            .onLongPressGesture(minimumDuration: 0) {
                boardViewModel.selectedObject?.enableEditing = false
            }

        })

    }
    
}


#Preview {
    NavigationStack {
        VStack {
            Text("test")
        }
        .toolbar(content: {
            BoardViewTopBar(isCompact: true)
        })
        .environment(BoardViewModel(doodleModel: DoodleModel.testModel))

    }

}
