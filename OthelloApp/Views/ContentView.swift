//
//  Othello iOS App
//  Copyright © 2025 Primatech Paper Co. LLC.
//
import SwiftUI

public struct ContentView: View {
    public init() {}
    public var body: some View {
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
