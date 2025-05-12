import SwiftUI

// Match Zone represents a target area on the volcano where a label can be dropped
struct MatchZone: Identifiable {
    let id = UUID()
    let label: String
    let coordinates: CGPoint
    let size: CGSize
    let fact: String
    var isMatched: Bool = false
}

// Match Item represents a draggable word/label that the user needs to position
struct MatchItem: Identifiable {
    let id = UUID()
    let label: String
    var position: CGPoint
    var originalPosition: CGPoint
    var isMatched: Bool = false
}

// Volcano Match represents the entire match game for a specific volcano
struct VolcanoMatch {
    let volcanoName: String
    let backgroundImage: String
    var zones: [MatchZone]
    var items: [MatchItem]
    var isCompleted: Bool = false
    
    // Progress calculation
    var progress: Double {
        if zones.isEmpty { return 0 }
        return Double(zones.filter { $0.isMatched }.count) / Double(zones.count)
    }
    
    // Check if all items are matched
    var isAllMatched: Bool {
        return zones.allSatisfy { $0.isMatched }
    }
    
    // Function to reset the game
    mutating func reset() {
        for i in 0..<zones.count {
            zones[i].isMatched = false
        }
        
        for i in 0..<items.count {
            items[i].position = items[i].originalPosition
            items[i].isMatched = false
        }
        
        isCompleted = false
    }
    
    // Function to check if a drag position matches a zone
    func checkMatch(itemIndex: Int, dragPosition: CGPoint) -> Int? {
        // Already matched items can't be rematched
        if items[itemIndex].isMatched {
            return nil
        }
        
        // Get the label of the current dragged item
        let itemLabel = items[itemIndex].label
        
        // Find the corresponding zone with the same label
        for (index, zone) in zones.enumerated() {
            if !zone.isMatched && zone.label == itemLabel {
                // Calculate distance between drag position and zone center
                let distance = sqrt(
                    pow(dragPosition.x - zone.coordinates.x, 2) +
                    pow(dragPosition.y - zone.coordinates.y, 2)
                )
                
                // If distance is within a reasonable threshold,
                // consider it a match - reduced from 50 to 40 for more precision
                let matchThreshold: CGFloat = 40.0
                if distance < matchThreshold {
                    return index
                }
            }
        }
        
        return nil
    }
    
    // Update match state when an item is correctly placed
    mutating func setMatched(itemIndex: Int, zoneIndex: Int) {
        items[itemIndex].isMatched = true
        zones[zoneIndex].isMatched = true
        
        // Check if the game is now complete
        if isAllMatched {
            isCompleted = true
        }
    }
}

// Sample match data for Mount Vesuvius
extension VolcanoMatch {
    static var vesuviusSample: VolcanoMatch {
        return VolcanoMatch(
            volcanoName: "Mount Vesuvius",
            backgroundImage: "Match1",
            zones: [
                MatchZone(
                    label: "Crater",
                    coordinates: CGPoint(x: 180, y: 90),
                    size: CGSize(width: 80, height: 50),
                    fact: "The crater is the bowl-shaped depression at the top of the volcano where eruptions occur."
                ),
                MatchZone(
                    label: "Magma Chamber",
                    coordinates: CGPoint(x: 200, y: 325),
                    size: CGSize(width: 100, height: 60),
                    fact: "The magma chamber is where molten rock collects before an eruption."
                ),
                MatchZone(
                    label: "Lava Flow",
                    coordinates: CGPoint(x: 280, y: 175),
                    size: CGSize(width: 90, height: 50),
                    fact: "Lava flows are streams of molten rock that pour out of a volcano during an eruption."
                ),
                MatchZone(
                    label: "Ash Cloud",
                    coordinates: CGPoint(x: 190, y: 60),
                    size: CGSize(width: 90, height: 50),
                    fact: "Ash clouds contain tiny particles of rock and can rise thousands of meters into the air."
                ),
                MatchZone(
                    label: "Vent",
                    coordinates: CGPoint(x: 170, y: 180),
                    size: CGSize(width: 70, height: 50),
                    fact: "The vent is the opening through which volcanic materials are ejected."
                )
            ],
            items: [
                MatchItem(
                    label: "Crater",
                    position: CGPoint(x: 80, y: 480),
                    originalPosition: CGPoint(x: 80, y: 480)
                ),
                MatchItem(
                    label: "Magma Chamber",
                    position: CGPoint(x: 240, y: 480),
                    originalPosition: CGPoint(x: 240, y: 480)
                ),
                MatchItem(
                    label: "Lava Flow",
                    position: CGPoint(x: 80, y: 550),
                    originalPosition: CGPoint(x: 80, y: 550)
                ),
                MatchItem(
                    label: "Ash Cloud",
                    position: CGPoint(x: 240, y: 550),
                    originalPosition: CGPoint(x: 240, y: 550)
                ),
                MatchItem(
                    label: "Vent",
                    position: CGPoint(x: 160, y: 620),
                    originalPosition: CGPoint(x: 160, y: 620)
                )
            ]
        )
    }
    
    static var stHelensSample: VolcanoMatch {
        return VolcanoMatch(
            volcanoName: "Mount St. Helens",
            backgroundImage: "Match2",
            zones: [
                MatchZone(
                    label: "Crater",
                    coordinates: CGPoint(x: 200, y: 80),
                    size: CGSize(width: 100, height: 60),
                    fact: "The 1980 eruption created a massive crater, replacing the previously symmetric peak."
                ),
                MatchZone(
                    label: "Pyroclastic Flow",
                    coordinates: CGPoint(x: 100, y: 140),
                    size: CGSize(width: 120, height: 60),
                    fact: "Pyroclastic flows are fast-moving currents of hot gas and volcanic matter that travel down the slopes of volcanoes."
                ),
                MatchZone(
                    label: "Volcanic Dome",
                    coordinates: CGPoint(x: 220, y: 120),
                    size: CGSize(width: 100, height: 60),
                    fact: "A new dome has been growing in the crater since the eruption."
                ),
                MatchZone(
                    label: "Magma Chamber",
                    coordinates: CGPoint(x: 200, y: 310),
                    size: CGSize(width: 100, height: 60),
                    fact: "The magma chamber feeds the volcano with molten rock from deep within the Earth."
                ),
                MatchZone(
                    label: "Lateral Blast Zone",
                    coordinates: CGPoint(x: 70, y: 170),
                    size: CGSize(width: 110, height: 60),
                    fact: "The 1980 eruption featured a lateral blast that devastated the surrounding forest."
                )
            ],
            items: [
                MatchItem(
                    label: "Crater",
                    position: CGPoint(x: 80, y: 480),
                    originalPosition: CGPoint(x: 80, y: 480)
                ),
                MatchItem(
                    label: "Pyroclastic Flow",
                    position: CGPoint(x: 240, y: 480),
                    originalPosition: CGPoint(x: 240, y: 480)
                ),
                MatchItem(
                    label: "Volcanic Dome",
                    position: CGPoint(x: 80, y: 550),
                    originalPosition: CGPoint(x: 80, y: 550)
                ),
                MatchItem(
                    label: "Magma Chamber",
                    position: CGPoint(x: 240, y: 550),
                    originalPosition: CGPoint(x: 240, y: 550)
                ),
                MatchItem(
                    label: "Lateral Blast Zone",
                    position: CGPoint(x: 160, y: 620),
                    originalPosition: CGPoint(x: 160, y: 620)
                )
            ]
        )
    }
    
    static var fujiSample: VolcanoMatch {
        return VolcanoMatch(
            volcanoName: "Mount Fuji",
            backgroundImage: "Match3A",
            zones: [
                MatchZone(
                    label: "Summit Crater",
                    coordinates: CGPoint(x: 200, y: 55),
                    size: CGSize(width: 100, height: 50),
                    fact: "Fuji's summit crater is about 500 meters in diameter and 250 meters deep."
                ),
                MatchZone(
                    label: "Parasitic Cone",
                    coordinates: CGPoint(x: 85, y: 140),
                    size: CGSize(width: 100, height: 50),
                    fact: "Parasitic cones are small volcanic vents that form on the flanks of the main volcano."
                ),
                MatchZone(
                    label: "Lava Layer",
                    coordinates: CGPoint(x: 200, y: 210),
                    size: CGSize(width: 100, height: 50),
                    fact: "Mount Fuji is built up of many layers of lava and ash from previous eruptions."
                ),
                MatchZone(
                    label: "Magma Chamber",
                    coordinates: CGPoint(x: 200, y: 330),
                    size: CGSize(width: 100, height: 60),
                    fact: "Fuji's magma chamber is located deep beneath the mountain and feeds its eruptions."
                ),
                MatchZone(
                    label: "Volcanic Vent",
                    coordinates: CGPoint(x: 200, y: 130),
                    size: CGSize(width: 90, height: 50),
                    fact: "The vent connects the magma chamber to the surface, allowing lava and gases to escape."
                )
            ],
            items: [
                MatchItem(
                    label: "Summit Crater",
                    position: CGPoint(x: 80, y: 480),
                    originalPosition: CGPoint(x: 80, y: 480)
                ),
                MatchItem(
                    label: "Parasitic Cone",
                    position: CGPoint(x: 240, y: 480),
                    originalPosition: CGPoint(x: 240, y: 480)
                ),
                MatchItem(
                    label: "Lava Layer",
                    position: CGPoint(x: 80, y: 550),
                    originalPosition: CGPoint(x: 80, y: 550)
                ),
                MatchItem(
                    label: "Magma Chamber",
                    position: CGPoint(x: 240, y: 550),
                    originalPosition: CGPoint(x: 240, y: 550)
                ),
                MatchItem(
                    label: "Volcanic Vent",
                    position: CGPoint(x: 160, y: 620),
                    originalPosition: CGPoint(x: 160, y: 620)
                )
            ]
        )
    }
    
    // Get match game by volcano name
    static func getMatch(for volcanoName: String) -> VolcanoMatch {
        switch volcanoName {
        case "Mount St. Helens":
            return stHelensSample
        case "Mount Fuji":
            return fujiSample
        default:
            return vesuviusSample
        }
    }
} 