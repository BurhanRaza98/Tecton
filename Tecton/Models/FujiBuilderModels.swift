import Foundation
import SwiftUI

struct FujiLayer: Identifiable, Equatable {
    var id = UUID()
    var name: String
    var imageAsset: String // Corresponds to PZF1-4 image assets
    var question: String
    var options: [String]
    var correctIndex: Int
    var fact: String
    
    static func == (lhs: FujiLayer, rhs: FujiLayer) -> Bool {
        lhs.id == rhs.id
    }
}

struct FujiBuilderQuiz {
    var layers: [FujiLayer]
}

class FujiQuizManager: ObservableObject {
    @Published var quiz: FujiBuilderQuiz?
    @Published var currentIndex = 0
    @Published var answeredCorrectly: [String] = []
    @Published var showingFact = false
    @Published var currentFact = ""
    
    func loadQuiz() {
        // Create a Mount Fuji volcano quiz with 4 layers
        let layers = [
            FujiLayer(
                name: "Base",
                imageAsset: "PZF1",
                question: "When was Mount Fuji's last eruption?",
                options: ["1707", "1800", "1900", "2000"],
                correctIndex: 0,
                fact: "Mount Fuji last erupted in 1707-1708, known as the Hoei eruption, which deposited ash on Tokyo."
            ),
            FujiLayer(
                name: "Mid-Section",
                imageAsset: "PZF2",
                question: "What is the height of Mount Fuji?",
                options: ["2,776 meters", "3,776 meters", "4,776 meters", "5,776 meters"],
                correctIndex: 1,
                fact: "At 3,776 meters (12,380 feet), Mount Fuji is Japan's highest mountain."
            ),
            FujiLayer(
                name: "Upper Cone",
                imageAsset: "PZF3",
                question: "What type of volcano is Mount Fuji?",
                options: ["Shield volcano", "Stratovolcano", "Cinder cone", "Caldera"],
                correctIndex: 1,
                fact: "Mount Fuji is a stratovolcano, also known as a composite volcano, built of layers of lava and ash."
            ),
            FujiLayer(
                name: "Summit",
                imageAsset: "PZF4",
                question: "What is the diameter of Mount Fuji's crater?",
                options: ["500 meters", "750 meters", "1000 meters", "1500 meters"],
                correctIndex: 0,
                fact: "The summit crater of Mount Fuji is about 500 meters in diameter and 250 meters deep."
            )
        ]
        
        quiz = FujiBuilderQuiz(layers: layers)
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