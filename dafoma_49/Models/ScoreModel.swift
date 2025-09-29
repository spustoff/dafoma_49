//
//  ScoreModel.swift
//  dafoma_49
//
//  Created by Вячеслав on 9/29/25.
//

import Foundation
import CoreData

// MARK: - Score Entry
struct ScoreEntry: Identifiable, Codable {
    var id = UUID()
    let playerName: String
    let score: Int
    let gameType: GameType
    let difficulty: String
    let date: Date
    let timeSpent: TimeInterval
    let achievements: [Achievement]
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var formattedTime: String {
        let minutes = Int(timeSpent) / 60
        let seconds = Int(timeSpent) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Game Type
enum GameType: String, CaseIterable, Codable {
    case quiz = "Quiz"
    case puzzle = "Puzzle"
    case mixed = "Mixed"
    
    var icon: String {
        switch self {
        case .quiz: return "questionmark.circle"
        case .puzzle: return "puzzlepiece"
        case .mixed: return "star.circle"
        }
    }
    
    var color: String {
        switch self {
        case .quiz: return "#2196F3"
        case .puzzle: return "#4CAF50"
        case .mixed: return "#FF9800"
        }
    }
}

// MARK: - Achievement
struct Achievement: Identifiable, Codable {
    var id = UUID()
    let title: String
    let description: String
    let icon: String
    let rarity: AchievementRarity
    let unlockedDate: Date
    let category: AchievementCategory
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: unlockedDate)
    }
}

// MARK: - Achievement Rarity
enum AchievementRarity: String, CaseIterable, Codable {
    case common = "Common"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    
    var color: String {
        switch self {
        case .common: return "#9E9E9E"
        case .rare: return "#2196F3"
        case .epic: return "#9C27B0"
        case .legendary: return "#FF9800"
        }
    }
    
    var points: Int {
        switch self {
        case .common: return 10
        case .rare: return 25
        case .epic: return 50
        case .legendary: return 100
        }
    }
}

// MARK: - Achievement Category
enum AchievementCategory: String, CaseIterable, Codable {
    case quiz = "Quiz Master"
    case puzzle = "Puzzle Solver"
    case speed = "Speed Demon"
    case accuracy = "Perfectionist"
    case dedication = "Dedicated Player"
    case exploration = "Explorer"
    
    var icon: String {
        switch self {
        case .quiz: return "brain.head.profile"
        case .puzzle: return "puzzlepiece.extension"
        case .speed: return "bolt"
        case .accuracy: return "target"
        case .dedication: return "calendar"
        case .exploration: return "map"
        }
    }
}

// MARK: - Leaderboard
struct Leaderboard {
    let entries: [LeaderboardEntry]
    let gameType: GameType
    let timeframe: LeaderboardTimeframe
    let lastUpdated: Date
    
    var topPlayers: [LeaderboardEntry] {
        return Array(entries.prefix(10))
    }
}

// MARK: - Leaderboard Entry
struct LeaderboardEntry: Identifiable, Codable {
    var id = UUID()
    let rank: Int
    let playerName: String
    let totalScore: Int
    let gamesPlayed: Int
    let averageScore: Double
    let bestScore: Int
    let totalTimeSpent: TimeInterval
    let achievements: [Achievement]
    let level: PlayerLevel
    
    var formattedTotalTime: String {
        let hours = Int(totalTimeSpent) / 3600
        let minutes = Int(totalTimeSpent) % 3600 / 60
        return String(format: "%02d:%02d", hours, minutes)
    }
}

// MARK: - Leaderboard Timeframe
enum LeaderboardTimeframe: String, CaseIterable, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case allTime = "All Time"
    
    var icon: String {
        switch self {
        case .daily: return "sun.max"
        case .weekly: return "calendar.badge.clock"
        case .monthly: return "calendar"
        case .allTime: return "infinity"
        }
    }
}

// MARK: - Player Level
struct PlayerLevel: Codable {
    let level: Int
    let title: String
    let experiencePoints: Int
    let experienceToNext: Int
    let totalExperience: Int
    
    var progress: Double {
        guard experienceToNext > 0 else { return 1.0 }
        return Double(experiencePoints) / Double(experienceToNext)
    }
    
    static func calculateLevel(from totalExperience: Int) -> PlayerLevel {
        let level = max(1, Int(sqrt(Double(totalExperience) / 100)))
        let experienceForCurrentLevel = level * level * 100
        let experienceForNextLevel = (level + 1) * (level + 1) * 100
        let experiencePoints = totalExperience - experienceForCurrentLevel
        let experienceToNext = experienceForNextLevel - experienceForCurrentLevel
        
        let title = PlayerLevel.titleForLevel(level)
        
        return PlayerLevel(
            level: level,
            title: title,
            experiencePoints: experiencePoints,
            experienceToNext: experienceToNext,
            totalExperience: totalExperience
        )
    }
    
    static func titleForLevel(_ level: Int) -> String {
        switch level {
        case 1...5: return "Novice"
        case 6...10: return "Apprentice"
        case 11...20: return "Scholar"
        case 21...35: return "Expert"
        case 36...50: return "Master"
        case 51...75: return "Grandmaster"
        case 76...100: return "Legend"
        default: return "Mythic"
        }
    }
}

// MARK: - Player Statistics
struct PlayerStatistics {
    let totalGamesPlayed: Int
    let totalScore: Int
    let totalTimeSpent: TimeInterval
    let averageScore: Double
    let bestScore: Int
    let currentStreak: Int
    let longestStreak: Int
    let achievements: [Achievement]
    let level: PlayerLevel
    let quizStats: QuizStatistics?
    let puzzleStats: PuzzleStatistics?
    
    var achievementPoints: Int {
        return achievements.reduce(0) { $0 + $1.rarity.points }
    }
    
    var gamesPerDay: Double {
        let daysSinceFirstGame = max(1, Calendar.current.dateComponents([.day], from: Date().addingTimeInterval(-totalTimeSpent), to: Date()).day ?? 1)
        return Double(totalGamesPlayed) / Double(daysSinceFirstGame)
    }
}

// MARK: - Score Comparison
struct ScoreComparison {
    let currentScore: Int
    let previousBest: Int
    let improvement: Int
    let percentageImprovement: Double
    let isNewRecord: Bool
    
    init(currentScore: Int, previousBest: Int) {
        self.currentScore = currentScore
        self.previousBest = previousBest
        self.improvement = currentScore - previousBest
        self.percentageImprovement = previousBest > 0 ? Double(improvement) / Double(previousBest) * 100 : 0
        self.isNewRecord = currentScore > previousBest
    }
}
