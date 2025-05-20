//
//  LinkEntryAlert.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/17.
//


import SwiftUI

extension View {
    func linkEntryAlert(
        showLinkEntryAlert: Binding<Bool>,
        onConfirm: @escaping (String) -> Void,
        currentLink: String?
    ) -> some View {
        self.modifier(LinkEntryAlert(
            showLinkEntryAlert: showLinkEntryAlert,
            onConfirm: onConfirm,
            currentLink: currentLink,
        ))
    }
}


private struct LinkEntryAlert: ViewModifier {

    @Binding var showLinkEntryAlert: Bool
    var onConfirm: (String) -> Void
    var currentLink: String?

    @State private var linkEntry: String = ""
    
    func body(content: Content) -> some View {
        let title = currentLink == nil ? "Add Link" : "Edit Link"
        let placeHolder = currentLink == nil ? "https://medium.com/@itsuki.enjoy" : ""
        let message = "Enter the link address."
        let confirmButton = currentLink == nil ? "Insert" : "OK"
        
        content
            .alert(title, isPresented: $showLinkEntryAlert) {
                TextField(placeHolder, text: $linkEntry)
                    .textInputAutocapitalization(.never)
                    .textContentType(.URL)

                Button(action: {
                    showLinkEntryAlert = false
                }, label: {
                    Text("Cancel")
                })
                
                Button(action: {
                    onConfirm(self.linkEntry)
                    showLinkEntryAlert = false
                }, label: {
                    Text(confirmButton)
                })
                .disabled(linkEntry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            } message: {
                Text(message)
            }
            .onChange(of: currentLink, initial: true, {
                self.linkEntry = currentLink ?? ""
            })
    }

}


#Preview(body: {
    
    VStack {
        
    }
    .linkEntryAlert(showLinkEntryAlert: .constant(true), onConfirm: {_ in}, currentLink: "1345")
})
