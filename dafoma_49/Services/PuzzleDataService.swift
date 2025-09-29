//
//  PuzzleDataService.swift
//  dafoma_49
//
//  Created by Вячеслав on 9/29/25.
//

import Foundation

class PuzzleDataService: ObservableObject {
    static let shared = PuzzleDataService()
    
    private init() {}
    
    // MARK: - Sample Puzzle Data
    
    // MARK: - Word Search Puzzles
    func generateWordSearchPuzzle(difficulty: PuzzleDifficulty) -> WordSearchPuzzle {
        let gridSize: Int
        let wordsToFind: [String]
        let estimatedTime: TimeInterval
        
        switch difficulty {
        case .beginner:
            gridSize = 10
            wordsToFind = ["SWIFT", "CODE", "APP", "iOS", "MAC"]
            estimatedTime = 300 // 5 minutes
        case .intermediate:
            gridSize = 12
            wordsToFind = ["PROGRAMMING", "DEVELOPER", "XCODE", "INTERFACE", "DESIGN", "MOBILE"]
            estimatedTime = 600 // 10 minutes
        case .advanced:
            gridSize = 15
            wordsToFind = ["ARCHITECTURE", "FRAMEWORK", "ALGORITHM", "DATABASE", "NETWORKING", "SECURITY", "OPTIMIZATION"]
            estimatedTime = 900 // 15 minutes
        case .expert:
            gridSize = 18
            wordsToFind = ["MULTITHREADING", "SYNCHRONIZATION", "ENCAPSULATION", "POLYMORPHISM", "INHERITANCE", "ABSTRACTION", "COMPOSITION", "DELEGATION"]
            estimatedTime = 1200 // 20 minutes
        }
        
        let grid = generateWordSearchGrid(size: gridSize, words: wordsToFind)
        
        return WordSearchPuzzle(
            title: "\(difficulty.rawValue) Word Search",
            difficulty: difficulty,
            estimatedTime: estimatedTime,
            grid: grid,
            wordsToFind: wordsToFind,
            gridSize: gridSize
        )
    }
    
    private func generateWordSearchGrid(size: Int, words: [String]) -> [[String]] {
        var grid = Array(repeating: Array(repeating: " ", count: size), count: size)
        
        // Place words in the grid (simplified implementation)
        for word in words {
            if let position = findValidPosition(for: word, in: grid, size: size) {
                placeWord(word, at: position, in: &grid)
            }
        }
        
        // Fill empty spaces with random letters
        let alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
        for i in 0..<size {
            for j in 0..<size {
                if grid[i][j] == " " {
                    grid[i][j] = alphabet.randomElement() ?? "A"
                }
            }
        }
        
        return grid
    }
    
    private func findValidPosition(for word: String, in grid: [[String]], size: Int) -> (row: Int, col: Int, direction: Direction)? {
        let directions: [Direction] = [.horizontal, .vertical, .diagonal]
        let maxAttempts = 100
        
        for _ in 0..<maxAttempts {
            let direction = directions.randomElement()!
            let row = Int.random(in: 0..<size)
            let col = Int.random(in: 0..<size)
            
            if canPlaceWord(word, at: (row, col), direction: direction, in: grid, size: size) {
                return (row, col, direction)
            }
        }
        
        return nil
    }
    
    private func canPlaceWord(_ word: String, at position: (row: Int, col: Int), direction: Direction, in grid: [[String]], size: Int) -> Bool {
        let (row, col) = position
        let wordLength = word.count
        
        switch direction {
        case .horizontal:
            return col + wordLength <= size
        case .vertical:
            return row + wordLength <= size
        case .diagonal:
            return row + wordLength <= size && col + wordLength <= size
        }
    }
    
    private func placeWord(_ word: String, at position: (row: Int, col: Int, direction: Direction), in grid: inout [[String]]) {
        let (row, col, direction) = position
        let characters = word.map { String($0) }
        
        for (index, char) in characters.enumerated() {
            switch direction {
            case .horizontal:
                grid[row][col + index] = char
            case .vertical:
                grid[row + index][col] = char
            case .diagonal:
                grid[row + index][col + index] = char
            }
        }
    }
    
    enum Direction {
        case horizontal, vertical, diagonal
    }
    
    // MARK: - Number Sequence Puzzles
    func generateNumberSequencePuzzle(difficulty: PuzzleDifficulty) -> NumberSequencePuzzle {
        let sequenceLength: Int
        let missingCount: Int
        let estimatedTime: TimeInterval
        
        switch difficulty {
        case .beginner:
            sequenceLength = 8
            missingCount = 2
            estimatedTime = 180 // 3 minutes
        case .intermediate:
            sequenceLength = 10
            missingCount = 3
            estimatedTime = 300 // 5 minutes
        case .advanced:
            sequenceLength = 12
            missingCount = 4
            estimatedTime = 420 // 7 minutes
        case .expert:
            sequenceLength = 15
            missingCount = 5
            estimatedTime = 600 // 10 minutes
        }
        
        let (sequence, correctAnswers, hint) = generateSequence(length: sequenceLength, difficulty: difficulty)
        let missingIndices = Array(0..<sequenceLength).shuffled().prefix(missingCount).sorted()
        
        return NumberSequencePuzzle(
            title: "\(difficulty.rawValue) Number Sequence",
            difficulty: difficulty,
            estimatedTime: estimatedTime,
            sequence: sequence,
            missingIndices: Array(missingIndices),
            correctAnswers: Dictionary(uniqueKeysWithValues: missingIndices.map { ($0, correctAnswers[$0]) }),
            hint: hint
        )
    }
    
    private func generateSequence(length: Int, difficulty: PuzzleDifficulty) -> ([Int], [Int], String) {
        let sequenceType = Int.random(in: 0..<4)
        
        switch sequenceType {
        case 0: // Arithmetic sequence
            let start = Int.random(in: 1...10)
            let difference = Int.random(in: 2...5)
            let sequence = (0..<length).map { start + $0 * difference }
            return (sequence, sequence, "Each number increases by \(difference)")
            
        case 1: // Geometric sequence
            let start = Int.random(in: 2...5)
            let ratio = 2
            let sequence = (0..<length).map { start * Int(pow(Double(ratio), Double($0))) }
            return (sequence, sequence, "Each number is multiplied by \(ratio)")
            
        case 2: // Fibonacci-like
            var sequence = [1, 1]
            for i in 2..<length {
                sequence.append(sequence[i-1] + sequence[i-2])
            }
            return (sequence, sequence, "Each number is the sum of the two previous numbers")
            
        default: // Square numbers
            let sequence = (1...length).map { $0 * $0 }
            return (sequence, sequence, "Each number is a perfect square")
        }
    }
    
    // MARK: - Pattern Matching Puzzles
    func generatePatternMatchingPuzzle(difficulty: PuzzleDifficulty) -> PatternMatchingPuzzle {
        let pairCount: Int
        let estimatedTime: TimeInterval
        
        switch difficulty {
        case .beginner:
            pairCount = 4
            estimatedTime = 240 // 4 minutes
        case .intermediate:
            pairCount = 6
            estimatedTime = 360 // 6 minutes
        case .advanced:
            pairCount = 8
            estimatedTime = 480 // 8 minutes
        case .expert:
            pairCount = 10
            estimatedTime = 600 // 10 minutes
        }
        
        let patterns = generatePatterns(count: pairCount)
        let options = patterns.shuffled()
        let correctMatches = Dictionary(uniqueKeysWithValues: zip(patterns.map { $0.id }, patterns.map { $0.id }))
        
        return PatternMatchingPuzzle(
            title: "\(difficulty.rawValue) Pattern Matching",
            difficulty: difficulty,
            estimatedTime: estimatedTime,
            patterns: patterns,
            options: options,
            correctMatches: correctMatches
        )
    }
    
    private func generatePatterns(count: Int) -> [PatternItem] {
        var patterns: [PatternItem] = []
        
        for _ in 0..<count {
            let shape = PatternShape.allCases.randomElement()!
            let color = PatternColor.allCases.randomElement()!
            let size = PatternSize.allCases.randomElement()!
            
            patterns.append(PatternItem(shape: shape, color: color, size: size))
        }
        
        return patterns
    }
    
    // MARK: - Puzzle Generation
    func generateRandomPuzzle(difficulty: PuzzleDifficulty) -> any Puzzle {
        let puzzleTypes: [PuzzleType] = [.wordSearch, .numberSequence, .patternMatching]
        let selectedType = puzzleTypes.randomElement()!
        
        switch selectedType {
        case .wordSearch:
            return generateWordSearchPuzzle(difficulty: difficulty)
        case .numberSequence:
            return generateNumberSequencePuzzle(difficulty: difficulty)
        case .patternMatching:
            return generatePatternMatchingPuzzle(difficulty: difficulty)
        default:
            return generateWordSearchPuzzle(difficulty: difficulty)
        }
    }
    
    func generatePuzzleSet(count: Int, difficulty: PuzzleDifficulty) -> [any Puzzle] {
        var puzzles: [any Puzzle] = []
        
        for _ in 0..<count {
            puzzles.append(generateRandomPuzzle(difficulty: difficulty))
        }
        
        return puzzles
    }
    
    // MARK: - Puzzle Statistics
    func getPuzzleStatistics(for playerName: String) -> PuzzleStatistics {
        let scores = DataService.shared.fetchScores(gameType: .puzzle).filter { $0.playerName == playerName }
        
        let totalPuzzlesSolved = scores.count
        let totalScore = scores.reduce(0) { $0 + $1.score }
        let averageScore = totalPuzzlesSolved > 0 ? Double(totalScore) / Double(totalPuzzlesSolved) : 0
        let bestScore = scores.max(by: { $0.score < $1.score })?.score ?? 0
        let totalTimeSpent = scores.reduce(0) { $0 + $1.timeSpent }
        
        // Calculate type stats (simplified for now)
        var typeStats: [PuzzleType: PuzzleTypeStats] = [:]
        for type in PuzzleType.allCases {
            typeStats[type] = PuzzleTypeStats(
                puzzlesSolved: 0,
                totalScore: 0,
                averageScore: 0,
                bestTime: 0
            )
        }
        
        // Calculate difficulty stats (simplified for now)
        var difficultyStats: [PuzzleDifficulty: PuzzleDifficultyStats] = [:]
        for difficulty in PuzzleDifficulty.allCases {
            difficultyStats[difficulty] = PuzzleDifficultyStats(
                puzzlesSolved: 0,
                totalScore: 0,
                averageScore: 0,
                completionRate: 0
            )
        }
        
        return PuzzleStatistics(
            totalPuzzlesSolved: totalPuzzlesSolved,
            totalScore: totalScore,
            averageScore: averageScore,
            bestScore: bestScore,
            totalTimeSpent: totalTimeSpent,
            typeStats: typeStats,
            difficultyStats: difficultyStats
        )
    }
    
    // MARK: - Achievement Checking
    func checkForAchievements(puzzle: any Puzzle, playerName: String) -> [Achievement] {
        var newAchievements: [Achievement] = []
        let playerStats = DataService.shared.getPlayerStatistics(for: playerName)
        
        // First Puzzle Achievement
        if playerStats.totalGamesPlayed == 0 {
            let achievement = Achievement(
                title: "Puzzle Pioneer",
                description: "Complete your first puzzle",
                icon: "puzzlepiece.fill",
                rarity: .common,
                unlockedDate: Date(),
                category: .puzzle
            )
            newAchievements.append(achievement)
        }
        
        // Perfect Puzzle Achievement
        if puzzle.score >= Int(500 * puzzle.difficulty.multiplier) {
            let achievement = Achievement(
                title: "Perfect Puzzle",
                description: "Achieve maximum score on a puzzle",
                icon: "star.circle.fill",
                rarity: .rare,
                unlockedDate: Date(),
                category: .accuracy
            )
            newAchievements.append(achievement)
        }
        
        // Speed Solver Achievement
        if let completionTime = puzzle.completionTime,
           let startTime = puzzle.startTime,
           completionTime.timeIntervalSince(startTime) < puzzle.estimatedTime * 0.5 {
            let achievement = Achievement(
                title: "Speed Solver",
                description: "Complete a puzzle in half the estimated time",
                icon: "timer",
                rarity: .epic,
                unlockedDate: Date(),
                category: .speed
            )
            newAchievements.append(achievement)
        }
        
        // Puzzle Master Achievement
        if playerStats.totalGamesPlayed >= 50 {
            let achievement = Achievement(
                title: "Puzzle Master",
                description: "Complete 50 puzzles",
                icon: "crown.fill",
                rarity: .legendary,
                unlockedDate: Date(),
                category: .dedication
            )
            newAchievements.append(achievement)
        }
        
        // Save new achievements
        for achievement in newAchievements {
            DataService.shared.saveAchievement(achievement, for: playerName)
        }
        
        return newAchievements
    }
}
