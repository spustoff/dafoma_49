//
//  PuzzleViewModel.swift
//  dafoma_49
//
//  Created by Вячеслав on 9/29/25.
//

import Foundation
import SwiftUI

class PuzzleViewModel: ObservableObject {
    @Published var currentPuzzle: (any Puzzle)?
    @Published var isPuzzleActive = false
    @Published var showResults = false
    @Published var selectedPatternId: UUID?
    @Published var selectedOptionId: UUID?
    @Published var foundWords: Set<String> = []
    @Published var userAnswers: [Int: Int] = [:]
    @Published var matches: [UUID: UUID] = [:]
    @Published var newAchievements: [Achievement] = []
    @Published var showAchievements = false
    @Published var timeElapsed: TimeInterval = 0
    
    private var timer: Timer?
    private let puzzleDataService = PuzzleDataService.shared
    private let dataService = DataService.shared
    
    @AppStorage("playerName") private var playerName: String = "Player"
    
    // MARK: - Puzzle Management
    func startPuzzle(type: PuzzleType, difficulty: PuzzleDifficulty) {
        switch type {
        case .wordSearch:
            currentPuzzle = puzzleDataService.generateWordSearchPuzzle(difficulty: difficulty) as (any Puzzle)
        case .numberSequence:
            currentPuzzle = puzzleDataService.generateNumberSequencePuzzle(difficulty: difficulty) as (any Puzzle)
        case .patternMatching:
            currentPuzzle = puzzleDataService.generatePatternMatchingPuzzle(difficulty: difficulty) as (any Puzzle)
        default:
            currentPuzzle = puzzleDataService.generateRandomPuzzle(difficulty: difficulty)
        }
        
        currentPuzzle?.startTime = Date()
        isPuzzleActive = true
        showResults = false
        resetPuzzleState()
        startTimer()
    }
    
    func startRandomPuzzle(difficulty: PuzzleDifficulty) {
        currentPuzzle = puzzleDataService.generateRandomPuzzle(difficulty: difficulty)
        currentPuzzle?.startTime = Date()
        isPuzzleActive = true
        showResults = false
        resetPuzzleState()
        startTimer()
    }
    
    private func resetPuzzleState() {
        foundWords = []
        userAnswers = [:]
        matches = [:]
        selectedPatternId = nil
        selectedOptionId = nil
        timeElapsed = 0
    }
    
    func finishPuzzle() {
        guard var puzzle = currentPuzzle else { return }
        
        puzzle.isCompleted = true
        puzzle.completionTime = Date()
        currentPuzzle = puzzle
        
        stopTimer()
        savePuzzleResults()
        checkForAchievements()
        
        isPuzzleActive = false
        showResults = true
    }
    
    func exitPuzzle() {
        stopTimer()
        currentPuzzle = nil
        isPuzzleActive = false
        showResults = false
        resetPuzzleState()
    }
    
    // MARK: - Word Search Logic
    func markWordFound(_ word: String) {
        guard var puzzle = currentPuzzle as? WordSearchPuzzle else { return }
        
        puzzle.markWordFound(word)
        foundWords.insert(word)
        currentPuzzle = puzzle
        
        if puzzle.isCompleted {
            finishPuzzle()
        }
    }
    
    func isWordFound(_ word: String) -> Bool {
        return foundWords.contains(word)
    }
    
    func getWordsToFind() -> [String] {
        guard let puzzle = currentPuzzle as? WordSearchPuzzle else { return [] }
        return puzzle.wordsToFind
    }
    
    func getWordSearchGrid() -> [[String]] {
        guard let puzzle = currentPuzzle as? WordSearchPuzzle else { return [] }
        return puzzle.grid
    }
    
    // MARK: - Number Sequence Logic
    func submitSequenceAnswer(at index: Int, value: Int) {
        guard var puzzle = currentPuzzle as? NumberSequencePuzzle else { return }
        
        puzzle.submitAnswer(at: index, value: value)
        userAnswers[index] = value
        currentPuzzle = puzzle
        
        if puzzle.isCompleted {
            finishPuzzle()
        }
    }
    
    func getSequence() -> [Int] {
        guard let puzzle = currentPuzzle as? NumberSequencePuzzle else { return [] }
        return puzzle.sequence
    }
    
    func getMissingIndices() -> [Int] {
        guard let puzzle = currentPuzzle as? NumberSequencePuzzle else { return [] }
        return puzzle.missingIndices
    }
    
    func getSequenceHint() -> String {
        guard let puzzle = currentPuzzle as? NumberSequencePuzzle else { return "" }
        return puzzle.hint
    }
    
    func isIndexMissing(_ index: Int) -> Bool {
        guard let puzzle = currentPuzzle as? NumberSequencePuzzle else { return false }
        return puzzle.missingIndices.contains(index)
    }
    
    func getUserAnswer(at index: Int) -> Int? {
        return userAnswers[index]
    }
    
    // MARK: - Pattern Matching Logic
    func selectPattern(_ patternId: UUID) {
        selectedPatternId = patternId
        
        if let optionId = selectedOptionId {
            makeMatch(patternId: patternId, optionId: optionId)
        }
    }
    
    func selectOption(_ optionId: UUID) {
        selectedOptionId = optionId
        
        if let patternId = selectedPatternId {
            makeMatch(patternId: patternId, optionId: optionId)
        }
    }
    
    private func makeMatch(patternId: UUID, optionId: UUID) {
        guard var puzzle = currentPuzzle as? PatternMatchingPuzzle else { return }
        
        puzzle.makeMatch(patternId: patternId, optionId: optionId)
        matches[patternId] = optionId
        currentPuzzle = puzzle
        
        selectedPatternId = nil
        selectedOptionId = nil
        
        if puzzle.isCompleted {
            finishPuzzle()
        }
    }
    
    func getPatterns() -> [PatternItem] {
        guard let puzzle = currentPuzzle as? PatternMatchingPuzzle else { return [] }
        return puzzle.patterns
    }
    
    func getOptions() -> [PatternItem] {
        guard let puzzle = currentPuzzle as? PatternMatchingPuzzle else { return [] }
        return puzzle.options
    }
    
    func isPatternMatched(_ patternId: UUID) -> Bool {
        return matches[patternId] != nil
    }
    
    func isOptionUsed(_ optionId: UUID) -> Bool {
        return matches.values.contains(optionId)
    }
    
    func isPatternSelected(_ patternId: UUID) -> Bool {
        return selectedPatternId == patternId
    }
    
    func isOptionSelected(_ optionId: UUID) -> Bool {
        return selectedOptionId == optionId
    }
    
    // MARK: - Timer Management
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.timeElapsed += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Data Persistence
    private func savePuzzleResults() {
        guard let puzzle = currentPuzzle else { return }
        
        let scoreEntry = ScoreEntry(
            playerName: playerName,
            score: puzzle.score,
            gameType: .puzzle,
            difficulty: puzzle.difficulty.rawValue,
            date: Date(),
            timeSpent: timeElapsed,
            achievements: newAchievements
        )
        
        dataService.saveScore(scoreEntry)
    }
    
    // MARK: - Achievements
    private func checkForAchievements() {
        guard let puzzle = currentPuzzle else { return }
        
        newAchievements = puzzleDataService.checkForAchievements(puzzle: puzzle, playerName: playerName)
        
        if !newAchievements.isEmpty {
            showAchievements = true
        }
    }
    
    func dismissAchievements() {
        showAchievements = false
        newAchievements = []
    }
    
    // MARK: - Statistics and Progress
    func getProgress() -> Double {
        guard let puzzle = currentPuzzle else { return 0 }
        
        switch puzzle {
        case let wordSearch as WordSearchPuzzle:
            return wordSearch.progress
        case let numberSequence as NumberSequencePuzzle:
            return numberSequence.progress
        case let patternMatching as PatternMatchingPuzzle:
            return patternMatching.progress
        default:
            return 0
        }
    }
    
    func getFormattedTime() -> String {
        let minutes = Int(timeElapsed) / 60
        let seconds = Int(timeElapsed) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func getEstimatedTimeRemaining() -> String {
        guard let puzzle = currentPuzzle else { return "00:00" }
        
        let _ = getProgress() // Suppress unused warning
        let estimatedTotal = puzzle.estimatedTime
        let remaining = max(0, estimatedTotal - timeElapsed)
        
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func getCompletionPercentage() -> Int {
        return Int(getProgress() * 100)
    }
    
    // MARK: - Puzzle Types and Difficulties
    func getAvailablePuzzleTypes() -> [PuzzleType] {
        return PuzzleType.allCases
    }
    
    func getAvailableDifficulties() -> [PuzzleDifficulty] {
        return PuzzleDifficulty.allCases
    }
    
    func getPuzzleTypeDescription(_ type: PuzzleType) -> String {
        return type.description
    }
    
    func getPuzzleTypeIcon(_ type: PuzzleType) -> String {
        return type.icon
    }
    
    // MARK: - Hints and Help
    func getHint() -> String? {
        guard let puzzle = currentPuzzle else { return nil }
        
        switch puzzle {
        case let numberSequence as NumberSequencePuzzle:
            return numberSequence.hint
        case is WordSearchPuzzle:
            return "Look for words horizontally, vertically, and diagonally"
        case is PatternMatchingPuzzle:
            return "Match patterns based on shape, color, and size"
        default:
            return nil
        }
    }
    
    func canShowHint() -> Bool {
        return getHint() != nil
    }
}
