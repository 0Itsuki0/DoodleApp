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
//        self.imageData = image.pngData()
        self.imageData = image.jpegData(compressionQuality: 0.8)
    }
    
    init(imageData: Data) {
        self.imageData = imageData
    }
}
