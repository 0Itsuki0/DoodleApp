//
//  ThumbnailListView.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/04.
//

import SwiftUI
import PencilKit
import SwiftData


struct ThumbnailListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DoodleModel.lastModified, order: .reverse, animation: .smooth) var drawingModels: [DoodleModel]

    @State private var searchText: String = ""
    @State private var destinationModel: DoodleModel? = nil
    
    @State private var isSelecting: Bool = false
    @State private var selectedModels: Set<DoodleModel> = Set()

    var body: some View {
        GeometryReader { proxy in
            let filteredDrawings = searchText.isEmpty ? drawingModels : drawingModels.filter({ $0.name.localizedCaseInsensitiveContains(searchText)})
            
            ScrollView {
                let width = proxy.size.width / 2.3
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: width, maximum: width), spacing: 16)], spacing: 24, content: {

                    ForEach(filteredDrawings) { drawingModel in

                        Button(action: {
                            if isSelecting {
                                if selectedModels.contains(drawingModel) {
                                    selectedModels.remove(drawingModel)
                                } else {
                                    selectedModels.insert(drawingModel)
                                }
                            } else {
                                destinationModel = drawingModel
                            }
                        }, label: {
                            ThumbnailCard(doodleModel: drawingModel, selected: isSelecting ? selectedModels.contains(drawingModel) : nil)
                                .frame(width: width, height: width)
                        })
                    }
                })
                .buttonStyle(.plain)
                .searchable(text: $searchText, placement: .toolbar)
            }
            .navigationTitle("All Doodles")
            .navigationDestination(item: $destinationModel, destination: { drawingModel in
                BoardView(doodleModel: drawingModel)
            })
            .toolbar(content: {
                if !isSelecting {
                    ToolbarItem(placement: .topBarTrailing, content: {
                        HStack {
                            Button(action: {
                                let new = DoodleModel()
                                modelContext.insert(new)
                                destinationModel = new
                            }, label: {
                                Image(systemName: "square.and.pencil")
                            })
                            
                            
                            Button(action: {
                                isSelecting = true
                            }, label: {
                                Image(systemName: "checkmark.circle")
                            })
                        }
                    })
                } else {
                    ToolbarItem(placement: .topBarLeading, content: {

                        if selectedModels.count == drawingModels.count {
                            Button(action: {
                                selectedModels = Set()
                            }, label: {
                                Text("Deselect All")
                            })
                        } else {
                            Button(action: {
                                selectedModels = Set(drawingModels)
                            }, label: {
                                Text("Select All")
                            })
                        }
                    })
                    
                    ToolbarItem(placement: .topBarTrailing, content: {

                        Button(action: {
                            isSelecting = false
                        }, label: {
                            Text("Done")
                        })
                    })
                    
                    
                    ToolbarItem(placement: .bottomBar, content: {
                        HStack {
                            Button(action: {
                                for model in selectedModels {
                                    modelContext.insert(model.duplicate)
                                }
                            }, label: {
                                Text("Duplicate")
                            })
                            
                            Spacer()
                            
                            Button(action: {
                                for model in selectedModels {
                                    modelContext.delete(model)
                                    selectedModels.remove(model)
                                }
                            }, label: {
                                Text("Delete")
                            })
                        }
                    })

                }

            })
            .overlay(content: {
                if filteredDrawings.isEmpty && !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    ContentUnavailableView("No Results for \"\(searchText)\"", systemImage: "magnifyingglass")
                } else if drawingModels.isEmpty {
                    ContentUnavailableView("No Doodles", systemImage: "rectangle.fill.on.rectangle.fill")
                }
            })
        }
        
    }
}


#Preview {
    NavigationStack {
        
        ThumbnailListView()
            .modelContainer(for: [DoodleModel.self], inMemory: true)
    }
}
