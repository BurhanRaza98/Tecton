import Foundation
import SwiftUI

struct VolcanoLayer: Identifiable, Equatable {
    var id = UUID()
    var name: String
    var imageAsset: String // Corresponds to PZV1-5 image assets
    var question: String
    var options: [String]
    var correctIndex: Int
    var fact: String
    
    static func == (lhs: VolcanoLayer, rhs: VolcanoLayer) -> Bool {
        lhs.id == rhs.id
    }
}

struct VolcanoBuilderQuiz {
    var layers: [VolcanoLayer]
}

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

class QuizManager: ObservableObject {
    @Published var quiz: VolcanoBuilderQuiz?
    @Published var currentIndex = 0
    @Published var answeredCorrectly: [String] = []
    @Published var showingFact = false
    @Published var currentFact = ""
    
    func loadQuiz() {
        // Create a Vesuvius volcano quiz with 5 layers
        let layers = [
            VolcanoLayer(
                name: "Base",
                imageAsset: "PZV1",
                question: "What is the main composition of magma in stratovolcanoes like Vesuvius?",
                options: ["Basaltic", "Andesitic", "Rhyolitic", "Granitic"],
                correctIndex: 1,
                fact: "Vesuvius typically contains intermediate andesitic magma with moderate silica content."
            ),
            VolcanoLayer(
                name: "Conduit",
                imageAsset: "PZV2",
                question: "How does magma travel from the chamber to the surface?",
                options: ["Through faults", "Through a conduit", "By lateral spreading", "By ground infiltration"],
                correctIndex: 1,
                fact: "Magma rises through a central conduit, which is a pipe-like passage."
            ),
            VolcanoLayer(
                name: "Lava Flow",
                imageAsset: "PZV3",
                question: "What was unique about Vesuvius' eruption in 79 CE?",
                options: ["It produced very fluid lava", "It mainly consisted of pyroclastic flows", "It lasted for several years", "It occurred underwater"],
                correctIndex: 1,
                fact: "The famous 79 CE eruption buried Pompeii primarily through pyroclastic flows, not lava."
            ),
            VolcanoLayer(
                name: "Crater",
                imageAsset: "PZV4",
                question: "What is the term for the depression at the top of a volcano?",
                options: ["Caldera", "Crater", "Vent", "Summit"],
                correctIndex: 1,
                fact: "A crater forms at the top of a volcano, often after eruptions."
            ),
            VolcanoLayer(
                name: "Ash Cloud",
                imageAsset: "PZV5",
                question: "How high can volcanic ash clouds reach?",
                options: ["1-5 km", "5-10 km", "10-20 km", "Over 30 km"],
                correctIndex: 3,
                fact: "Major eruptions like Vesuvius can send ash over 30 km into the stratosphere."
            )
        ]
        
        quiz = VolcanoBuilderQuiz(layers: layers)
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