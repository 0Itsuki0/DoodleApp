//
//  PhotoPicker.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/10.
//

import SwiftUI
import PhotosUI

extension View {
    func photosPicker(
        showPicker: Binding<Bool>,
        onPickerItemChange: @escaping ([PhotosPickerItem]) async -> Void,
        allowMultiSelection: Bool
    ) -> some View {
        self.modifier(PhotosPicker(
            showPicker: showPicker,
            onPickerItemChange: onPickerItemChange,
            allowMultiSelection: allowMultiSelection
        ))
    }
}


private struct PhotosPicker: ViewModifier {
    @Binding var showPicker: Bool
    var onPickerItemChange: ([PhotosPickerItem]) async -> Void
    var allowMultiSelection: Bool

    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var pickerItem: PhotosPickerItem? = nil

    func body(content: Content) -> some View {
        if allowMultiSelection {
            content
                .photosPicker(isPresented: $showPicker, selection: $pickerItems, matching: .any(of: [.images]), photoLibrary: .shared())
                .onChange(of: pickerItems) {
                    Task {
                        await onPickerItemChange(pickerItems)
                    }
                }
        } else {
            content
                .photosPicker(isPresented: $showPicker, selection: $pickerItem, matching: .any(of: [.images]), photoLibrary: .shared())
                .onChange(of: pickerItem) {
                    guard let pickerItem else { return }
                    Task {
                        await onPickerItemChange([pickerItem])
                    }
                }

        }
    }

}
