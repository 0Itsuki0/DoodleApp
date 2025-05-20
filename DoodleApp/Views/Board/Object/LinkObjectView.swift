//
//  LinkObjectView.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/14.
//

import SwiftUI

struct LinkObjectView: View {
    @Environment(BoardViewModel.self) private var boardViewModel: BoardViewModel

    let linkObject: LinkObject
    
    
    private var url: URL? {
        URL(string: linkObject.link)
    }
    
    private var defaultTitle: String {
        url?.host() ?? linkObject.link
    }

    var body: some View {
        VStack(spacing: 0) {
            
            if let image = linkObject.image {
                image
                    .resizable()
                    .scaledToFit()
                    .padding(.all, 16)

            } else {
                Image(systemName: "safari")
                     .resizable()
                     .scaledToFit()
                     .frame(maxWidth: 48)
                     .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
    
            
            Text(linkObject.title ?? defaultTitle)
                .font(.system(size: 16))
                .fontWeight(.semibold)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.gray.opacity(0.1))
            
        }
        .foregroundStyle(.black.opacity(0.6))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(RoundedRectangle(cornerRadius: 8)
            .fill(.white)
            .fill(.gray.opacity(0.2))
        )
    }
}




private let linkObject = LinkObject(link: "https://www.google.com", image: nil, title: nil)
private let linkModel = NonDrawingModel(object: .link(linkObject), position: .init(x: 250, y: 250), size: .init(width: 200, height: 200), angleDegree: 20)

private let model = DoodleModel.init(name: "d", lastModified: Date(), isFavorite: true, showBackgroundGrid: true, previousZoomScale: 1.0, previousOffset: .zero, drawings: [], nonDrawings: [linkModel], objectOrder: [linkModel.id])

#Preview {
    
    LinkObjectView(linkObject: linkObject)
        .interactable(doodleObject: .nonDrawing(linkModel))
        .environment(BoardViewModel(doodleModel: model))

}
