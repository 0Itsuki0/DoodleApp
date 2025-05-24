//
//  CanvasView.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/04.
//

import SwiftUI
import PencilKit
import SwiftData


struct DrawingCanvasView: UIViewRepresentable {
    @Environment(BoardViewModel.self) private var boardViewModel: BoardViewModel

    let drawingModel: DrawingModel
    var isCompact: Bool
    
    private var isDrawingEnabled: Bool {
        guard let selectedObject = boardViewModel.selectedObject else { return false }
        guard selectedObject.id == drawingModel.id else { return false }
        return selectedObject.enableEditing
    }

    @Environment(\.safeAreaInsets) private var safeAreaInsets

    /// **NOTE**: the tool picker initialization has to be outside of the `makeUIView` function for the tool picker to show up
    private let toolPicker = PKToolPicker()

    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.delegate = context.coordinator
        
        canvasView.drawing = drawingModel.drawing
        canvasView.drawingPolicy = boardViewModel.drawingPolicy
        
        canvasView.isOpaque = false

        canvasView.contentSize = Constants.canvasSize
        canvasView.contentOffset = boardViewModel.doodleModel.previousOffset
        
        /// for zooming
        canvasView.minimumZoomScale = Constants.minScale
        canvasView.maximumZoomScale = Constants.maxScale
        canvasView.zoomScale = boardViewModel.doodleModel.previousZoomScale
        
        canvasView.isUserInteractionEnabled = self.isDrawingEnabled

        updateToolPicker(canvasView)
        setUpCanvasLayout(canvasView)

        return canvasView
    }


    func updateUIView(_ canvasView: PKCanvasView, context: Context) {
        canvasView.drawingPolicy = boardViewModel.drawingPolicy
        canvasView.isUserInteractionEnabled = self.isDrawingEnabled
        
        if self.boardViewModel.doodleModel.previousOffset != canvasView.contentOffset {
            canvasView.contentOffset = self.boardViewModel.doodleModel.previousOffset
        }
        
        if self.boardViewModel.doodleModel.previousZoomScale != canvasView.zoomScale {
            canvasView.zoomScale = self.boardViewModel.doodleModel.previousZoomScale
        }
        
        updateToolPicker(canvasView)

        if drawingModel.drawing != canvasView.drawing {
            canvasView.drawing = drawingModel.drawing
        }
    }
    
    private func updateToolPicker(_ canvasView: PKCanvasView) {
        toolPicker.setVisible(self.isDrawingEnabled, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        toolPicker.showsDrawingPolicyControls = false
        if self.isDrawingEnabled {
            canvasView.becomeFirstResponder()
        } else {
            canvasView.resignFirstResponder()
        }
    }

    private func setUpCanvasLayout(_ canvasView: PKCanvasView) {
        if isCompact {
            let obscuredFrame = toolPicker.frameObscured(in: canvasView)
            canvasView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: obscuredFrame.height - safeAreaInsets.bottom, right: 0)

        } else {
            canvasView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -safeAreaInsets.bottom, right: 0)
        }

        canvasView.horizontalScrollIndicatorInsets = canvasView.contentInset
        canvasView.verticalScrollIndicatorInsets = canvasView.contentInset
    }

}


extension DrawingCanvasView {
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: DrawingCanvasView
        private var isUserChange = false

        init(_ parent: DrawingCanvasView) {
            self.parent = parent
        }

        // MARK: PKCanvasViewDelegate
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            self.parent.boardViewModel.updateDrawing(drawingModel: self.parent.drawingModel, canvasView: canvasView)
        }
        
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            self.updateZoomOffset(scrollView)
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            self.updateZoomOffset(scrollView)
        }
        
        private func updateZoomOffset(_ scrollView: UIScrollView) {
            guard self.parent.isDrawingEnabled else { return }
            DispatchQueue.main.async {
                self.parent.boardViewModel.doodleModel.previousZoomScale = scrollView.zoomScale
                self.parent.boardViewModel.doodleModel.previousOffset = scrollView.contentOffset
            }
        }
    }
}



#Preview {
    NavigationStack {
        BoardView(doodleModel: DoodleModel.testModel)
            .modelContainer(for: [DoodleModel.self], inMemory: true)
    }
}
