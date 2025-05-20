//
//  Editable.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/07.
//


import SwiftUI


extension View {
    func interactable(
        doodleObject: DoodleObject,
    ) -> some View {
        self.modifier(Interactable(
            doodleObject: doodleObject,
            angleLast: doodleObject.angleDegree,
        ))
    }
}



private struct Interactable: ViewModifier {
    @Environment(BoardViewModel.self) private var boardViewModel: BoardViewModel

    let doodleObject: DoodleObject

    @State var angleLast: CGFloat

    @State private var viewOffsetTemp: CGSize = .zero
    @State private var viewScaleTemp: CGSize = CGSize(width: 1, height: 1)

    @State private var anchor: UnitPoint = .center
    
    private let minSize: CGSize = CGSize(width: 16, height: 16)
    private let translationFactor: CGFloat = 1
    private let borderWidth: CGFloat = 1
    private let borderColor: Color = .blue
    private let cornerSize: CGSize = CGSize(width: 24, height: 24)
    
    
    func body(content: Content) -> some View {
        let interactable = self.boardViewModel.selectedObject?.id == doodleObject.id && self.boardViewModel.selectedObject?.enableEditing == false
        
        Group {
            if interactable {
                content
                    .frame(width: doodleObject.size.width, height: doodleObject.size.height)
                    .scaleEffect(viewScaleTemp, anchor: anchor)
                    .rotationEffect(.degrees(doodleObject.angleDegree))
                    .offset(viewOffsetTemp)
                    .contentShape(Rectangle())
                    .simultaneousGesture(positionGesture)
                    .simultaneousGesture(rotationGesture)
                    // top edge
                    .overlay(content: {
                        makeEdge(for: .top)
                    })
                    // bottom edge
                    .overlay(content: {
                        makeEdge(for: .bottom)
                    })
                    // leading edge
                    .overlay(content: {
                        makeEdge(for: .leading)
                    })
                    // trailing edge
                    .overlay(content: {
                        makeEdge(for: .trailing)
                    })
                    // top leading corner
                    .overlay(content: {
                        makeCorner(for: .topLeading)
                    })
                    // top trailing corner
                    .overlay(content: {
                        makeCorner(for: .topTrailing)
                    })
                    // bottom leading corner
                    .overlay(content: {
                        makeCorner(for: .bottomLeading)
                    })
                    // bottom trailing corner
                    .overlay(content: {
                        makeCorner(for: .bottomTrailing)
                    })
                    .position(doodleObject.position)
            } else {
                content
                    .frame(width: doodleObject.size.width, height: doodleObject.size.height)
                    .padding(.horizontal, doodleObject.size.width/2)
                    .padding(.vertical, doodleObject.size.height/2)
                    .rotationEffect(.degrees(doodleObject.angleDegree))
                    .position(doodleObject.position)
            }

        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged({ _ in
                    self.selectObject()
                })
        )
        .highPriorityGesture(
            TapGesture()
                .onEnded({ _ in
                    self.selectObject()
                })
        )

    }
    
    private func selectObject() {
        guard self.boardViewModel.selectedObject?.id != self.doodleObject.id else { return }
        self.boardViewModel.selectedObject = .init(objectId: doodleObject.id, enableEditing: false)
    }
    
}


extension Interactable {
    func makeCorner(for corner: UnitPoint) -> some View {
        
        let targetAnchor: UnitPoint =
        switch corner {
        case .topLeading:
            .bottomTrailing
        case .topTrailing:
            .bottomLeading
        case .bottomTrailing:
            .topLeading
        case .bottomLeading:
            .topTrailing
        default:
            .center
        }
        
        return Rectangle()
            .fill(.clear)
            .corner(size: CGSize(width: cornerSize.width/viewScaleTemp.width, height: cornerSize.height/viewScaleTemp.height), anchors: [corner], color: borderColor)
            .scaleEffect(viewScaleTemp, anchor: anchor)
            .rotationEffect(.degrees(doodleObject.angleDegree))
            .offset(viewOffsetTemp)
            .highPriorityGesture(DragGesture()
                .onChanged({ gesture in
                    onResizingGestureChanged(gesture.translation, targetAnchor: targetAnchor)
                })
                .onEnded({gesture in
                    onResizingGestureEnded(currentAnchor: targetAnchor)
                })
            )
    }
    
    
    func makeEdge(for edge: Edge) -> some View {
       
        let targetAnchor: UnitPoint =
        switch edge {
        case .top:
            .bottomTrailing
        case .bottom:
            .topLeading
        case .leading:
            .bottomTrailing
        case .trailing:
            .topLeading
        }
        
        let scaledWidth: CGFloat =
        switch edge {
        case .top:
            borderWidth/viewScaleTemp.height
        case .bottom:
            borderWidth/viewScaleTemp.height
        case .leading:
            borderWidth/viewScaleTemp.width
        case .trailing:
            borderWidth/viewScaleTemp.width
        }
        
        return Rectangle()
            .fill(.clear)
            .padding(.all, 4)
            .border(width: scaledWidth, edges: [edge], color: borderColor)
            .scaleEffect(viewScaleTemp, anchor: anchor)
            .rotationEffect(.degrees(doodleObject.angleDegree))
            .offset(viewOffsetTemp)
            .highPriorityGesture(DragGesture()
                .onChanged({ gesture in
                    onResizingGestureChanged(gesture.translation, targetAnchor: targetAnchor, edge: edge)
                })
                .onEnded({gesture in
                    onResizingGestureEnded(currentAnchor: targetAnchor)
                })
            )
    }
}

extension Interactable {
    var positionGesture: some Gesture {
        DragGesture()
            .onChanged({ gesture in
                viewOffsetTemp = gesture.translation
            })
            .onEnded({ _ in
                let previousPosition = doodleObject.position
                let newPosition = CGPoint(x: previousPosition.x + viewOffsetTemp.width, y: previousPosition.y + viewOffsetTemp.height)

                self.boardViewModel.updatePositionWithUndo(object: self.doodleObject, oldValue: previousPosition, newValue: newPosition)
                
                viewOffsetTemp = .zero
                
            })
    }
    
    var rotationGesture: some Gesture {
        RotateGesture(minimumAngleDelta: .degrees(0))
            .onChanged({ gesture in
                doodleObject.setAngle(angleLast + gesture.rotation.degrees)
            })
            .onEnded({ _ in
                let previousAngle = angleLast
                let newAngle = doodleObject.angleDegree
               
                self.boardViewModel.updateAngleWithUndo(object: self.doodleObject, oldValue: previousAngle, newValue: newAngle)

                angleLast = doodleObject.angleDegree

            })

     }
    

    private func onResizingGestureChanged(_ translation: CGSize, targetAnchor: UnitPoint, edge: Edge? = nil) {
        anchor = targetAnchor

        let signX: CGFloat = targetAnchor.x == 0 ? 1 : -1
        let signY: CGFloat = targetAnchor.y == 0 ? 1 : -1
                
        let rawChangeX = translation.width * translationFactor
        let rawChangeY = translation.height * translationFactor
        
        let angleRaw = atan2(rawChangeX, rawChangeY)

        let totalChange = sqrt(pow(rawChangeX, 2) + pow(rawChangeY, 2))
    
        var actualChangeX = totalChange * sin(angleRaw + angleLast*(.pi)/180)
        var actualChangeY = totalChange * cos(angleRaw + angleLast*(.pi)/180)
        
        switch edge {
        case .top:
            actualChangeX = 0
        case .bottom:
            actualChangeX = 0
        case .leading:
            actualChangeY = 0
        case .trailing:
            actualChangeY = 0
        default:
            break
        }
    
        let newHeight = max(minSize.height, doodleObject.size.height + signY * actualChangeY)
        let newWidth = max(minSize.width, doodleObject.size.width + signX * actualChangeX)
        
        viewScaleTemp.height = newHeight / doodleObject.size.height
        viewScaleTemp.width = newWidth / doodleObject.size.width
    }
    
    
    private func onResizingGestureEnded(currentAnchor: UnitPoint) {
        anchor = .center
        
        let signX: CGFloat = currentAnchor.x == 0 ? -1 : 1
        let signY: CGFloat = currentAnchor.y == 0 ? -1 : 1
        
        let rawChangeX = signX * doodleObject.size.width * (1-viewScaleTemp.width)
        let rawChangeY = signY * doodleObject.size.height * (1-viewScaleTemp.height)
        
        let angleRaw = atan2(rawChangeX, rawChangeY)

        
        let totalChange = sqrt(pow(rawChangeX, 2) + pow(rawChangeY, 2))
        let actualChangeX = totalChange * sin(angleRaw - angleLast*(.pi)/180)/2
        let actualChangeY = totalChange * cos(angleRaw - angleLast*(.pi)/180)/2
        
        self.boardViewModel.updateSizeWithUndo(
            object: doodleObject,
            oldValue: (doodleObject.size, doodleObject.position),
            newValue: (
                CGSize(width: doodleObject.size.width * viewScaleTemp.width, height: doodleObject.size.height * viewScaleTemp.height),
                CGPoint(x: doodleObject.position.x + actualChangeX, y: doodleObject.position.y + actualChangeY)
        ))

        
        viewScaleTemp.width = 1
        viewScaleTemp.height = 1
    }
    
}




private let model = DoodleModel.testModel

private struct EditableTestView: View {
    var doodleObject: DoodleObject {
        return .drawing(model.drawings.first!)
    }
    
    var body: some View {

        if case .drawing(let drawingModel) = doodleObject {
            ZStack {
                let image = drawingModel.drawing.image(from: drawingModel.drawing.bounds, scale: DoodleModel.testModel.previousZoomScale)

                Image(uiImage: image)
                    .renderingMode(.original)
                    .resizable()
                    .interactable(doodleObject: doodleObject)
            }
        }
    }
}



#Preview {
    EditableTestView()
        .environment(BoardViewModel(doodleModel: model))
}
