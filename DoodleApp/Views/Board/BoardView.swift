//
//  DrawingView.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/04.
//

import SwiftUI
import PencilKit
import SwiftData


extension BoardView {
    init(doodleModel: DoodleModel) {
        self.boardViewModel = .init(doodleModel: doodleModel)
    }
}


struct BoardView: View {
    @State var boardViewModel: BoardViewModel

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass



    var body: some View {

        let isCompact = horizontalSizeClass == .compact || verticalSizeClass == .compact

        ZStack {
            BackgroundView()
            
            ObjectContentView()
                .allowsHitTesting(!self.boardViewModel.allowCanvasHitTest)


            if let selectedObject = boardViewModel.selectedObject, selectedObject.enableEditing, let drawingModel = self.boardViewModel.doodleModel.drawings.first(where: {$0.id == selectedObject.id}) {
                    DrawingCanvasView(
                        drawingModel: drawingModel,
                        isCompact: isCompact,
                    )
                    .allowsHitTesting(boardViewModel.allowCanvasHitTest)
            }
            
        }
        .onTapGesture {
            self.boardViewModel.selectedObject = nil
        }
        .clipShape(Rectangle())
        .ignoresSafeArea(.container, edges: .bottom)
        .overlay(alignment: .topTrailing, content: {
            HStack(alignment: .top, spacing: 12, content: {
                if self.boardViewModel.showZoom {
                    Text("\(Int(self.boardViewModel.doodleModel.previousZoomScale*100))%")
                        .font(.system(size: 12))
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(4)
                        .background(RoundedRectangle(cornerRadius: 8).fill(.white).fill(.gray.opacity(0.8)))
                }
                
                VStack(spacing: 12) {
                    Button(action: {
                        self.boardViewModel.doodleModel.previousZoomScale = self.getNextZoom(self.boardViewModel.doodleModel.previousZoomScale)
                    }, label: {
                        zoomIcon(systemName: "plus.circle.fill")
                    })
                    
//                        Button(action: {
//                            doodleModel.previousZoomScale = self.getZoomForFit(viewSize: proxy.size, drawingSize: doodleModel.drawing.bounds.size)
//
//                            scrollToRect = doodleModel.drawing.bounds
//
//                        }, label: {
//                            zoomIcon(systemName: "square.circle.fill")
//                        })
                    
                    Button(action: {
                        self.boardViewModel.doodleModel.previousZoomScale = self.getPreviousZoom(self.boardViewModel.doodleModel.previousZoomScale)

                    }, label: {
                        zoomIcon(systemName: "minus.circle.fill")
                    })
                }

                
            })
            .padding(.all, 12)
            .onChange(of: self.boardViewModel.doodleModel.previousZoomScale, {
                self.boardViewModel.showZoom = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self.boardViewModel.showZoom = false
                })
            })
        })
        .navigationTitle(self.boardViewModel.doodleModel.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .renameAlert(
            doodleModel: self.boardViewModel.doodleModel,
            showRenameAlert: $boardViewModel.showRenameAlert
        )
        .linkEntryAlert(
            showLinkEntryAlert: $boardViewModel.showLinkEntryAlert,
            onConfirm: boardViewModel.onLinkEntered,
            currentLink: boardViewModel.selectedLinkObject?.link
        )
        .photosPicker(
            showPicker: $boardViewModel.showPhotosPicker,
            onPickerItemChange: boardViewModel.onImagePicked,
            allowMultiSelection: !boardViewModel.isSelectionImage
        )
        .imageImporter(showImporter: $boardViewModel.showImageImporter, onImageImportComplete: boardViewModel.onImageImportComplete, allowMultiSelection: !boardViewModel.isSelectionImage
        )
        .toolbar(content: {
            BoardViewTopBar(
                isCompact: isCompact
            )
        })
        .overlay(alignment: .bottom, content: {
            BoardViewBottomBar()
        })
        .environment(self.boardViewModel)
    }

    
    private func getNextZoom(_ currentZoom: CGFloat) -> CGFloat {
        guard let firstIndex = Constants.zooms.firstIndex(of: currentZoom) else {
            return min(currentZoom + 0.1, Constants.maxZoom)
        }
        if firstIndex == Constants.zooms.count - 1 {
            return currentZoom
        }
        return Constants.zooms[firstIndex + 1]
    }
    
    private func getPreviousZoom(_ currentZoom: CGFloat) -> CGFloat {
        guard let firstIndex = Constants.zooms.firstIndex(of: currentZoom) else {
            return max(currentZoom - 0.1, Constants.minZoom)
        }
        
        if firstIndex == 0 {
            return currentZoom
        }
        
        return Constants.zooms[firstIndex - 1]
    }
    
    
    private func getZoomForFit(viewSize: CGSize, drawingSize: CGSize) -> CGFloat {
        let heightScale = viewSize.height / drawingSize.height
        let widthScale = viewSize.width / drawingSize.width

        return min(max(min(widthScale, heightScale) * 0.8, Constants.minZoom), Constants.maxZoom)
    }
    

    private func zoomIcon(systemName: String) -> some View {
        Image(systemName: systemName)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .background(.white)
            .foregroundStyle(.gray.opacity(0.3))
            .clipShape(Circle())

    }

}



#Preview {
    NavigationStack {
        BoardView(doodleModel: DoodleModel.testModel)
            .modelContainer(for: [DoodleModel.self], inMemory: true)
    }
}
