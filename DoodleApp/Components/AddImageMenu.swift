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

        MenuButton("Photos", "photo.on.rectangle", {
            boardViewModel.showPhotosPicker = true
        })

        MenuButton("Insert from...", "folder", {
            boardViewModel.showImageImporter = true
        })

    }
}
