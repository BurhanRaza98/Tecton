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
    
    // Placeholder para Mount St. Helens (a implementar después)
    static var stHelensDeck: VolcanoFlashcardDeck {
        return VolcanoFlashcardDeck(
            volcanoName: "Mount St. Helens",
            cards: []
        )
    }
    
    // Placeholder para Mount Fuji (a implementar después)
    static var fujiDeck: VolcanoFlashcardDeck {
        return VolcanoFlashcardDeck(
            volcanoName: "Mount Fuji",
            cards: []
        )
    }
}
