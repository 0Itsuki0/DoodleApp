//
//  ToolBarImage.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/08.
//

import SwiftUI

struct ToolBarImage: View {
    var systemName: String
    
    var body: some View {
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .contentShape(Rectangle())
    }
}
