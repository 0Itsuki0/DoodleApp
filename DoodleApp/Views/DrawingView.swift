//
//  DrawingView.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/04.
//

import SwiftUI
import PencilKit
import SwiftData


struct DrawingView: View {

    let drawingModel: DrawingModel

    @Environment(\.undoManager) private var undoManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    @Environment(\.dismiss) private var dismiss

    @State private var canUndo: Bool = false
    @State private var canRedo: Bool = false

    @State private var showTools: Bool = true

    @State private var canvasBound: CGRect = .zero
    @State private var canvasZoomScale: CGFloat = 1.0
    @State private var scrollToRect: CGRect? = nil

    @State private var nameEntry: String = ""
    @State private var showRenameAlert: Bool = false

    @State private var drawingPolicy: PKCanvasViewDrawingPolicy = .anyInput

    var body: some View {

        let isCompact = horizontalSizeClass == .compact || verticalSizeClass == .compact

        GeometryReader { proxy in
            CanvasView(
                drawingModel: drawingModel,
                drawingPolicy: $drawingPolicy,
                canUndo: $canUndo,
                canRedo: $canRedo,
                showTools: $showTools,
                zoomScale: $canvasZoomScale,
                scrollToRect: $scrollToRect,
                isCompact: isCompact
            )
            .ignoresSafeArea(.container)
            .overlay(alignment: .topTrailing, content: {
                VStack(spacing: 12) {
                    Button(action: {
                        self.canvasZoomScale = self.canvasZoomScale * 1.2
                    }, label: {
                        zoomIcon(systemName: "plus.circle.fill")
                    })
                    
                    Button(action: {
                        let heightScale = proxy.size.height / drawingModel.drawing.bounds.height
                        
                        let widthScale = proxy.size.width / drawingModel.drawing.bounds.width

                        self.canvasZoomScale = min(widthScale, heightScale) * 0.8
                        scrollToRect = drawingModel.drawing.bounds

                    }, label: {
                        zoomIcon(systemName: "square.circle.fill")
                    })
                    
                    Button(action: {
                        self.canvasZoomScale = self.canvasZoomScale * 0.8
                    }, label: {
                        zoomIcon(systemName: "minus.circle.fill")
                    })
                }
                .padding(.all, 12)
            })
            .navigationTitle(drawingModel.name)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
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
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading, content: {
                    HStack(spacing: 8) {
                        Button(action: {
                            dismiss()
                        }, label: {
                            HStack {
                                toolbarImage(systemName: "chevron.left")
                                    .fontWeight(.bold)
                                    .scaleEffect(0.8)

                                if !isCompact {
                                    Text("Drawings")
                                }
                            }
                        })
                        
                        if isCompact {
                            HStack(spacing: 8)  {
                                Button(action: {
                                    undoManager?.undo()
                                }, label: {
                                    toolbarImage(systemName: "arrow.uturn.backward.circle")
                                })
                                .disabled(!canUndo)

                                Button(action: {
                                    undoManager?.redo()
                                }, label: {
                                    toolbarImage(systemName: "arrow.uturn.forward.circle")
                                })
                                .disabled(!canRedo)

                            }
                            .padding(.leading, 8)
                        }

                    }
                })


                ToolbarItem(placement: .topBarTrailing, content: {
                    let image = Image(uiImage: drawingModel.drawing.image(from: drawingModel.drawing.bounds, scale: 1.0))

                    HStack(spacing: 8) {

                        ShareLink(item: image, preview: SharePreview(drawingModel.name, image: image), label: {
                            toolbarImage(systemName: "square.and.arrow.up")
                        })
                        .simultaneousGesture(TapGesture()
                            .onEnded({
                                showTools = false
                            }))

                        Button(action: {
                            showTools.toggle()
                        }, label: {
                            toolbarImage(systemName: "pencil.tip.crop.circle")
                        })
                        
                        Menu(content: {
                            Section {
                                MenuButton("Rename", "pencil", {
                                    nameEntry = drawingModel.name
                                    showRenameAlert = true
                                })

                                MenuButton(drawingModel.isFavorite ? "Unfavorite" :"Favorite", drawingModel.isFavorite ? "heart.slash" : "heart", {
                                    drawingModel.isFavorite.toggle()
                                })

                            }
                            
                            Section("Drawing Input") {
                                Picker(selection: $drawingPolicy, content: {
                                    Text("Apple Pencil Only")
                                        .tag(PKCanvasViewDrawingPolicy.pencilOnly)
                                    Text("Any Input")
                                        .tag(PKCanvasViewDrawingPolicy.anyInput)
                                }, label: {
                                    Text("Drawing Input")
                                })
                            }
                            

                        }, label: {
                            toolbarImage(systemName: "ellipsis.circle")
                        })

                    }

                })

            })

        }
    }
    
    
    private func toolbarImage(systemName: String) -> some View {
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
    }
    
    private func zoomIcon(systemName: String) -> some View {
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .foregroundStyle(.gray.opacity(0.3))
    }

}



#Preview {
    NavigationStack {
        DrawingView(drawingModel: DrawingModel.testModel)
            .modelContainer(for: [DrawingModel.self], inMemory: true)
    }
}
