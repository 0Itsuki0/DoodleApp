//
//  CornerRect.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/07.
//


import SwiftUI

extension View {
    func corner(size: CGSize, anchors: [UnitPoint], color: Color) -> some View {
        overlay(CornerRect(size: size, anchors: anchors).foregroundColor(color))
    }
}

private struct CornerRect: Shape {
    var size: CGSize
    var anchors: [UnitPoint]

    func path(in rect: CGRect) -> Path {
        anchors.map { anchor -> Path in
            switch anchor {
            case .topLeading:
                return Path(.init(x: rect.minX - size.width*0.25, y: rect.minY - size.height*0.25, width: size.width, height: size.height))
            case .topTrailing:
                return Path(.init(x: rect.maxX - size.width*0.75, y: rect.minY - size.height*0.25, width: size.width, height: size.height))
            case .bottomLeading:
                return Path(.init(x: rect.minX - size.width*0.25, y: rect.maxY - size.height*0.75, width: size.width, height: size.height))
            case .bottomTrailing:
                return Path(.init(x: rect.maxX - size.width*0.75, y: rect.maxY - size.height*0.75, width: size.width, height: size.height))
            default:
                return Path(CGRect.zero)
            }
        }.reduce(into: Path()) { $0.addPath($1) }

    }
}
