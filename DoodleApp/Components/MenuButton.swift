//
//  MenuButton.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/04.
//

import SwiftUI


extension MenuButton {
    init (_ title: String, _ image: String?, _ action: @escaping () -> Void, role: ButtonRole? = nil) {
        self.title = title
        self.image = image
        self.action = action
        self.role = role
    }
}

struct MenuButton: View {
    var title: String
    var image: String?
    var action: () -> Void
    var role: ButtonRole? = nil
    
    var body: some View {
        Button(role: role, action: {
            action()
        }, label: {
            HStack {
                Text(title)
                Spacer()
                if let image {
                    Image(systemName: image)
                }
            }
        })

    }
}
