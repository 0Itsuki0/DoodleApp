//
//  ImageObject.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/08.
//

import SwiftUI

struct ImageObject: Codable {
    private var imageData: Data?
    
    var image: Image? {
        guard let imageData = imageData, let uiImage = UIImage(data: imageData) else {
            return nil
        }
        
        return Image(uiImage: uiImage)
    }
    
    init(image: UIImage) {
        if let compressed = image.pngData()?.compressedImage(to: .init(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/2)) {
            self.imageData = compressed.pngData()
        } else {
            self.imageData = image.pngData()
        }
    }
    
    init(imageData: Data) {
        self.imageData = imageData
    }
}
