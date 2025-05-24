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
            BoardViewZoomControl()
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

}



#Preview {
    NavigationStack {
        BoardView(doodleModel: DoodleModel.testModel)
            .modelContainer(for: [DoodleModel.self], inMemory: true)
    }
}
