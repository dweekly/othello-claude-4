import SwiftUI

struct HowToPlayView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    introSection
                    
                    objectiveSection
                    
                    rulesSection
                    
                    strategySection
                }
                .padding()
            }
            .navigationTitle("How to Play")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var introSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Welcome to Othello!")
                .font(.title2)
                .bold()
            
            Text("Also known as Reversi, Othello is a classic strategy board game for two players.")
                .foregroundColor(.secondary)
        }
    }
    
    private var objectiveSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Objective", systemImage: "target")
                .font(.headline)
            
            Text("Have the majority of discs on the board showing your color when the game ends.")
                .padding(.leading, 28)
        }
    }
    
    private var rulesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Rules", systemImage: "list.bullet")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                ruleItem(
                    number: "1",
                    text: "The game begins with 4 discs placed in the center: 2 black and 2 white in a diagonal pattern."
                )
                
                ruleItem(
                    number: "2",
                    text: "Black always moves first. Players take turns placing discs on empty squares."
                )
                
                ruleItem(
                    number: "3",
                    text: "A valid move must outflank at least one opponent disc. This means placing your disc so that one or more of your opponent's discs are between your new disc and another disc of your color."
                )
                
                ruleItem(
                    number: "4",
                    text: "All outflanked discs are flipped to your color. Flips can happen horizontally, vertically, or diagonally."
                )
                
                ruleItem(
                    number: "5",
                    text: "If a player cannot make a valid move, they must pass. If neither player can move, the game ends."
                )
                
                ruleItem(
                    number: "6",
                    text: "The game also ends when the board is full. The player with the most discs wins!"
                )
            }
            .padding(.leading, 28)
        }
    }
    
    private var strategySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Strategy Tips", systemImage: "lightbulb")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                strategyTip(
                    title: "Corners are Key",
                    description: "Corner squares can't be flipped once captured. Try to control them!"
                )
                
                strategyTip(
                    title: "Avoid Early Edges",
                    description: "Placing discs on edges early can give your opponent access to corners."
                )
                
                strategyTip(
                    title: "Minimize Discs Early",
                    description: "Having fewer discs early gives you more move options later."
                )
                
                strategyTip(
                    title: "Control the Center",
                    description: "Central positions often provide more strategic flexibility."
                )
            }
            .padding(.leading, 28)
        }
    }
    
    private func ruleItem(number: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(number)
                .font(.callout)
                .fontWeight(.semibold)
                .frame(width: 20)
                .foregroundColor(.accentColor)
            
            Text(text)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private func strategyTip(title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.callout)
                .fontWeight(.semibold)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    HowToPlayView()
}