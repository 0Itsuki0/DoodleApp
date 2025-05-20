//
//  LinkObject.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/14.
//

import SwiftUI

struct LinkObject: Codable {
    var link: String
    
    var title: String?

    private var imageData: Data?

    var image: Image? {
        guard let imageData = imageData, let uiImage = UIImage(data: imageData) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }
    
    
    init(link: String, image: UIImage?, title: String?) {
        self.link = link
        self.imageData = image?.pngData()
        self.title = title
    }
    
    init(link: String, imageData: Data?, title: String?) {
        self.link = link
        self.imageData = imageData
        self.title = title
    }
}
