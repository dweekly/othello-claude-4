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
