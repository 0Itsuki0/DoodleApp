//
//  BoardViewZoomControl.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/24.
//

import SwiftUI


struct BoardViewZoomControl: View {
    @Environment(BoardViewModel.self) private var boardViewModel: BoardViewModel
    @Environment(\.safeAreaInsets) private var safeAreaInsets

    var body: some View {
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
                    
                    let newScale = self.getNextScale(self.boardViewModel.doodleModel.previousZoomScale)
                    self.boardViewModel.doodleModel.previousZoomScale = newScale
                    
                    
                }, label: {
                    makeZoomIcon(systemName: "plus.circle.fill")
                })
                
                Button(action: {
                    
                    let bounds = self.boardViewModel.doodleModel.bounds

                    let newScale = self.getScaleThatFit(bounds)
                    let offset = self.getOffsetForCentering(scale: newScale, bounds: bounds)

                    self.setScaleAndOffset(newScale, offset)

                }, label: {
                    makeZoomIcon(systemName: "square.circle.fill")
                })
                
                Button(action: {
                    let newScale = self.getPreviousScale(self.boardViewModel.doodleModel.previousZoomScale)
                    self.boardViewModel.doodleModel.previousZoomScale = newScale

                }, label: {
                    makeZoomIcon(systemName: "minus.circle.fill")
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

    }
    
    private func getNextScale(_ currentZoom: CGFloat) -> CGFloat {
        let firstIndex = Constants.scales.closestIndex(to: currentZoom)

        if firstIndex == Constants.scales.count - 1 {
            return currentZoom
        }
        return Constants.scales[firstIndex + 1]
    }
    
    private func getPreviousScale(_ currentZoom: CGFloat) -> CGFloat {
        let firstIndex = Constants.scales.closestIndex(to: currentZoom)
        
        if firstIndex == 0 {
            return currentZoom
        }
        
        return Constants.scales[firstIndex - 1]
    }
    
    private func getOffsetForCentering(scale: CGFloat, bounds: CGRect) -> CGPoint {
        let maxOffsetX = max(Constants.canvasSize.width * scale - UIScreen.main.bounds.width, 0)
        let maxOffsetY = max(Constants.canvasSize.height * scale - UIScreen.main.bounds.height, 0)
                            
        let offsetX = min(max((bounds.midX) * scale - UIScreen.main.bounds.width/2, 0), maxOffsetX)
        let offsetY = min(max((bounds.midY) * scale - UIScreen.main.bounds.height/2 + safeAreaInsets.top, 0), maxOffsetY)

        return CGPoint(x: offsetX, y: offsetY)
    }
    
    private func getScaleThatFit(_ bounds: CGRect) -> CGFloat {
    
        let heightScale = bounds.width / UIScreen.main.bounds.width
        let widthScale = bounds.height / UIScreen.main.bounds.height
        
        let newScale = min(max(1/max(widthScale, heightScale) * 0.8, Constants.minScale), Constants.maxScale)
        
        return newScale
    }
    
    
    private func setScaleAndOffset(_ scale: CGFloat, _ offset: CGPoint) {
        withAnimation(.linear(duration: 0.0), {
            self.boardViewModel.doodleModel.previousZoomScale = scale
        }, completion: {
            // offset has to be set after zoom finishes
            self.boardViewModel.doodleModel.previousOffset = .init(x: offset.x, y: offset.y)
        })

    }


    private func makeZoomIcon(systemName: String) -> some View {
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
    var testModel: DoodleModel {

        let imageObject = ImageObject(image: UIImage(systemName: "heart.fill")!)
        let imageModel = NonDrawingModel(object: .image(imageObject), position: .init(x: Constants.canvasSize.width-3000, y:  Constants.canvasSize.height-3000), size: .init(width: 1000, height: 1000), angleDegree: 20)
        
        let linkObject = LinkObject(link: "https://www.google.com", image: nil, title: nil)
        let linkModel = NonDrawingModel(object: .link(linkObject), position: .init(x: Constants.canvasSize.width-3000, y:  Constants.canvasSize.height-3000), size: .init(width: 200, height: 200), angleDegree: 20)

        return DoodleModel(name: "Test", lastModified: Date(), isFavorite: true, showBackgroundGrid: true, previousZoomScale: 0.75, imageData: nil, previousOffset: .init(x: Constants.canvasSize.width-400, y:  Constants.canvasSize.height-600), drawings: [], nonDrawings: [imageModel, linkModel], objectOrder: [imageModel.id, linkModel.id])
    }

    NavigationStack {
        BoardView(doodleModel: testModel)
            .modelContainer(for: [DoodleModel.self], inMemory: true)
    }
}
