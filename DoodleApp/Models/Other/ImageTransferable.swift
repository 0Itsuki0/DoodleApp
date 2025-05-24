//
//  ImageTransferable.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/24.
//

import SwiftUI

struct ImageTransferable: Transferable {
    var generateImage: () async -> UIImage?
    
    enum Error: Swift.Error {
        case generateImageFailed
        case getImageDataFailed
    }
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { _self in

            guard let image = await _self.generateImage() else {
                throw Error.generateImageFailed
            }
            guard let data = image.pngData() else {
                throw Error.getImageDataFailed
            }
           
            return data
        }
    }
}

