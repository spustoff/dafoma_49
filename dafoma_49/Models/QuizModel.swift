//
//  QuizModel.swift
//  dafoma_49
//
//  Created by Вячеслав on 9/29/25.
//

import Foundation
import CoreData

// MARK: - Quiz Question Model
struct QuizQuestion: Identifiable, Codable {
    var id = UUID()
    let question: String
    let options: [String]
    let correctAnswerIndex: Int
    let category: QuizCategory
    let difficulty: QuizDifficulty
    let explanation: String
}

// MARK: - Quiz Category
enum QuizCategory: String, CaseIterable, Codable {
    case science = "Science"
    case history = "History"
    case geography = "Geography"
    case sports = "Sports"
    case entertainment = "Entertainment"
    case technology = "Technology"
    case literature = "Literature"
    case art = "Art"
    
    var icon: String {
        switch self {
        case .science: return "atom"
        case .history: return "clock"
        case .geography: return "globe"
        case .sports: return "sportscourt"
        case .entertainment: return "tv"
        case .technology: return "laptopcomputer"
        case .literature: return "book"
        case .art: return "paintbrush"
        }
    }
    
    var color: String {
        switch self {
        case .science: return "#4CAF50"
        case .history: return "#FF9800"
        case .geography: return "#2196F3"
        case .sports: return "#F44336"
        case .entertainment: return "#9C27B0"
        case .technology: return "#607D8B"
        case .literature: return "#795548"
        case .art: return "#E91E63"
        }
    }
}

// MARK: - Quiz Difficulty
enum QuizDifficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var multiplier: Double {
        switch self {
        case .easy: return 1.0
        case .medium: return 1.5
        case .hard: return 2.0
        }
    }
}

// MARK: - Quiz Session
struct QuizSession: Identifiable {
    let id = UUID()
    let questions: [QuizQuestion]
    var currentQuestionIndex: Int = 0
    var userAnswers: [Int?] = []
    var score: Int = 0
    var startTime: Date = Date()
    var endTime: Date?
    var isCompleted: Bool = false
    
    var currentQuestion: QuizQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex) / Double(questions.count)
    }
    
    var timeElapsed: TimeInterval {
        return (endTime ?? Date()).timeIntervalSince(startTime)
    }
    
    mutating func submitAnswer(_ answerIndex: Int) {
        if userAnswers.count <= currentQuestionIndex {
            userAnswers.append(answerIndex)
        } else {
            userAnswers[currentQuestionIndex] = answerIndex
        }
        
        if let currentQuestion = currentQuestion,
           answerIndex == currentQuestion.correctAnswerIndex {
            let baseScore = 100
            let difficultyBonus = Int(Double(baseScore) * currentQuestion.difficulty.multiplier)
            score += difficultyBonus
        }
    }
    
    mutating func nextQuestion() {
        currentQuestionIndex += 1
        if currentQuestionIndex >= questions.count {
            isCompleted = true
            endTime = Date()
        }
    }
    
    mutating func previousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
        }
    }
}

// MARK: - Quiz Statistics
struct QuizStatistics {
    let totalQuizzes: Int
    let totalScore: Int
    let averageScore: Double
    let bestScore: Int
    let totalTimeSpent: TimeInterval
    let categoryStats: [QuizCategory: CategoryStats]
}

struct CategoryStats {
    let questionsAnswered: Int
    let correctAnswers: Int
    let averageScore: Double
    
    var accuracy: Double {
        guard questionsAnswered > 0 else { return 0 }
        return Double(correctAnswers) / Double(questionsAnswered)
    }
}
