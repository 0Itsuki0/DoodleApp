//
//  ImportImageMenu.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/17.
//

import SwiftUI

struct AddImageMenu: View {
    @Environment(BoardViewModel.self) private var boardViewModel: BoardViewModel

    var body: some View {
        Button(action: {
            boardViewModel.showPhotosPicker = true
        }, label: {
            HStack {
                Text("Photos")
                Image(systemName: "photo.on.rectangle")
            }
        })
        
        Button(action: {
            boardViewModel.showImageImporter = true
        }, label: {
            HStack {
                Text("Insert from...")
                Image(systemName: "folder")
            }
        })

    }
}
