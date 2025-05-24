//
//  ThumbnailCardView.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/04.
//

import SwiftUI
import SwiftData
import PencilKit

struct ThumbnailCard: View {
    @Environment(\.modelContext) private var modelContext

    let doodleModel: DoodleModel

    var selected: Bool?
    
    @State private var nameEntry: String = ""
    @State private var showRenameAlert: Bool = false
    
    @State private var thumbnailImage: UIImage? = nil

    var body: some View {
        let defaultImage = Image(systemName: "pencil.and.outline")
        let name: String = doodleModel.name
        let lastModified: Date = doodleModel.lastModified

        VStack(spacing: 0) {
            ZStack {
                if doodleModel.allObjects.isEmpty {
                    Text("Nothing added!")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else {
                    if let thumbnailImage {
                        Image(uiImage: thumbnailImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        defaultImage
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.all, 24)

                    }
                }
            }
            .overlay(alignment: .bottomLeading, content: {
                if doodleModel.isFavorite {
                    Image(systemName: "heart.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.red)
                        .frame(width: 16)
                }
            })
            .overlay(alignment: .bottomTrailing, content: {
                if let selected {
                    Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.blue)
                        .frame(width: 16)
                        .padding(.all, 2)
                        .background(Circle().stroke(.blue, lineWidth: 1))

                }
            })
            .padding(.all, 8)
            .frame(maxHeight: .infinity)
     
            VStack(alignment: .leading, content: {
                Text(name)
                    .lineLimit(1)
                    .font(.subheadline)
                    .fontWeight(.bold)
                
                Text(lastModified, format: .dateTime)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            })
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.gray.opacity(0.2))

        }
        .onAppear {
            // to avoid generating new one while editing the doodleModel
            self.thumbnailImage = doodleModel.getThumbnailImage()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white)
                .fill(.gray.opacity(0.05))
                .shadow(color: .black.opacity(0.2), radius: 2, x: 2, y: 2)

        )
        .renameAlert(doodleModel: self.doodleModel, showRenameAlert: $showRenameAlert)
        .contextMenu(menuItems: {
            MenuButton("Rename", "pencil", {
                nameEntry = doodleModel.name
                showRenameAlert = true
            })

            MenuButton(doodleModel.isFavorite ? "Unfavorite" :"Favorite", doodleModel.isFavorite ? "heart.slash" : "heart", {
                doodleModel.isFavorite.toggle()
            })
            
            MenuButton("Duplicate", "plus.square.on.square", {
                modelContext.insert(doodleModel.duplicate)
            })
            
            let transferable = ImageTransferable(generateImage: doodleModel.getThumbnailImage)
            ShareLink(item: transferable, preview: SharePreview(name, image: transferable))

            MenuButton("Delete", "trash", {
                modelContext.delete(doodleModel)
            }, role: .destructive)
        })

    }

}
#Preview {
    ThumbnailCard(doodleModel: DoodleModel.testModel, selected: true)
        .frame(width: 200, height: 200)
        .modelContainer(for: [DoodleModel.self], inMemory: true)
}
