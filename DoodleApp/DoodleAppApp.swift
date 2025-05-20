//
//  DoodleAppApp.swift
//  DoodleApp
//
//  Created by Itsuki on 2025/05/04.
//

import SwiftUI

@main
struct DoodleAppApp: App {
    var body: some Scene {
        WindowGroup {

            ContentView()
                .modelContainer(for: [DoodleModel.self])
//                .onAppear {
//                    print("URL.applicationSupportDirectory: \(URL.applicationSupportDirectory.path(percentEncoded: false))")
//                }
        }
    }
}
