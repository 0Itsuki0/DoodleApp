//
//  RenameAlert.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/09.
//

import SwiftUI

extension View {
    func renameAlert(
        doodleModel: DoodleModel,
        showRenameAlert: Binding<Bool>
    ) -> some View {
        self.modifier(RenameAlert(
            doodleModel: doodleModel,
            showRenameAlert: showRenameAlert,
            nameEntry: doodleModel.name
        ))
    }
}


private struct RenameAlert: ViewModifier {

    let doodleModel: DoodleModel
    @Binding var showRenameAlert: Bool
    
    @State var nameEntry: String
    
    func body(content: Content) -> some View {
        content
            .alert("Rename Drawing", isPresented: $showRenameAlert) {
                TextField("", text: $nameEntry)

                Button(action: {
                    showRenameAlert = false
                }, label: {
                    Text("Cancel")
                })
                Button(action: {
                    doodleModel.name = nameEntry.isEmpty ? Constants.defaultDoodleName: nameEntry
                    showRenameAlert = false
                }, label: {
                    Text("OK")
                })
            } message: {
                Text("Enter a new name for this drawing.")
            }

    }

}
