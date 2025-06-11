import SwiftUI

// Modelo para una tarjeta informativa (simplificado)
struct VolcanoFlashcard: Identifiable {
    let id = UUID()
    let image: String
    // Mantenemos estos campos por compatibilidad, pero no los usaremos en la vista
    let title: String = ""
    let description: String = ""
}

// Colección de tarjetas para cada volcán
struct VolcanoFlashcardDeck {
    let volcanoName: String
    let cards: [VolcanoFlashcard]
    
    // Obtener deck de tarjetas según el volcán
    static func getDeck(for volcanoName: String) -> VolcanoFlashcardDeck {
        switch volcanoName {
        case "Mount Vesuvius":
            return vesuviusDeck
        case "Mount St. Helens":
            return stHelensDeck
        case "Mount Fuji":
            return fujiDeck
        default:
            return vesuviusDeck
        }
    }
    
    // Tarjetas para Mount Vesuvius (solo imágenes)
    static var vesuviusDeck: VolcanoFlashcardDeck {
        return VolcanoFlashcardDeck(
            volcanoName: "Mount Vesuvius",
            cards: [
                VolcanoFlashcard(image: "FC1"),
                VolcanoFlashcard(image: "FC2"),
                VolcanoFlashcard(image: "FC3"),
                VolcanoFlashcard(image: "FC4"),
                VolcanoFlashcard(image: "FC5"),
                VolcanoFlashcard(image: "FC6")
            ]
        )
    }
    
    // Mount St. Helens deck con las imágenes correspondientes
    static var stHelensDeck: VolcanoFlashcardDeck {
        return VolcanoFlashcardDeck(
            volcanoName: "Mount St. Helens",
            cards: [
                VolcanoFlashcard(image: "MS1"),
                VolcanoFlashcard(image: "MS2"),
                VolcanoFlashcard(image: "MS3"),
                VolcanoFlashcard(image: "MS4"),
                VolcanoFlashcard(image: "MS5"),
                VolcanoFlashcard(image: "MS6")
            ]
        )
    }
    
    // Mount Fuji deck con las imágenes correspondientes
    static var fujiDeck: VolcanoFlashcardDeck {
        return VolcanoFlashcardDeck(
            volcanoName: "Mount Fuji",
            cards: [
                VolcanoFlashcard(image: "MF1"),
                VolcanoFlashcard(image: "MF2"),
                VolcanoFlashcard(image: "MF3"),
                VolcanoFlashcard(image: "MF4"),
                VolcanoFlashcard(image: "MF5")
            ]
        )
    }
}
