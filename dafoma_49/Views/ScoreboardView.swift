//
//  ScoreboardView.swift
//  dafoma_49
//
//  Created by Вячеслав on 9/29/25.
//

import SwiftUI

struct ScoreboardView: View {
    @StateObject private var viewModel = ScoreboardViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(hex: "#1D1F30") ?? .black,
                        Color(hex: "#2A2D47") ?? .gray
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    ScoreboardHeaderView(viewModel: viewModel)
                    
                    // Tab Selection
                    ScoreboardTabView(selectedTab: $selectedTab)
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        LeaderboardView(viewModel: viewModel)
                            .tag(0)
                        
                        PlayerStatsView(viewModel: viewModel)
                            .tag(1)
                        
                        AchievementsView(viewModel: viewModel)
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
        }
        .onAppear {
            viewModel.refreshData()
        }
    }
}

struct ScoreboardHeaderView: View {
    @ObservedObject var viewModel: ScoreboardViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            // Title
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Color(hex: "#FFD700"))
                
                Text("Scoreboard")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    viewModel.refreshData()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Player Rank (if in top 10)
            if viewModel.isPlayerInTopTen(), let rank = viewModel.getPlayerRank() {
                HStack {
                    Text("Your Rank:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("#\(rank)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "#FFD700"))
                    
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 15)
    }
}

struct ScoreboardTabView: View {
    @Binding var selectedTab: Int
    
    private let tabs = [
        ("Leaderboard", "list.number"),
        ("My Stats", "person.circle"),
        ("Achievements", "star.circle")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: tabs[index].1)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(selectedTab == index ? Color(hex: "#FE284A") : .white.opacity(0.6))
                        
                        Text(tabs[index].0)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(selectedTab == index ? Color(hex: "#FE284A") : .white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedTab == index ? (Color(hex: "#FE284A") ?? .red).opacity(0.1) : Color.clear)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 15)
    }
}

struct LeaderboardView: View {
    @ObservedObject var viewModel: ScoreboardViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Game Type Filter
                GameTypeFilterView(viewModel: viewModel)
                
                // Timeframe Filter
                TimeframeFilterView(viewModel: viewModel)
                
                // Leaderboard List
                LazyVStack(spacing: 12) {
                    ForEach(Array(viewModel.getFilteredLeaderboard().enumerated()), id: \.offset) { index, entry in
                        LeaderboardEntryView(entry: entry, rank: index + 1)
                    }
                }
                .padding(.horizontal, 20)
                
                if viewModel.getFilteredLeaderboard().isEmpty {
                    EmptyLeaderboardView()
                }
            }
            .padding(.bottom, 30)
        }
    }
}

struct GameTypeFilterView: View {
    @ObservedObject var viewModel: ScoreboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Game Type")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(GameType.allCases, id: \.self) { gameType in
                        Button(action: {
                            viewModel.changeGameType(gameType)
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: gameType.icon)
                                    .font(.system(size: 14))
                                Text(gameType.rawValue)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(viewModel.selectedGameType == gameType ? .white : .white.opacity(0.7))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(viewModel.selectedGameType == gameType ? 
                                          (viewModel.getGameTypeColor(gameType)) : 
                                          Color.white.opacity(0.1))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct TimeframeFilterView: View {
    @ObservedObject var viewModel: ScoreboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Timeframe")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(LeaderboardTimeframe.allCases, id: \.self) { timeframe in
                        Button(action: {
                            viewModel.changeTimeframe(timeframe)
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: timeframe.icon)
                                    .font(.system(size: 14))
                                Text(timeframe.rawValue)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(viewModel.selectedTimeframe == timeframe ? .white : .white.opacity(0.7))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(viewModel.selectedTimeframe == timeframe ? 
                                          (Color(hex: "#FE284A") ?? .red) : 
                                          Color.white.opacity(0.1))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct LeaderboardEntryView: View {
    let entry: LeaderboardEntry
    let rank: Int
    
    var body: some View {
        HStack(spacing: 15) {
            // Rank
            Text("#\(rank)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(getRankColor())
                .frame(width: 40)
            
            // Player Info
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.playerName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                HStack(spacing: 15) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)
                        Text("\(entry.totalScore)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.blue)
                        Text("\(entry.gamesPlayed)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 10))
                            .foregroundColor(.green)
                        Text(String(format: "%.0f", entry.averageScore))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            
            Spacer()
            
            // Level Badge
            VStack(spacing: 2) {
                Text("Lv.\(entry.level.level)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                
                Text(entry.level.title)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "#FE284A")?.opacity(0.2) ?? .red.opacity(0.2))
            )
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(hex: "#1D1F30") ?? .black)
                .shadow(
                    color: Color.black.opacity(0.3),
                    radius: 5,
                    x: 3,
                    y: 3
                )
                .shadow(
                    color: Color.white.opacity(0.05),
                    radius: 5,
                    x: -3,
                    y: -3
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(
                    rank <= 3 ? getRankColor().opacity(0.3) : Color.clear,
                    lineWidth: 1
                )
        )
    }
    
    private func getRankColor() -> Color {
        switch rank {
        case 1: return Color(hex: "#FFD700") ?? .yellow
        case 2: return Color(hex: "#C0C0C0") ?? .gray
        case 3: return Color(hex: "#CD7F32") ?? .orange
        default: return .white.opacity(0.8)
        }
    }
}

struct EmptyLeaderboardView: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(.white.opacity(0.5))
            
            Text("No scores yet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
            
            Text("Play some games to see the leaderboard!")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

struct PlayerStatsView: View {
    @ObservedObject var viewModel: ScoreboardViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let stats = viewModel.playerStatistics {
                    // Level Card
                    PlayerLevelCard(stats: stats)
                    
                    // Overall Stats
                    PlayerOverallStatsCard(stats: stats, viewModel: viewModel)
                    
                    // Game Type Stats
                    PlayerGameTypeStatsCard(stats: stats)
                    
                    // Recent Activity
                    PlayerRecentActivityCard(viewModel: viewModel)
                } else {
                    EmptyStatsView()
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
}

struct PlayerLevelCard: View {
    let stats: PlayerStatistics
    
    var body: some View {
        VStack(spacing: 15) {
            // Level Info
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Level \(stats.level.level)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(stats.level.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#FE284A"))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 5) {
                    Text("\(stats.level.experiencePoints)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("/ \(stats.level.experienceToNext) XP")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress to Next Level")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("\(Int(stats.level.progress * 100))%")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "#FE284A"))
                }
                
                ProgressView(value: stats.level.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#FE284A") ?? .red))
                    .scaleEffect(y: 2)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "#1D1F30") ?? .black)
                .shadow(
                    color: Color.black.opacity(0.3),
                    radius: 10,
                    x: 5,
                    y: 5
                )
                .shadow(
                    color: Color.white.opacity(0.05),
                    radius: 10,
                    x: -5,
                    y: -5
                )
        )
    }
}

struct PlayerOverallStatsCard: View {
    let stats: PlayerStatistics
    let viewModel: ScoreboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(Color(hex: "#FE284A"))
                Text("Overall Statistics")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                StatCard(title: "Total Score", value: "\(stats.totalScore)", icon: "star.fill", color: .yellow)
                StatCard(title: "Games Played", value: "\(stats.totalGamesPlayed)", icon: "gamecontroller.fill", color: .blue)
                StatCard(title: "Average Score", value: viewModel.getFormattedAverageScore(), icon: "chart.line.uptrend.xyaxis", color: .green)
                StatCard(title: "Best Score", value: "\(stats.bestScore)", icon: "trophy.fill", color: .orange)
                StatCard(title: "Time Played", value: viewModel.getFormattedTotalTime(), icon: "clock.fill", color: .purple)
                StatCard(title: "Achievements", value: "\(stats.achievements.count)", icon: "rosette", color: .pink)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "#1D1F30") ?? .black)
                .shadow(
                    color: Color.black.opacity(0.3),
                    radius: 10,
                    x: 5,
                    y: 5
                )
                .shadow(
                    color: Color.white.opacity(0.05),
                    radius: 10,
                    x: -5,
                    y: -5
                )
        )
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct PlayerGameTypeStatsCard: View {
    let stats: PlayerStatistics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "gamecontroller.fill")
                    .foregroundColor(Color(hex: "#FE284A"))
                Text("Game Type Breakdown")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(spacing: 12) {
                GameTypeStatRow(gameType: .quiz, stats: stats.quizStats)
                GameTypeStatRow(gameType: .puzzle, stats: stats.puzzleStats)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "#1D1F30") ?? .black)
                .shadow(
                    color: Color.black.opacity(0.3),
                    radius: 10,
                    x: 5,
                    y: 5
                )
                .shadow(
                    color: Color.white.opacity(0.05),
                    radius: 10,
                    x: -5,
                    y: -5
                )
        )
    }
}

struct GameTypeStatRow: View {
    let gameType: GameType
    let stats: Any?
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: gameType.icon)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: gameType.color))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(gameType.rawValue)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                if let quizStats = stats as? QuizStatistics {
                    Text("\(quizStats.totalQuizzes) games • \(quizStats.totalScore) points")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                } else if let puzzleStats = stats as? PuzzleStatistics {
                    Text("\(puzzleStats.totalPuzzlesSolved) puzzles • \(puzzleStats.totalScore) points")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                } else {
                    Text("No games played yet")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct PlayerRecentActivityCard: View {
    let viewModel: ScoreboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(Color(hex: "#FE284A"))
                Text("Recent Activity")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            
            if viewModel.recentScores.isEmpty {
                Text("No recent activity")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.recentScores.prefix(5), id: \.id) { score in
                        RecentActivityRow(score: score)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "#1D1F30") ?? .black)
                .shadow(
                    color: Color.black.opacity(0.3),
                    radius: 10,
                    x: 5,
                    y: 5
                )
                .shadow(
                    color: Color.white.opacity(0.05),
                    radius: 10,
                    x: -5,
                    y: -5
                )
        )
    }
}

struct RecentActivityRow: View {
    let score: ScoreEntry
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: score.gameType.icon)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: score.gameType.color))
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(score.gameType.rawValue) • \(score.difficulty)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                
                Text(score.formattedDate)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Text("\(score.score)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "#FE284A"))
        }
        .padding(.vertical, 4)
    }
}

struct EmptyStatsView: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "person.circle")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(.white.opacity(0.5))
            
            Text("No statistics yet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
            
            Text("Play some games to see your stats!")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

struct AchievementsView: View {
    @ObservedObject var viewModel: ScoreboardViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.achievements.isEmpty {
                    EmptyAchievementsView()
                } else {
                    // Achievement Summary
                    AchievementSummaryCard(viewModel: viewModel)
                    
                    // Achievements by Category
                    let achievementsByCategory = viewModel.getAchievementsByCategory()
                    
                    ForEach(AchievementCategory.allCases, id: \.self) { category in
                        if let categoryAchievements = achievementsByCategory[category], !categoryAchievements.isEmpty {
                            AchievementCategorySection(category: category, achievements: categoryAchievements)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
}

struct AchievementSummaryCard: View {
    let viewModel: ScoreboardViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "rosette")
                    .foregroundColor(Color(hex: "#FFD700"))
                Text("Achievement Summary")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            
            HStack(spacing: 30) {
                VStack(spacing: 5) {
                    Text("\(viewModel.achievements.count)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Total")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                VStack(spacing: 5) {
                    Text("\(viewModel.getTotalAchievementPoints())")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "#FFD700"))
                    
                    Text("Points")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // Rarity breakdown
                let achievementsByRarity = viewModel.getAchievementsByRarity()
                
                VStack(spacing: 5) {
                    HStack(spacing: 8) {
                        ForEach(AchievementRarity.allCases, id: \.self) { rarity in
                            if let count = achievementsByRarity[rarity]?.count, count > 0 {
                                VStack(spacing: 2) {
                                    Text("\(count)")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(Color(hex: rarity.color))
                                    
                                    Circle()
                                        .fill(Color(hex: rarity.color) ?? .gray)
                                        .frame(width: 8, height: 8)
                                }
                            }
                        }
                    }
                    
                    Text("By Rarity")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "#1D1F30") ?? .black)
                .shadow(
                    color: Color.black.opacity(0.3),
                    radius: 10,
                    x: 5,
                    y: 5
                )
                .shadow(
                    color: Color.white.opacity(0.05),
                    radius: 10,
                    x: -5,
                    y: -5
                )
        )
    }
}

struct AchievementCategorySection: View {
    let category: AchievementCategory
    let achievements: [Achievement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: category.icon)
                    .foregroundColor(Color(hex: "#FE284A"))
                Text(category.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text("\(achievements.count)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(achievements, id: \.id) { achievement in
                    AchievementItemView(achievement: achievement)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "#1D1F30") ?? .black)
                .shadow(
                    color: Color.black.opacity(0.3),
                    radius: 10,
                    x: 5,
                    y: 5
                )
                .shadow(
                    color: Color.white.opacity(0.05),
                    radius: 10,
                    x: -5,
                    y: -5
                )
        )
    }
}

struct AchievementItemView: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 10) {
            // Icon and Rarity
            ZStack {
                Image(systemName: achievement.icon)
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: achievement.rarity.color))
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        RarityBadge(rarity: achievement.rarity)
                    }
                }
            }
            .frame(height: 40)
            
            // Title and Description
            VStack(spacing: 4) {
                Text(achievement.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(achievement.description)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            
            // Date and Points
            HStack {
                Text(achievement.formattedDate)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                
                Spacer()
                
                PointsBadge(points: achievement.rarity.points)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: achievement.rarity.color)?.opacity(0.1) ?? .gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(hex: achievement.rarity.color)?.opacity(0.3) ?? .gray, lineWidth: 1)
                )
        )
    }
}

struct EmptyAchievementsView: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "star.circle")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(.white.opacity(0.5))
            
            Text("No achievements yet")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
            
            Text("Complete quizzes and puzzles to unlock achievements!")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

#Preview {
    ScoreboardView()
}
