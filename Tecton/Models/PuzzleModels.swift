import SwiftUI

// Enum to define the different puzzle game modes
enum PuzzleMode: String, CaseIterable, Identifiable {
    case layers = "Build the Layers"
    case sequence = "Sequence the Eruption"
    case jigsaw = "Assemble the Image"
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .layers:
            return "Stack the volcano layers from bottom to top"
        case .sequence:
            return "Arrange the steps of an eruption in order"
        case .jigsaw:
            return "Reassemble the volcano image"
        }
    }
    
    var iconName: String {
        switch self {
        case .layers:
            return "square.stack.3d.up"
        case .sequence:
            return "arrow.left.arrow.right"
        case .jigsaw:
            return "puzzlepiece"
        }
    }
}

// Puzzle piece model for all three game modes
struct PuzzlePiece: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let image: String?  // Image name (optional)
    let correctIndex: Int  // Correct position/order
    var currentIndex: Int? // Current position in the puzzle
    var isPlaced: Bool = false
    
    // For layers mode - add details for each layer
    var description: String = ""
}

// Model for the different puzzle states
struct VolcanoPuzzle {
    let volcanoName: String
    let mode: PuzzleMode
    let backgroundImage: String
    var pieces: [PuzzlePiece]
    var isCompleted: Bool = false
    var showHint: Bool = false
    
    // Calculate progress (0.0 - 1.0)
    var progress: Double {
        if pieces.isEmpty { return 0 }
        return Double(pieces.filter { $0.isPlaced }.count) / Double(pieces.count)
    }
    
    // Check if placement is correct
    func isCorrectPlacement(pieceIndex: Int, targetIndex: Int) -> Bool {
        return pieces[pieceIndex].correctIndex == targetIndex
    }
    
    // Update the puzzle state when a piece is placed
    mutating func placePiece(pieceIndex: Int, at targetIndex: Int) {
        // Make sure we properly set the isPlaced flag
        pieces[pieceIndex].isPlaced = true
        pieces[pieceIndex].currentIndex = targetIndex
        
        // Check if the puzzle is completed (regardless of correctness for jigsaw mode)
        isCompleted = pieces.allSatisfy { $0.isPlaced }
    }
    
    // Reset the puzzle
    mutating func reset() {
        for i in 0..<pieces.count {
            pieces[i].isPlaced = false
            pieces[i].currentIndex = nil
        }
        isCompleted = false
        showHint = false
    }
}

// Extension to provide sample puzzles for each volcano and mode
extension VolcanoPuzzle {
    // Build the Layers mode for Mount Vesuvius
    static var vesuviusLayers: VolcanoPuzzle {
        VolcanoPuzzle(
            volcanoName: "Mount Vesuvius",
            mode: .layers,
            backgroundImage: "PZ",
            pieces: [
                PuzzlePiece(
                    name: "Magma Chamber",
                    image: "PZV1",
                    correctIndex: 0,
                    description: "Contains molten rock deep below the surface"
                ),
                PuzzlePiece(
                    name: "Vent",
                    image: "PZV2",
                    correctIndex: 1,
                    description: "The pathway for magma to reach the surface"
                ),
                PuzzlePiece(
                    name: "Lava Layers",
                    image: "PZV3",
                    correctIndex: 2,
                    description: "Built up from previous eruptions"
                ),
                PuzzlePiece(
                    name: "Summit Crater",
                    image: "PZV4",
                    correctIndex: 3,
                    description: "The opening at the top of the volcano"
                ),
                PuzzlePiece(
                    name: "Ash Cloud",
                    image: "PZV5",
                    correctIndex: 4,
                    description: "Formed during explosive eruptions"
                )
            ]
        )
    }
    
    // Sequence the Eruption mode for Mount Vesuvius
    static var vesuviusSequence: VolcanoPuzzle {
        VolcanoPuzzle(
            volcanoName: "Mount Vesuvius",
            mode: .sequence,
            backgroundImage: "vesuvius_background",
            pieces: [
                PuzzlePiece(
                    name: "Magma Rises",
                    image: "vesuvius_seq1",
                    correctIndex: 0,
                    description: "Magma begins moving upward from deep beneath the volcano"
                ),
                PuzzlePiece(
                    name: "Pressure Builds",
                    image: "vesuvius_seq2",
                    correctIndex: 1,
                    description: "Gases in the magma expand as pressure increases"
                ),
                PuzzlePiece(
                    name: "Lava Erupts",
                    image: "vesuvius_seq3",
                    correctIndex: 2,
                    description: "Molten rock and gases escape through the vent"
                ),
                PuzzlePiece(
                    name: "Ash Cloud Forms",
                    image: "vesuvius_seq4",
                    correctIndex: 3,
                    description: "A column of ash and gas rises above the volcano"
                ),
                PuzzlePiece(
                    name: "Cone Shape Expands",
                    image: "vesuvius_seq5",
                    correctIndex: 4,
                    description: "New layers of material add to the volcano's size"
                )
            ]
        )
    }
    
    // Jigsaw puzzle mode for Mount Vesuvius (2x3 grid = 6 pieces)
    static var vesuviusJigsaw: VolcanoPuzzle {
        return VolcanoPuzzle(
            volcanoName: "Mount Vesuvius",
            mode: .jigsaw,
            backgroundImage: "PZ",
            pieces: [
                // Use the PZV images from the layers mode
                PuzzlePiece(
                    name: "Magma Chamber",
                    image: "PZV1",
                    correctIndex: 0,
                    description: "Contains molten rock deep below the surface"
                ),
                PuzzlePiece(
                    name: "Vent",
                    image: "PZV2",
                    correctIndex: 1,
                    description: "The pathway for magma to reach the surface"
                ),
                PuzzlePiece(
                    name: "Lava Layers",
                    image: "PZV3",
                    correctIndex: 2,
                    description: "Built up from previous eruptions"
                ),
                PuzzlePiece(
                    name: "Summit Crater",
                    image: "PZV4",
                    correctIndex: 3,
                    description: "The opening at the top of the volcano"
                ),
                PuzzlePiece(
                    name: "Ash Cloud",
                    image: "PZV5",
                    correctIndex: 4,
                    description: "Formed during explosive eruptions"
                ),
                // Add a sixth placeholder piece to complete the 2x3 grid
                PuzzlePiece(
                    name: "Volcanic Cone",
                    image: "PZV1", // Using an existing image as placeholder
                    correctIndex: 5,
                    description: "The mountain-like shape of the volcano"
                )
            ]
        )
    }
    
    // Get appropriate puzzle based on volcano and mode
    static func getPuzzle(for volcanoName: String, mode: PuzzleMode) -> VolcanoPuzzle {
        // Always use Vesuvius for now since that's the only one with images
        switch mode {
        case .layers:
            return vesuviusLayers
        case .sequence:
            return vesuviusSequence
        case .jigsaw:
            return vesuviusJigsaw
        }
    }
    
    static var stHelensSample: VolcanoPuzzle {
        return VolcanoPuzzle(
            volcanoName: "Mount St. Helens",
            mode: .layers,
            backgroundImage: "PZ2",
            pieces: [
                PuzzlePiece(
                    name: "Crater",
                    image: "sthelens_layer1",
                    correctIndex: 0,
                    description: "The 1980 eruption created a massive crater, replacing the previously symmetric peak."
                ),
                PuzzlePiece(
                    name: "Pyroclastic Flow",
                    image: "sthelens_layer2",
                    correctIndex: 1,
                    description: "Pyroclastic flows are fast-moving currents of hot gas and volcanic matter that travel down the slopes of volcanoes."
                ),
                PuzzlePiece(
                    name: "Volcanic Dome",
                    image: "sthelens_layer3",
                    correctIndex: 2,
                    description: "A new dome has been growing in the crater since the eruption."
                ),
                PuzzlePiece(
                    name: "Magma Chamber",
                    image: "sthelens_layer4",
                    correctIndex: 3,
                    description: "The magma chamber feeds the volcano with molten rock from deep within the Earth."
                ),
                PuzzlePiece(
                    name: "Lateral Blast Zone",
                    image: "sthelens_layer5",
                    correctIndex: 4,
                    description: "The 1980 eruption featured a lateral blast that devastated the surrounding forest."
                )
            ]
        )
    }
    
    static var fujiSample: VolcanoPuzzle {
        return VolcanoPuzzle(
            volcanoName: "Mount Fuji",
            mode: .layers,
            backgroundImage: "PZ3",
            pieces: [
                PuzzlePiece(
                    name: "Summit Crater",
                    image: "fuji_layer1",
                    correctIndex: 0,
                    description: "Fuji's summit crater is about 500 meters in diameter and 250 meters deep."
                ),
                PuzzlePiece(
                    name: "Parasitic Cone",
                    image: "fuji_layer2",
                    correctIndex: 1,
                    description: "Parasitic cones are small volcanic vents that form on the flanks of the main volcano."
                ),
                PuzzlePiece(
                    name: "Lava Layer",
                    image: "fuji_layer3",
                    correctIndex: 2,
                    description: "Mount Fuji is built up of many layers of lava and ash from previous eruptions."
                ),
                PuzzlePiece(
                    name: "Magma Chamber",
                    image: "fuji_layer4",
                    correctIndex: 3,
                    description: "Fuji's magma chamber is located deep beneath the mountain and feeds its eruptions."
                ),
                PuzzlePiece(
                    name: "Volcanic Vent",
                    image: "fuji_layer5",
                    correctIndex: 4,
                    description: "The vent connects the magma chamber to the surface, allowing lava and gases to escape."
                )
            ]
        )
    }
} 