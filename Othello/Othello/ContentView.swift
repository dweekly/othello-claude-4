//
//  ContentView.swift
//  Othello
//
//  Created by David E. Weekly on 5/22/25.
//  Copyright © 2025 Primatech Paper Co. LLC.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
#if os(iOS)
            GameView()
                .navigationTitle("Othello")
                .navigationBarTitleDisplayMode(.large)
#else
            GameView()
                .navigationTitle("Othello")
#endif
        }
    }
}

#Preview {
    ContentView()
}
