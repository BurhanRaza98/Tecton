import Foundation

// Question Types
enum QuestionType {
    case singleChoice
    case trueFalse
    case visualMatch
}

// Badge Levels
enum BadgeLevel: String {
    case bronze = "Bronze"
    case silver = "Silver" 
    case gold = "Gold"
    
    static func forScore(score: Int, totalQuestions: Int) -> BadgeLevel {
        let percentage = Double(score) / Double(totalQuestions)
        if percentage >= 1.0 {
            return .gold
        } else if percentage >= 0.8 {
            return .silver
        } else {
            return .bronze
        }
    }
}

// Quiz Question model
struct QuizQuestion: Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctAnswerIndex: Int
    let type: QuestionType
    let funFact: String // Shown after answering correctly
    let hint: String // Shown after answering incorrectly
    
    // Convenience property to get the correct answer
    var correctAnswer: String {
        return options[correctAnswerIndex]
    }
}

// Volcano Quiz model
struct VolcanoQuiz {
    let volcanoName: String
    let questions: [QuizQuestion]
    let description: String
    let unlockableFacts: [String]
    
    // Track the user's progress
    var currentQuestionIndex: Int = 0
    var score: Int = 0
    var isCompleted: Bool = false
    
    // Compute badge level based on current score
    var badgeLevel: BadgeLevel {
        return BadgeLevel.forScore(score: score, totalQuestions: questions.count)
    }
    
    // Progress as percentage
    var progress: Double {
        if questions.isEmpty { return 0 }
        return Double(currentQuestionIndex) / Double(questions.count)
    }
    
    // Check if quiz is finished
    var isFinished: Bool {
        return currentQuestionIndex >= questions.count
    }
    
    // Get current question
    var currentQuestion: QuizQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    // Mutating functions to update quiz state
    mutating func answerQuestion(withIndex index: Int) -> Bool {
        guard let question = currentQuestion else { return false }
        
        let isCorrect = index == question.correctAnswerIndex
        if isCorrect {
            score += 1
        }
        
        return isCorrect
    }
    
    mutating func moveToNextQuestion() {
        currentQuestionIndex += 1
        if currentQuestionIndex >= questions.count {
            isCompleted = true
        }
    }
    
    mutating func reset() {
        currentQuestionIndex = 0
        score = 0
        isCompleted = false
    }
}

// Sample Mount Vesuvius quiz data
extension VolcanoQuiz {
    static var vesuviusSample: VolcanoQuiz {
        return VolcanoQuiz(
            volcanoName: "Mount Vesuvius",
            questions: [
                QuizQuestion(
                    question: "What type of volcano is Vesuvius?",
                    options: ["Shield Volcano", "Stratovolcano", "Cinder Cone", "Caldera"],
                    correctAnswerIndex: 1,
                    type: .singleChoice,
                    funFact: "Stratovolcanoes are the most picturesque and also the most dangerous type of volcano!",
                    hint: "It's characterized by a steep profile and periodic explosive eruptions."
                ),
                QuizQuestion(
                    question: "In what year did Mount Vesuvius famously destroy Pompeii?",
                    options: ["79 CE", "410 CE", "1200 BCE", "1944 CE"],
                    correctAnswerIndex: 0,
                    type: .singleChoice,
                    funFact: "The eruption of Vesuvius in 79 CE buried Pompeii under 13-20 feet (4-6 meters) of ash and pumice.",
                    hint: "It happened during the early Roman Empire period."
                ),
                QuizQuestion(
                    question: "Mount Vesuvius has erupted more than 50 times since 79 CE.",
                    options: ["True", "False"],
                    correctAnswerIndex: 0,
                    type: .trueFalse,
                    funFact: "The most recent eruption was in March 1944, during World War II, which destroyed several villages.",
                    hint: "Think about its historical activity over 2,000 years."
                ),
                QuizQuestion(
                    question: "Approximately how many people live in the 'red zone' around Vesuvius today?",
                    options: ["About 10,000", "About 100,000", "About 700,000", "About 3 million"],
                    correctAnswerIndex: 2,
                    type: .singleChoice,
                    funFact: "This makes Vesuvius potentially the most dangerous volcano in the world due to population density.",
                    hint: "It's one of the most densely populated volcanic regions in the world."
                ),
                QuizQuestion(
                    question: "Scientists can predict exactly when Mount Vesuvius will erupt next.",
                    options: ["True", "False"],
                    correctAnswerIndex: 1,
                    type: .trueFalse,
                    funFact: "While scientists monitor seismic activity, gas emissions, and ground deformation, exact prediction remains impossible.",
                    hint: "Think about the current limitations of volcanic prediction technology."
                )
            ],
            description: "Test your knowledge of Mount Vesuvius, one of the world's most famous volcanoes located in Italy.",
            unlockableFacts: [
                "Mount Vesuvius is the only active volcano on the European mainland.",
                "The word 'volcano' comes from Vulcan, the Roman god of fire.",
                "If Vesuvius erupts today, authorities would need at least two weeks to evacuate everyone in the danger zone."
            ]
        )
    }
    
    static var stHelensSample: VolcanoQuiz {
        return VolcanoQuiz(
            volcanoName: "Mount St. Helens",
            questions: [
                QuizQuestion(
                    question: "In what year did Mount St. Helens have its catastrophic eruption?",
                    options: ["1980", "1975", "1990", "2000"],
                    correctAnswerIndex: 0,
                    type: .singleChoice,
                    funFact: "The May 18, 1980 eruption was the deadliest and most economically destructive volcanic event in U.S. history.",
                    hint: "It happened in the early 1980s."
                ),
                QuizQuestion(
                    question: "How much elevation did Mount St. Helens lose in its 1980 eruption?",
                    options: ["400 feet", "1,300 feet", "5,500 feet", "8,000 feet"],
                    correctAnswerIndex: 1,
                    type: .singleChoice,
                    funFact: "The mountain's height was reduced from 9,677 feet to 8,363 feet as a result of the eruption.",
                    hint: "The mountain lost a significant portion of its peak, but not the majority of its height."
                ),
                QuizQuestion(
                    question: "Mount St. Helens is located in which U.S. state?",
                    options: ["Oregon", "Washington", "California", "Idaho"],
                    correctAnswerIndex: 1,
                    type: .singleChoice,
                    funFact: "Mount St. Helens is part of the Cascade Range in Washington State, named after British diplomat Lord St Helens.",
                    hint: "It's located in the Pacific Northwest region."
                ),
                QuizQuestion(
                    question: "The 1980 eruption of Mount St. Helens was predicted by scientists.",
                    options: ["True", "False"],
                    correctAnswerIndex: 0,
                    type: .trueFalse,
                    funFact: "Scientists observed increased seismic activity and a growing bulge on the mountain's north side in the months before the eruption.",
                    hint: "Think about the monitoring that was taking place before the eruption."
                ),
                QuizQuestion(
                    question: "What type of volcano is Mount St. Helens?",
                    options: ["Shield Volcano", "Stratovolcano", "Cinder Cone", "Caldera"],
                    correctAnswerIndex: 1,
                    type: .singleChoice,
                    funFact: "Like Mount Vesuvius, Mount St. Helens is a stratovolcano, characterized by steep sides and explosive eruptions.",
                    hint: "It's the same type as Mount Vesuvius."
                )
            ],
            description: "Test your knowledge of Mount St. Helens, the volcano that dramatically erupted in 1980 in Washington State.",
            unlockableFacts: [
                "The lateral blast from St. Helens' 1980 eruption traveled at speeds up to 300 miles per hour.",
                "The eruption killed 57 people, including volcanologist David Johnston.",
                "Mount St. Helens has shown renewed volcanic activity since 2004, building a new lava dome."
            ]
        )
    }
    
    static var fujiSample: VolcanoQuiz {
        return VolcanoQuiz(
            volcanoName: "Mount Fuji",
            questions: [
                QuizQuestion(
                    question: "When was Mount Fuji's last eruption?",
                    options: ["1707", "1823", "1901", "1945"],
                    correctAnswerIndex: 0,
                    type: .singleChoice,
                    funFact: "The 1707 eruption, known as the Hōei eruption, lasted for 16 days and covered Tokyo (then called Edo) in ash.",
                    hint: "It was during Japan's Edo period."
                ),
                QuizQuestion(
                    question: "What is the height of Mount Fuji?",
                    options: ["2,776 meters", "3,776 meters", "4,776 meters", "5,776 meters"],
                    correctAnswerIndex: 1,
                    type: .singleChoice,
                    funFact: "At 3,776 meters (12,389 feet), Mount Fuji is Japan's highest mountain.",
                    hint: "It's between 3,000 and 4,000 meters high."
                ),
                QuizQuestion(
                    question: "Mount Fuji is considered an active volcano.",
                    options: ["True", "False"],
                    correctAnswerIndex: 0,
                    type: .trueFalse,
                    funFact: "Though it hasn't erupted in over 300 years, Mount Fuji is still classified as active and is monitored constantly.",
                    hint: "Think about how volcanologists classify volcanoes that haven't erupted recently."
                ),
                QuizQuestion(
                    question: "Mount Fuji consists of how many distinct layers of volcanic rock?",
                    options: ["One main layer", "Three main layers", "Five main layers", "Seven main layers"],
                    correctAnswerIndex: 1,
                    type: .singleChoice,
                    funFact: "The three layers are named Komitake, Ko-Fuji (Old Fuji), and Shin-Fuji (New Fuji).",
                    hint: "Each layer represents a different stage in the volcano's formation."
                ),
                QuizQuestion(
                    question: "In what year was Mount Fuji designated as a UNESCO World Heritage Site?",
                    options: ["1978", "1995", "2013", "2020"],
                    correctAnswerIndex: 2,
                    type: .singleChoice,
                    funFact: "Mount Fuji was recognized as a UNESCO World Heritage Site as a cultural (not natural) site due to its inspiration in art and religion.",
                    hint: "It's relatively recent, within the last decade."
                )
            ],
            description: "Test your knowledge of Mount Fuji, Japan's highest mountain and an iconic symbol of Japanese culture.",
            unlockableFacts: [
                "Mount Fuji is actually three separate volcanoes stacked on top of each other.",
                "The name 'Fuji' may come from the Ainu language meaning 'fire deity'.",
                "Each year, approximately 300,000 people climb Mount Fuji, mostly during the official climbing season in July and August."
            ]
        )
    }
    
    // Method to get quiz by volcano name
    static func getQuiz(for volcanoName: String) -> VolcanoQuiz {
        switch volcanoName {
        case "Mount St. Helens":
            return stHelensSample
        case "Mount Fuji":
            return fujiSample
        default:
            return vesuviusSample // Default to Vesuvius
        }
    }
} 