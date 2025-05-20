//
//  ImageImporter.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/18.
//

import SwiftUI

extension View {
    func imageImporter(
        showImporter: Binding<Bool>,
        onImageImportComplete: @escaping (_ result: Result<[URL], any Error>) -> Void,
        allowMultiSelection: Bool
    ) -> some View {
        self.modifier(ImageImporter(
            showImporter: showImporter,
            onImageImportComplete: onImageImportComplete,
            allowMultiSelection: allowMultiSelection
        ))
    }
}


private struct ImageImporter: ViewModifier {
    @Binding var showImporter: Bool
    var onImageImportComplete: (_ result: Result<[URL], any Error>) -> Void
    var allowMultiSelection: Bool


    func body(content: Content) -> some View {
        content
            .fileImporter(
                isPresented: $showImporter,
                allowedContentTypes: [.image],
                allowsMultipleSelection: self.allowMultiSelection,
                onCompletion: onImageImportComplete
            )
    }

}
