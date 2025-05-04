//
//  CanvasView.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/04.
//

import SwiftUI
import PencilKit
import SwiftData


struct CanvasView: UIViewRepresentable {

    let drawingModel: DrawingModel
    
    @Binding var drawingPolicy: PKCanvasViewDrawingPolicy

    @Binding var canUndo: Bool
    @Binding var canRedo: Bool
    @Binding var showTools: Bool
    @Binding var zoomScale: CGFloat
    @Binding var scrollToRect: CGRect?

    var isCompact: Bool

    @Environment(\.safeAreaInsets) private var safeAreaInsets

    /// **NOTE**: the tool picker initialization has to be outside of the `makeUIView` function for the tool picker to show up
    private let toolPicker = PKToolPicker()

    func makeUIView(context: Context) -> PKCanvasView {
        let canvasView = PKCanvasView()
        canvasView.delegate = context.coordinator
        
        canvasView.drawing = drawingModel.drawing
        canvasView.drawingPolicy = drawingPolicy
        
        canvasView.backgroundColor = .gray.withAlphaComponent(0.1)

        /// for scrolling(panning) using two-finger pan gesture (If drawingPolicy is pencilOnly, scroll with only one finger.), set a `large` canvas content size for the drawing area
        canvasView.contentSize = CGSize(width: 1000, height: 2000)
        
        /// for zooming
        canvasView.minimumZoomScale = .zero
        canvasView.maximumZoomScale = 10
        canvasView.zoomScale = zoomScale

        updateToolPicker(canvasView)

        updateCanvasLayout(canvasView)

        return canvasView
    }


    func updateUIView(_ canvasView: PKCanvasView, context: Context) {
        canvasView.zoomScale = zoomScale
        canvasView.drawingPolicy = drawingPolicy
        
        if let scrollToRect {
            let targetRect = CGRect(origin: scrollToRect.origin, size: CGSize(width: scrollToRect.width * zoomScale, height: scrollToRect.height * zoomScale))
            canvasView.scrollRectToVisible(targetRect, animated: false)
            DispatchQueue.main.async(execute: {
                self.scrollToRect = nil
            })
        }

        updateToolPicker(canvasView)

        updateCanvasLayout(canvasView)

        if drawingModel.drawing != canvasView.drawing {
            canvasView.drawing = drawingModel.drawing
        }
    }
    
    private func updateToolPicker(_ canvasView: PKCanvasView) {
        toolPicker.setVisible(showTools, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        toolPicker.showsDrawingPolicyControls = false
        if showTools {
            canvasView.becomeFirstResponder()
        } else {
            canvasView.resignFirstResponder()
        }
    }

    private func updateCanvasLayout(_ canvasView: PKCanvasView) {
        if isCompact && showTools {
            let obscuredFrame = toolPicker.frameObscured(in: canvasView)
            canvasView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: obscuredFrame.height - safeAreaInsets.bottom, right: 0)

        } else {
            canvasView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -safeAreaInsets.bottom, right: 0)
        }

        canvasView.horizontalScrollIndicatorInsets = canvasView.contentInset
        canvasView.verticalScrollIndicatorInsets = canvasView.contentInset
    }

}


extension CanvasView {
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }


    class Coordinator: NSObject, PKCanvasViewDelegate{
        var parent: CanvasView

        init(_ parent: CanvasView) {
            self.parent = parent
        }

        // MARK: PKCanvasViewDelegate
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {

            DispatchQueue.main.async {
                /// update undo and redo state
                self.parent.canUndo = canvasView.undoManager?.canUndo ?? false
                self.parent.canRedo = canvasView.undoManager?.canRedo ?? false

                /// update drawing
                self.parent.drawingModel.drawing = canvasView.drawing
                self.parent.drawingModel.lastModified = Date()

            }
        }


        // MARK: UIScrollViewDelegate
        // PKCanvasViewDelegate is a subclass of UIScrollViewDelegate
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            DispatchQueue.main.async {
                self.parent.zoomScale = scrollView.zoomScale
            }
        }

        
//        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
//            <#code#>
//        }
    }
}

