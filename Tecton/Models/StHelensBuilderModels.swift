import Foundation
import SwiftUI

struct StHelensLayer: Identifiable, Equatable {
    var id = UUID()
    var name: String
    var imageAsset: String // Corresponds to PZH1-4 image assets
    var question: String
    var options: [String]
    var correctIndex: Int
    var fact: String
    
    static func == (lhs: StHelensLayer, rhs: StHelensLayer) -> Bool {
        lhs.id == rhs.id
    }
}

struct StHelensBuilderQuiz {
    var layers: [StHelensLayer]
}

class StHelensQuizManager: ObservableObject {
    @Published var quiz: StHelensBuilderQuiz?
    @Published var currentIndex = 0
    @Published var answeredCorrectly: [String] = []
    @Published var showingFact = false
    @Published var currentFact = ""
    
    func loadQuiz() {
        // Create a Mount St. Helens volcano quiz with 4 layers
        let layers = [
            StHelensLayer(
                name: "Base",
                imageAsset: "PZH1",
                question: "When did Mount St. Helens have its major eruption?",
                options: ["1970", "1980", "1990", "2000"],
                correctIndex: 1,
                fact: "The 1980 eruption of Mount St. Helens was the deadliest and most economically destructive volcanic event in U.S. history."
            ),
            StHelensLayer(
                name: "Mid-Section",
                imageAsset: "PZH2",
                question: "Which side of Mount St. Helens collapsed during the 1980 eruption?",
                options: ["North", "South", "East", "West"],
                correctIndex: 0,
                fact: "The north face of the mountain collapsed in a massive landslide, triggering a lateral blast that flattened everything within 230 square miles."
            ),
            StHelensLayer(
                name: "Crater",
                imageAsset: "PZH3",
                question: "By how much did Mount St. Helens' height decrease after the 1980 eruption?",
                options: ["400 feet", "1,300 feet", "3,000 feet", "5,000 feet"],
                correctIndex: 1,
                fact: "The volcano lost about 1,300 feet of elevation when the top was blown off during the eruption."
            ),
            StHelensLayer(
                name: "Dome",
                imageAsset: "PZH4",
                question: "What formed inside the crater of Mount St. Helens after the eruption?",
                options: ["A lake", "A lava dome", "A forest", "A new peak"],
                correctIndex: 1,
                fact: "A lava dome began forming in the crater after the eruption, and it continues to grow as new magma reaches the surface."
            )
        ]
        
        quiz = StHelensBuilderQuiz(layers: layers)
    }
    
    func submitAnswer(_ selectedIndex: Int) {
        guard let current = quiz?.layers[safe: currentIndex] else { return }
        
        if selectedIndex == current.correctIndex {
            // These updates will be animated in the view
            answeredCorrectly.append(current.imageAsset)
            currentFact = current.fact
            showingFact = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                // Hide the fact after a delay
                self.showingFact = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // Move to next question after another short delay
                    self.currentIndex += 1
                }
            }
        }
    }
    
    func resetQuiz() {
        currentIndex = 0
        answeredCorrectly = []
        showingFact = false
    }
} 