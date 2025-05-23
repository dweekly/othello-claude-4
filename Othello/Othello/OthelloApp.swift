//
//  OthelloApp.swift
//  Othello
//
//  Created by David E. Weekly on 5/22/25.
//  Copyright © 2025 Primatech Paper Co. LLC.
//

import SwiftUI

@main
struct OthelloApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        .windowResizability(.contentMinSize)
        .defaultSize(width: 700, height: 800)
        #endif
    }
}
