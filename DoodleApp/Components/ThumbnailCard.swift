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

    let drawingModel: DrawingModel

    var selected: Bool?
    
    @State private var nameEntry: String = ""
    @State private var showRenameAlert: Bool = false

    var body: some View {
        let image = Image(uiImage: drawingModel.drawing.image(from: drawingModel.drawing.bounds, scale: 1.0))
        let name: String = drawingModel.name
        let lastModified: Date = drawingModel.lastModified

        VStack(spacing: 0) {
            ZStack {
                if drawingModel.drawing.strokes.isEmpty {
                    Text("No doodles yet!")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .overlay(alignment: .bottomLeading, content: {
                if drawingModel.isFavorite {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.white)
                .fill(.gray.opacity(0.05))
                .shadow(color: .black.opacity(0.2), radius: 2, x: 2, y: 2)

        )
        .alert("Rename Drawing", isPresented: $showRenameAlert) {
            TextField("", text: $nameEntry)

            Button(action: {
                showRenameAlert = false
            }, label: {
                Text("Cancel")
            })
            Button(action: {
                drawingModel.name = nameEntry.isEmpty ? DrawingModel.defaultName: nameEntry
                showRenameAlert = false
            }, label: {
                Text("OK")
            })
        } message: {
            Text("Enter a new name for this drawing.")
        }
        .contextMenu(menuItems: {
            MenuButton("Rename", "pencil", {
                nameEntry = drawingModel.name
                showRenameAlert = true
            })

            MenuButton(drawingModel.isFavorite ? "Unfavorite" :"Favorite", drawingModel.isFavorite ? "heart.slash" : "heart", {
                drawingModel.isFavorite.toggle()
            })
            
            MenuButton("Duplicate", "plus.square.on.square", {
                modelContext.insert(drawingModel.duplicate)
            })
            
            ShareLink(item: image, preview: SharePreview(name, image: image))

            MenuButton("Delete", "trash", {
                modelContext.delete(drawingModel)
            }, role: .destructive)
        })

    }

}
#Preview {

    ThumbnailCard(drawingModel: DrawingModel.testModel, selected: true)
        .frame(width: 200, height: 200)
        .modelContainer(for: [DrawingModel.self], inMemory: true)
}
