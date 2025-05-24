//
//  BottomToolBar.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/08.
//

import SwiftUI

struct SelectedObjectControls: View {
    @Environment(BoardViewModel.self) private var boardViewModel: BoardViewModel


    var body: some View {
        let doodleModel: DoodleModel = boardViewModel.doodleModel
        
        if let selectedObject = boardViewModel.selectedObject, !selectedObject.enableEditing, let doodleObject = doodleModel.allObjects.first(where: {$0.id == selectedObject.id}) {
            
            HStack(spacing: 24) {
                switch doodleObject {
                case .drawing(_):
                    makeButton(systemName: "scribble", action: {
                        boardViewModel.selectedObject?.enableEditing = true
                    })

                case .nonDrawing(let nonDrawingModel):
                    Group {
                        switch nonDrawingModel.object {
                        case .image(_):
                            Menu(content: {
                                Section("Replace Photo", content: {
                                    AddImageMenu()
                                })

                            }, label: {
                                ToolBarImage(systemName: "photo.on.rectangle")
                                    .foregroundStyle(.black.opacity(0.8))

                            })
                            
                        case .link(_):
                            makeButton(systemName: "safari", action: {
                                boardViewModel.showLinkEntryAlert = true
                            })
                            
                            makeButton(systemName: "arrow.clockwise", action: {
                                boardViewModel.reloadLinkMetadata()
                            })

                        }
                        
                    }
                }
                
                Rectangle()
                    .frame(width: 2, height: 36)
                    .foregroundStyle(.gray.opacity(0.2))
                   
                    
                makeButton(systemName: "plus.square.on.square", action: {
                    self.boardViewModel.duplicateObject(doodleObject)
                })
                
                
                makeButton(systemName: "trash", action: {
                    self.boardViewModel.removeObject(doodleObject)
                    
                }, foregroundColor: .red)
                

                Menu(content: {
                    MenuButton("Bring Forward", "square.2.layers.3d.top.filled", {
                        boardViewModel.moveObjectForward(doodleObject)
                    })
                    MenuButton("Bring To Front", "square.3.layers.3d.top.filled", {
                        boardViewModel.moveObjectToFront(doodleObject)
                    })
                    MenuButton("Send Backward", "square.2.layers.3d.bottom.filled", {
                        boardViewModel.moveObjectBackward(doodleObject)
                    })
                    MenuButton("Send To Back", "square.3.layers.3d.bottom.filled", {
                        boardViewModel.moveObjectToBack(doodleObject)
                    })

                }, label: {
                    ToolBarImage(systemName: "ellipsis.circle")
                        .foregroundStyle(.black.opacity(0.8))

                })
                .menuOrder(.fixed)


            }
            .padding(.horizontal, 32)
            .background(
                Capsule()
                    .fill(.white)
                    .fill(.gray.opacity(0.05))
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 2, y: 2)
            )

        }
    }
    
    private func makeButton(systemName: String, action: @escaping () -> Void, foregroundColor: Color? = nil) -> some View {
        Button(action: action, label: {
            ToolBarImage(systemName: systemName)
                .fontWeight(.medium)
                .foregroundStyle(foregroundColor ?? .black.opacity(0.8))
        })
        .padding(.vertical, 16)
    }
}


#Preview {
    let model = DoodleModel.testModel
    var viewModel: BoardViewModel {
        let vm = BoardViewModel(doodleModel: model)
        vm.selectedObject = .init(objectId: model.nonDrawings[1].id, enableEditing: false)
        return vm
    }
        
    VStack {
        SelectedObjectControls()
            .environment(viewModel)

    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.yellow.opacity(0.1))
    
}
