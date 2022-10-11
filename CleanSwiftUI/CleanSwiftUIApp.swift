//
//  CleanSwiftUIApp.swift
//  CleanSwiftUI
//
//  Created by Rob Broadwell on 10/11/22.
//

import SwiftUI

@main
struct CleanSwiftUIApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
