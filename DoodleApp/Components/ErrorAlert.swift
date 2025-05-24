//
//  ErrorAlert.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/24.
//


import SwiftUI

extension View {
    func errorAlert(
        showErrorAlert: Binding<Bool>,
        error: String?,
    ) -> some View {
        self.modifier(ErrorAlert(
            showErrorAlert: showErrorAlert,
            error: error
        ))
    }
}


private struct ErrorAlert: ViewModifier {

    @Binding var showErrorAlert: Bool
    var error: String?
    
    func body(content: Content) -> some View {
        let title = "Something Went Wrong!"
        let message = error
        
        content
            .alert(title, isPresented: $showErrorAlert) {

                Button(action: {
                    showErrorAlert = false
                }, label: {
                    Text("Ok")
                })
                
            } message: {
                if let message {
                    Text(message)
                }
            }
    }

}


#Preview(body: {
    
    VStack {
        
    }
    .linkEntryAlert(showLinkEntryAlert: .constant(true), onConfirm: {_ in}, currentLink: "1345")
})
