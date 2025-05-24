//
//  Data+Extensions.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/21.
//

import SwiftUI

private extension CGSize {
    var pngBytes: Int {
        Int(width * height * 9)
    }
    
    var jpegBytes: Int {
        Int(width * height * 3)
    }
}

extension Data {

    func compressedImage(to size: CGSize?) -> UIImage? {
        guard let size = size else {
            return UIImage(data: self)
        }
        
        if self.count < size.pngBytes {
            return UIImage(data: self)
        }
        
        let scale = UIScreen.main.scale
        let options: [CFString: Any] = [
            kCGImageSourceShouldCache : false,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: Swift.max(size.width, size.height) * scale
        ]
        
        guard
            let src = CGImageSourceCreateWithData(self as CFData, nil),
            let cgImage = CGImageSourceCreateThumbnailAtIndex(src, 0, options as CFDictionary)
        else { return nil }

        return UIImage(cgImage: cgImage)
    }
}
