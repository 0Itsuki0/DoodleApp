//
//  Constants.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/07.
//

import SwiftUI

final class Constants {
    static let defaultDoodleName: String = "Untitled"

    static let zooms: [CGFloat] = [0.02, 0.03, 0.05, 0.1, 0.15, 0.2, 0.33, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 2.5, 3.0, 4.0]
    static let minZoom: CGFloat = 0.02
    static let maxZoom: CGFloat = 4.0
    
    static let canvasSize: CGSize = CGSize(width: UIScreen.main.bounds.width / minZoom, height: UIScreen.main.bounds.height / minZoom)
    
    static let initialImageWidth: CGFloat = 200
    static let initialLinkSize: CGSize = .init(width: 200, height: 150)

}
