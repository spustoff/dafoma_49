//
//  QuizViewModel.swift
//  dafoma_49
//
//  Created by Вячеслав on 9/29/25.
//

import Foundation
import SwiftUI

class QuizViewModel: ObservableObject {
    @Published var currentSession: QuizSession?
    @Published var isQuizActive = false
    @Published var showResults = false
    @Published var selectedAnswer: Int?
    @Published var showExplanation = false
    @Published var timeRemaining: TimeInterval = 0
    @Published var newAchievements: [Achievement] = []
    @Published var showAchievements = false
    
    private var timer: Timer?
    private let quizDataService = QuizDataService.shared
    private let dataService = DataService.shared
    
    @AppStorage("playerName") private var playerName: String = "Player"
    
    // MARK: - Quiz Management
    func startQuiz(category: QuizCategory? = nil, difficulty: QuizDifficulty? = nil, questionCount: Int = 10, timeLimit: TimeInterval? = nil) {
        currentSession = quizDataService.generateQuiz(category: category, difficulty: difficulty, questionCount: questionCount)
        currentSession?.startTime = Date()
        isQuizActive = true
        showResults = false
        selectedAnswer = nil
        showExplanation = false
        
        if let timeLimit = timeLimit {
            timeRemaining = timeLimit
            startTimer()
        }
    }
    
    func startAdaptiveQuiz(playerLevel: Int, questionCount: Int = 10) {
        currentSession = quizDataService.generateAdaptiveQuiz(playerLevel: playerLevel, questionCount: questionCount)
        currentSession?.startTime = Date()
        isQuizActive = true
        showResults = false
        selectedAnswer = nil
        showExplanation = false
    }
    
    func submitAnswer(_ answerIndex: Int) {
        guard var session = currentSession else { return }
        
        selectedAnswer = answerIndex
        session.submitAnswer(answerIndex)
        currentSession = session
        
        // Show explanation briefly
        showExplanation = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.showExplanation = false
            self.nextQuestion()
        }
    }
    
    func nextQuestion() {
        guard var session = currentSession else { return }
        
        session.nextQuestion()
        currentSession = session
        selectedAnswer = nil
        
        if session.isCompleted {
            finishQuiz()
        }
    }
    
    func previousQuestion() {
        guard var session = currentSession else { return }
        
        session.previousQuestion()
        currentSession = session
        selectedAnswer = session.userAnswers[session.currentQuestionIndex]
    }
    
    func finishQuiz() {
        guard var session = currentSession else { return }
        
        session.isCompleted = true
        session.endTime = Date()
        currentSession = session
        
        stopTimer()
        saveQuizResults()
        checkForAchievements()
        
        isQuizActive = false
        showResults = true
    }
    
    func restartQuiz() {
        guard let session = currentSession else { return }
        
        let newSession = quizDataService.generateQuiz(
            category: nil,
            difficulty: nil,
            questionCount: session.questions.count
        )
        
        currentSession = newSession
        isQuizActive = true
        showResults = false
        selectedAnswer = nil
        showExplanation = false
        timeRemaining = 0
    }
    
    func exitQuiz() {
        stopTimer()
        currentSession = nil
        isQuizActive = false
        showResults = false
        selectedAnswer = nil
        showExplanation = false
        timeRemaining = 0
    }
    
    // MARK: - Timer Management
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timeUp()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func timeUp() {
        finishQuiz()
    }
    
    // MARK: - Data Persistence
    private func saveQuizResults() {
        guard let session = currentSession else { return }
        
        let scoreEntry = ScoreEntry(
            playerName: playerName,
            score: session.score,
            gameType: .quiz,
            difficulty: getDifficultyString(from: session),
            date: Date(),
            timeSpent: session.timeElapsed,
            achievements: newAchievements
        )
        
        dataService.saveScore(scoreEntry)
    }
    
    private func getDifficultyString(from session: QuizSession) -> String {
        let difficulties = session.questions.map { $0.difficulty }
        let easyCount = difficulties.filter { $0 == .easy }.count
        let mediumCount = difficulties.filter { $0 == .medium }.count
        let hardCount = difficulties.filter { $0 == .hard }.count
        
        if hardCount > mediumCount && hardCount > easyCount {
            return "Hard"
        } else if mediumCount > easyCount {
            return "Medium"
        } else {
            return "Easy"
        }
    }
    
    // MARK: - Achievements
    private func checkForAchievements() {
        guard let session = currentSession else { return }
        
        newAchievements = quizDataService.checkForAchievements(session: session, playerName: playerName)
        
        if !newAchievements.isEmpty {
            showAchievements = true
        }
    }
    
    func dismissAchievements() {
        showAchievements = false
        newAchievements = []
    }
    
    // MARK: - Statistics
    func getAccuracy() -> Double {
        guard let session = currentSession else { return 0 }
        
        let correctAnswers = session.userAnswers.enumerated().filter { index, answer in
            guard let answer = answer, index < session.questions.count else { return false }
            return answer == session.questions[index].correctAnswerIndex
        }.count
        
        return session.userAnswers.count > 0 ? Double(correctAnswers) / Double(session.userAnswers.count) : 0
    }
    
    func getCorrectAnswersCount() -> Int {
        guard let session = currentSession else { return 0 }
        
        return session.userAnswers.enumerated().filter { index, answer in
            guard let answer = answer, index < session.questions.count else { return false }
            return answer == session.questions[index].correctAnswerIndex
        }.count
    }
    
    func getFormattedTime() -> String {
        guard let session = currentSession else { return "00:00" }
        
        let timeElapsed = session.timeElapsed
        let minutes = Int(timeElapsed) / 60
        let seconds = Int(timeElapsed) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func getFormattedTimeRemaining() -> String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Question Navigation
    func canGoToPreviousQuestion() -> Bool {
        guard let session = currentSession else { return false }
        return session.currentQuestionIndex > 0
    }
    
    func canGoToNextQuestion() -> Bool {
        guard let session = currentSession else { return false }
        return session.currentQuestionIndex < session.questions.count - 1
    }
    
    func isAnswerSelected(_ index: Int) -> Bool {
        return selectedAnswer == index
    }
    
    func isCorrectAnswer(_ index: Int) -> Bool {
        guard let session = currentSession,
              let currentQuestion = session.currentQuestion else { return false }
        return index == currentQuestion.correctAnswerIndex
    }
    
    func shouldShowAnswerFeedback() -> Bool {
        return selectedAnswer != nil && showExplanation
    }
    
    // MARK: - Quiz Categories and Difficulties
    func getAvailableCategories() -> [QuizCategory] {
        return QuizCategory.allCases
    }
    
    func getAvailableDifficulties() -> [QuizDifficulty] {
        return QuizDifficulty.allCases
    }
    
    func getQuestionsCount(for category: QuizCategory) -> Int {
        return quizDataService.getQuestionsForCategory(category).count
    }
    
    func getQuestionsCount(for difficulty: QuizDifficulty) -> Int {
        return quizDataService.getQuestionsForDifficulty(difficulty).count
    }
}
