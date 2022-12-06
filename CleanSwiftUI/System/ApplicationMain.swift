//
//  CSApp.swift
//  CleanSwiftUI
//
//  Created by Rob Broadwell on 12/6/22.
//

import SwiftUI

@main
struct ApplicationMain: App {
    @UIApplicationDelegateAdaptor var delegate: AppDelegate
    
    let environment = AppEnvironment.bootstrap()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ContentView.ViewModel(container: environment.container))
        }
    }
}
