//
//  ImageObjectView.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/09.
//

import SwiftUI

struct ImageObjectView: View {
    let imageObject: ImageObject
    
    var body: some View {
        imageObject.image?
            .renderingMode(.original)
            .resizable()
    }
}
