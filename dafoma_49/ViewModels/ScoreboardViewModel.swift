//
//  ScoreboardViewModel.swift
//  dafoma_49
//
//  Created by Вячеслав on 9/29/25.
//

import Foundation
import SwiftUI

class ScoreboardViewModel: ObservableObject {
    @Published var leaderboard: [LeaderboardEntry] = []
    @Published var playerStatistics: PlayerStatistics?
    @Published var selectedGameType: GameType = .quiz
    @Published var selectedTimeframe: LeaderboardTimeframe = .allTime
    @Published var isLoading = false
    @Published var showPlayerStats = false
    @Published var achievements: [Achievement] = []
    @Published var recentScores: [ScoreEntry] = []
    
    private let dataService = DataService.shared
    private let quizDataService = QuizDataService.shared
    private let puzzleDataService = PuzzleDataService.shared
    
    @AppStorage("playerName") private var playerName: String = "Player"
    
    init() {
        loadData()
    }
    
    // MARK: - Data Loading
    func loadData() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.loadLeaderboard()
            self.loadPlayerStatistics()
            self.loadAchievements()
            self.loadRecentScores()
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    private func loadLeaderboard() {
        let scores = dataService.fetchScores(gameType: selectedGameType)
        let groupedScores = Dictionary(grouping: scores) { $0.playerName }
        
        var entries: [LeaderboardEntry] = []
        
        for (playerName, playerScores) in groupedScores {
            let totalScore = playerScores.reduce(0) { $0 + $1.score }
            let gamesPlayed = playerScores.count
            let averageScore = Double(totalScore) / Double(gamesPlayed)
            let bestScore = playerScores.max(by: { $0.score < $1.score })?.score ?? 0
            let totalTimeSpent = playerScores.reduce(0) { $0 + $1.timeSpent }
            let playerAchievements = dataService.fetchAchievements(for: playerName)
            let totalExperience = totalScore + playerAchievements.reduce(0) { $0 + $1.rarity.points }
            let level = PlayerLevel.calculateLevel(from: totalExperience)
            
            let entry = LeaderboardEntry(
                rank: 0, // Will be set after sorting
                playerName: playerName,
                totalScore: totalScore,
                gamesPlayed: gamesPlayed,
                averageScore: averageScore,
                bestScore: bestScore,
                totalTimeSpent: totalTimeSpent,
                achievements: playerAchievements,
                level: level
            )
            
            entries.append(entry)
        }
        
        // Sort by total score and assign ranks
        entries.sort { $0.totalScore > $1.totalScore }
        for index in entries.indices {
            let entry = entries[index]
            entries[index] = LeaderboardEntry(
                rank: index + 1,
                playerName: entry.playerName,
                totalScore: entry.totalScore,
                gamesPlayed: entry.gamesPlayed,
                averageScore: entry.averageScore,
                bestScore: entry.bestScore,
                totalTimeSpent: entry.totalTimeSpent,
                achievements: entry.achievements,
                level: entry.level
            )
        }
        
        DispatchQueue.main.async {
            self.leaderboard = entries
        }
    }
    
    private func loadPlayerStatistics() {
        let _ = dataService.getPlayerStatistics(for: playerName) // Suppress unused warning
        let quizStats = quizDataService.getQuizStatistics(for: playerName)
        let puzzleStats = puzzleDataService.getPuzzleStatistics(for: playerName)
        
        let updatedStats = PlayerStatistics(
            totalGamesPlayed: 0,
            totalScore: 0,
            totalTimeSpent: 0,
            averageScore: 0,
            bestScore: 0,
            currentStreak: 0,
            longestStreak: 0,
            achievements: [],
            level: PlayerLevel.calculateLevel(from: 0),
            quizStats: quizStats,
            puzzleStats: puzzleStats
        )
        
        DispatchQueue.main.async {
            self.playerStatistics = updatedStats
        }
    }
    
    private func loadAchievements() {
        let playerAchievements = dataService.fetchAchievements(for: playerName)
        
        DispatchQueue.main.async {
            self.achievements = playerAchievements
        }
    }
    
    private func loadRecentScores() {
        let scores = dataService.fetchScores(limit: 10)
        
        DispatchQueue.main.async {
            self.recentScores = scores
        }
    }
    
    // MARK: - Filtering and Sorting
    func changeGameType(_ gameType: GameType) {
        selectedGameType = gameType
        loadLeaderboard()
    }
    
    func changeTimeframe(_ timeframe: LeaderboardTimeframe) {
        selectedTimeframe = timeframe
        loadLeaderboard()
    }
    
    func getFilteredLeaderboard() -> [LeaderboardEntry] {
        var filtered = leaderboard
        
        // Apply timeframe filter
        switch selectedTimeframe {
        case .daily:
            // Filter for last 24 hours - simplified for now
            break
        case .weekly:
            // Filter for last 7 days - simplified for now
            break
        case .monthly:
            // Filter for last 30 days - simplified for now
            break
        case .allTime:
            // No filter needed
            break
        }
        
        return Array(filtered.prefix(10)) // Top 10
    }
    
    // MARK: - Player Ranking
    func getPlayerRank() -> Int? {
        guard playerStatistics != nil else { return nil }
        
        return leaderboard.first { $0.playerName == playerName }?.rank
    }
    
    func getPlayerRankSuffix() -> String {
        guard let rank = getPlayerRank() else { return "" }
        
        switch rank % 10 {
        case 1 where rank % 100 != 11:
            return "st"
        case 2 where rank % 100 != 12:
            return "nd"
        case 3 where rank % 100 != 13:
            return "rd"
        default:
            return "th"
        }
    }
    
    func isPlayerInTopTen() -> Bool {
        guard let rank = getPlayerRank() else { return false }
        return rank <= 10
    }
    
    // MARK: - Statistics Formatting
    func getFormattedTotalTime() -> String {
        guard let stats = playerStatistics else { return "00:00:00" }
        
        let hours = Int(stats.totalTimeSpent) / 3600
        let minutes = Int(stats.totalTimeSpent) % 3600 / 60
        let seconds = Int(stats.totalTimeSpent) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func getFormattedAverageScore() -> String {
        guard let stats = playerStatistics else { return "0" }
        return String(format: "%.1f", stats.averageScore)
    }
    
    func getAchievementsByCategory() -> [AchievementCategory: [Achievement]] {
        return Dictionary(grouping: achievements) { $0.category }
    }
    
    func getAchievementsByRarity() -> [AchievementRarity: [Achievement]] {
        return Dictionary(grouping: achievements) { $0.rarity }
    }
    
    func getTotalAchievementPoints() -> Int {
        return achievements.reduce(0) { $0 + $1.rarity.points }
    }
    
    // MARK: - Comparison and Progress
    func getScoreComparison(for gameType: GameType) -> ScoreComparison? {
        let scores = dataService.fetchScores(gameType: gameType).filter { $0.playerName == playerName }
        
        guard let latestScore = scores.first,
              scores.count > 1 else { return nil }
        
        let previousBest = scores.dropFirst().max(by: { $0.score < $1.score })?.score ?? 0
        
        return ScoreComparison(currentScore: latestScore.score, previousBest: previousBest)
    }
    
    func getProgressToNextLevel() -> Double {
        guard let stats = playerStatistics else { return 0 }
        return stats.level.progress
    }
    
    func getExperienceToNextLevel() -> Int {
        guard let stats = playerStatistics else { return 0 }
        return stats.level.experienceToNext - stats.level.experiencePoints
    }
    
    // MARK: - Data Management
    func refreshData() {
        loadData()
    }
    
    func resetPlayerData() {
        dataService.resetAllData()
        loadData()
    }
    
    // MARK: - Sharing and Export
    func getShareableStats() -> String {
        guard let stats = playerStatistics else { return "" }
        
        return """
        🎯 QuizTrek Vada Stats
        
        Level: \(stats.level.level) (\(stats.level.title))
        Total Score: \(stats.totalScore)
        Games Played: \(stats.totalGamesPlayed)
        Average Score: \(getFormattedAverageScore())
        Best Score: \(stats.bestScore)
        Achievements: \(stats.achievements.count)
        
        #QuizTrekVada #BrainTraining
        """
    }
    
    // MARK: - UI Helpers
    func togglePlayerStats() {
        showPlayerStats.toggle()
    }
    
    func getGameTypeIcon(_ gameType: GameType) -> String {
        return gameType.icon
    }
    
    func getGameTypeColor(_ gameType: GameType) -> Color {
        return Color(hex: gameType.color) ?? .blue
    }
    
    func getTimeframeIcon(_ timeframe: LeaderboardTimeframe) -> String {
        return timeframe.icon
    }
    
    func getRarityColor(_ rarity: AchievementRarity) -> Color {
        return Color(hex: rarity.color) ?? .gray
    }
    
    func getCategoryIcon(_ category: AchievementCategory) -> String {
        return category.icon
    }
}

// MARK: - Color Extension
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
