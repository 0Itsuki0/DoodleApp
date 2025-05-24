//
//  EmptyScrollView.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/10.
//

import SwiftUI
import PencilKit
import SwiftData


struct EmptyScrollView: UIViewRepresentable {
    @Environment(BoardViewModel.self) private var boardViewModel: BoardViewModel

    private var isScrollingEnabled: Bool {
        !boardViewModel.allowCanvasHitTest
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        let emptyView = UIView()
        emptyView.frame = .init(origin: scrollView.frame.origin, size: Constants.canvasSize)
        scrollView.addSubview(emptyView)
        
        scrollView.delegate = context.coordinator
        
        scrollView.isOpaque = false

        scrollView.contentSize = Constants.canvasSize
        scrollView.contentOffset = boardViewModel.doodleModel.previousOffset
        
        /// for zooming
        scrollView.minimumZoomScale = Constants.minScale
        scrollView.maximumZoomScale = Constants.maxScale
        scrollView.zoomScale = boardViewModel.doodleModel.previousZoomScale
        
        scrollView.isUserInteractionEnabled = isScrollingEnabled
        
        return scrollView
    }


    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        scrollView.isUserInteractionEnabled = isScrollingEnabled

        if boardViewModel.doodleModel.previousOffset != scrollView.contentOffset {
            scrollView.contentOffset = boardViewModel.doodleModel.previousOffset
        }
        
        if boardViewModel.doodleModel.previousZoomScale != scrollView.zoomScale {
            scrollView.zoomScale = boardViewModel.doodleModel.previousZoomScale
        }

    }

}


extension EmptyScrollView {
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: EmptyScrollView

        init(_ parent: EmptyScrollView) {
            self.parent = parent
        }
        
        // MARK: UIScrollViewDelegate
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return scrollView.subviews.first
        }
        

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            self.updateZoomOffset(scrollView)
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            self.updateZoomOffset(scrollView)
        }
        
        private func updateZoomOffset(_ scrollView: UIScrollView) {
            guard self.parent.isScrollingEnabled else { return }
            DispatchQueue.main.async {
                self.parent.boardViewModel.doodleModel.previousZoomScale = scrollView.zoomScale
                self.parent.boardViewModel.doodleModel.previousOffset = scrollView.contentOffset
            }
        }
    }
}
