//
//  PuzzleModel.swift
//  dafoma_49
//
//  Created by Вячеслав on 9/29/25.
//

import Foundation

// MARK: - Puzzle Types
enum PuzzleType: String, CaseIterable, Codable {
    case wordSearch = "Word Search"
    case sudoku = "Sudoku"
    case crossword = "Crossword"
    case logicGrid = "Logic Grid"
    case numberSequence = "Number Sequence"
    case patternMatching = "Pattern Matching"
    
    var icon: String {
        switch self {
        case .wordSearch: return "textformat.abc"
        case .sudoku: return "grid"
        case .crossword: return "square.grid.3x3"
        case .logicGrid: return "square.grid.4x4"
        case .numberSequence: return "number"
        case .patternMatching: return "circle.grid.3x3"
        }
    }
    
    var description: String {
        switch self {
        case .wordSearch: return "Find hidden words in a grid of letters"
        case .sudoku: return "Fill the grid with numbers 1-9"
        case .crossword: return "Solve clues to fill the crossword"
        case .logicGrid: return "Use logic to solve the grid puzzle"
        case .numberSequence: return "Find the pattern in number sequences"
        case .patternMatching: return "Match patterns and shapes"
        }
    }
}

// MARK: - Puzzle Difficulty
enum PuzzleDifficulty: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"
    
    var multiplier: Double {
        switch self {
        case .beginner: return 1.0
        case .intermediate: return 1.3
        case .advanced: return 1.7
        case .expert: return 2.5
        }
    }
    
    var color: String {
        switch self {
        case .beginner: return "#4CAF50"
        case .intermediate: return "#FF9800"
        case .advanced: return "#F44336"
        case .expert: return "#9C27B0"
        }
    }
}

// MARK: - Base Puzzle Protocol
protocol Puzzle: Identifiable, Codable {
    var id: UUID { get }
    var title: String { get }
    var type: PuzzleType { get }
    var difficulty: PuzzleDifficulty { get }
    var estimatedTime: TimeInterval { get }
    var isCompleted: Bool { get set }
    var score: Int { get set }
    var startTime: Date? { get set }
    var completionTime: Date? { get set }
}

// MARK: - Word Search Puzzle
struct WordSearchPuzzle: Puzzle {
    var id = UUID()
    let title: String
    let type: PuzzleType = .wordSearch
    let difficulty: PuzzleDifficulty
    let estimatedTime: TimeInterval
    var isCompleted: Bool = false
    var score: Int = 0
    var startTime: Date?
    var completionTime: Date?
    
    let grid: [[String]] // Changed from [[Character]] to [[String]] for Codable
    let wordsToFind: [String]
    var foundWords: Set<String> = []
    let gridSize: Int
    
    var progress: Double {
        guard !wordsToFind.isEmpty else { return 0 }
        return Double(foundWords.count) / Double(wordsToFind.count)
    }
    
    mutating func markWordFound(_ word: String) {
        if wordsToFind.contains(word) {
            foundWords.insert(word)
            score += Int(100 * difficulty.multiplier)
            
            if foundWords.count == wordsToFind.count {
                isCompleted = true
                completionTime = Date()
            }
        }
    }
}

// MARK: - Number Sequence Puzzle
struct NumberSequencePuzzle: Puzzle {
    var id = UUID()
    let title: String
    let type: PuzzleType = .numberSequence
    let difficulty: PuzzleDifficulty
    let estimatedTime: TimeInterval
    var isCompleted: Bool = false
    var score: Int = 0
    var startTime: Date?
    var completionTime: Date?
    
    let sequence: [Int]
    let missingIndices: [Int]
    let correctAnswers: [Int: Int] // index: correct value
    var userAnswers: [Int: Int] = [:]
    let hint: String
    
    var progress: Double {
        guard !missingIndices.isEmpty else { return 0 }
        return Double(userAnswers.count) / Double(missingIndices.count)
    }
    
    mutating func submitAnswer(at index: Int, value: Int) {
        userAnswers[index] = value
        
        if let correctValue = correctAnswers[index], correctValue == value {
            score += Int(50 * difficulty.multiplier)
        }
        
        if userAnswers.count == missingIndices.count {
            let correctCount = userAnswers.filter { correctAnswers[$0.key] == $0.value }.count
            if correctCount == missingIndices.count {
                isCompleted = true
                completionTime = Date()
                score += Int(200 * difficulty.multiplier) // Bonus for completing
            }
        }
    }
}

// MARK: - Pattern Matching Puzzle
struct PatternMatchingPuzzle: Puzzle {
    var id = UUID()
    let title: String
    let type: PuzzleType = .patternMatching
    let difficulty: PuzzleDifficulty
    let estimatedTime: TimeInterval
    var isCompleted: Bool = false
    var score: Int = 0
    var startTime: Date?
    var completionTime: Date?
    
    let patterns: [PatternItem]
    let options: [PatternItem]
    var matches: [UUID: UUID] = [:] // pattern id: option id
    let correctMatches: [UUID: UUID]
    
    var progress: Double {
        guard !patterns.isEmpty else { return 0 }
        return Double(matches.count) / Double(patterns.count)
    }
    
    mutating func makeMatch(patternId: UUID, optionId: UUID) {
        matches[patternId] = optionId
        
        if let correctOptionId = correctMatches[patternId], correctOptionId == optionId {
            score += Int(75 * difficulty.multiplier)
        }
        
        if matches.count == patterns.count {
            let correctCount = matches.filter { correctMatches[$0.key] == $0.value }.count
            if correctCount == patterns.count {
                isCompleted = true
                completionTime = Date()
                score += Int(150 * difficulty.multiplier) // Bonus for completing
            }
        }
    }
}

// MARK: - Pattern Item
struct PatternItem: Identifiable, Codable {
    var id = UUID()
    let shape: PatternShape
    let color: PatternColor
    let size: PatternSize
}

enum PatternShape: String, CaseIterable, Codable {
    case circle, square, triangle, diamond, star, hexagon
}

enum PatternColor: String, CaseIterable, Codable {
    case red, blue, green, yellow, purple, orange
    
    var hexValue: String {
        switch self {
        case .red: return "#F44336"
        case .blue: return "#2196F3"
        case .green: return "#4CAF50"
        case .yellow: return "#FFEB3B"
        case .purple: return "#9C27B0"
        case .orange: return "#FF9800"
        }
    }
}

enum PatternSize: String, CaseIterable, Codable {
    case small, medium, large
    
    var value: CGFloat {
        switch self {
        case .small: return 20
        case .medium: return 30
        case .large: return 40
        }
    }
}

// MARK: - Puzzle Session
struct PuzzleSession: Identifiable {
    let id = UUID()
    var currentPuzzle: any Puzzle
    let startTime: Date = Date()
    var endTime: Date?
    var totalScore: Int = 0
    
    var timeElapsed: TimeInterval {
        return (endTime ?? Date()).timeIntervalSince(startTime)
    }
    
    mutating func completePuzzle() {
        endTime = Date()
        totalScore = currentPuzzle.score
    }
}

// MARK: - Puzzle Statistics
struct PuzzleStatistics {
    let totalPuzzlesSolved: Int
    let totalScore: Int
    let averageScore: Double
    let bestScore: Int
    let totalTimeSpent: TimeInterval
    let typeStats: [PuzzleType: PuzzleTypeStats]
    let difficultyStats: [PuzzleDifficulty: PuzzleDifficultyStats]
}

struct PuzzleTypeStats {
    let puzzlesSolved: Int
    let totalScore: Int
    let averageScore: Double
    let bestTime: TimeInterval
}

struct PuzzleDifficultyStats {
    let puzzlesSolved: Int
    let totalScore: Int
    let averageScore: Double
    let completionRate: Double
}
