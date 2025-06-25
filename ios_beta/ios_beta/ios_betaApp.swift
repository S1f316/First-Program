//
//  ios_betaApp.swift
//  ios_beta
//
//  Created by S1F on 25/06/2025.
//

import SwiftUI

@main
struct ios_betaApp: App {
    @State private var isAuthenticated = false
    
    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                ContentView()
            } else {
                LoginView(isAuthenticated: $isAuthenticated)
            }
        }
    }
}
