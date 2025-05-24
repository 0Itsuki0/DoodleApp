//
//  BoardViewBottomBar.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/09.
//

import SwiftUI

struct BoardViewBottomBar: View {
    @Environment(BoardViewModel.self) private var boardViewModel: BoardViewModel

//    let doodleModel: DoodleModel

//    @Binding var selectedObject: BoardView.Selection?
    
    var body: some View {
//        @Bindable var boardViewModel = boardViewModel
        if boardViewModel.selectedObject == nil {
            HStack {
                Button(action: {
                    boardViewModel.addNewDrawing()
                }, label: {
                    ToolBarImage(systemName: "pencil.tip.crop.circle")
                })
                
                Spacer()
                
                Menu(content: {
                    AddImageMenu()
                }, label: {
                    ToolBarImage(systemName: "photo.on.rectangle")
                })
                
                Spacer()
                
                Button(action: {
                    boardViewModel.showLinkEntryAlert = true
                }, label: {
                    ToolBarImage(systemName: "safari")
                })
                
            }
            .padding(.top, 24)
            .padding(.horizontal, 36)
            .frame(maxWidth: .infinity)
            .background(.white)
            
        } else {
            SelectedObjectControls()
        }

    }
}


#Preview {
    VStack {

    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.gray.opacity(0.3))
    .overlay(alignment: .bottom, content: {
        BoardViewBottomBar()
            .environment(BoardViewModel(doodleModel: DoodleModel.testModel))
    })

    
}
