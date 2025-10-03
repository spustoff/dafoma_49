//
//  ContentView.swift
//  dafoma_49
//
//  Created by Вячеслав on 9/29/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("playerName") private var playerName = ""
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView()
            } else {
                MainTabView(selectedTab: $selectedTab)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct MainTabView: View {
    @Binding var selectedTab: Int
    
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
                    // Main Content
                    TabView(selection: $selectedTab) {
                        HomeView()
                            .tag(0)
                        
                        QuizView()
                            .tag(1)
                        
                        PuzzleView()
                            .tag(2)
                        
                        ScoreboardView()
                            .tag(3)
                        
                        SettingsView()
                            .tag(4)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // Custom Tab Bar
                    CustomTabBar(selectedTab: $selectedTab)
                }
            }
        }
    }
}

struct HomeView: View {
    @AppStorage("playerName") private var playerName = "Player"
    @State private var showQuickQuiz = false
    @State private var showRandomPuzzle = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Welcome Header
                VStack(spacing: 15) {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Welcome back,")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text(playerName)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        // App Logo
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 40, weight: .light))
                            .foregroundColor(Color(hex: "#FE284A"))
                            .shadow(color: Color(hex: "#FE284A")?.opacity(0.3) ?? .red, radius: 10)
                    }
                    
                    Text("Ready to challenge your mind?")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Quick Actions
                VStack(spacing: 20) {
                    Text("Quick Start")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 15) {
                        QuickActionButton(
                            title: "Quick Quiz",
                            subtitle: "10 random questions",
                            icon: "bolt.fill",
                            color: Color(hex: "#FE284A") ?? .red,
                            action: { showQuickQuiz = true }
                        )
                        
                        QuickActionButton(
                            title: "Random Puzzle",
                            subtitle: "Surprise brain teaser",
                            icon: "shuffle",
                            color: Color(hex: "#4CAF50") ?? .green,
                            action: { showRandomPuzzle = true }
                        )
                    }
                    .padding(.horizontal, 20)
                }
                
                // Statistics Overview
                PlayerStatsOverview()
                
                // Recent Achievements
                RecentAchievementsView()
                
                Spacer(minLength: 100) // Space for tab bar
            }
        }
        .sheet(isPresented: $showQuickQuiz) {
            QuizView()
        }
        .sheet(isPresented: $showRandomPuzzle) {
            PuzzleView()
        }
    }
}

struct QuickActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(color.opacity(0.2))
                    )
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: "#1D1F30") ?? .black)
                    .shadow(
                        color: Color.black.opacity(0.3),
                        radius: 8,
                        x: 4,
                        y: 4
                    )
                    .shadow(
                        color: Color.white.opacity(0.05),
                        radius: 8,
                        x: -4,
                        y: -4
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PlayerStatsOverview: View {
    @StateObject private var viewModel = ScoreboardViewModel()
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Your Progress")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                NavigationLink(destination: ScoreboardView()) {
                    Text("View All")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "#FE284A"))
                }
            }
            .padding(.horizontal, 20)
            
            if let stats = viewModel.playerStatistics {
                HStack(spacing: 15) {
                    StatOverviewCard(
                        title: "Level",
                        value: "\(stats.level.level)",
                        subtitle: stats.level.title,
                        color: Color(hex: "#FE284A") ?? .red
                    )
                    
                    StatOverviewCard(
                        title: "Total Score",
                        value: "\(stats.totalScore)",
                        subtitle: "Points earned",
                        color: Color(hex: "#FFD700") ?? .yellow
                    )
                    
                    StatOverviewCard(
                        title: "Games",
                        value: "\(stats.totalGamesPlayed)",
                        subtitle: "Completed",
                        color: Color(hex: "#4CAF50") ?? .green
                    )
                }
                .padding(.horizontal, 20)
            } else {
                Text("Play your first game to see stats!")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 20)
            }
        }
        .onAppear {
            viewModel.refreshData()
        }
    }
}

struct StatOverviewCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
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
    }
}

struct RecentAchievementsView: View {
    @StateObject private var viewModel = ScoreboardViewModel()
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Recent Achievements")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if !viewModel.achievements.isEmpty {
                    NavigationLink(destination: ScoreboardView()) {
                        Text("View All")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#FE284A"))
                    }
                }
            }
            .padding(.horizontal, 20)
            
            if viewModel.achievements.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "star.circle")
                        .font(.system(size: 30, weight: .light))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("No achievements yet")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("Complete games to unlock achievements!")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 30)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(viewModel.achievements.prefix(5), id: \.id) { achievement in
                            RecentAchievementCard(achievement: achievement)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .onAppear {
            viewModel.refreshData()
        }
    }
}

struct RecentAchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: achievement.icon)
                .font(.system(size: 24))
                .foregroundColor(Color(hex: achievement.rarity.color))
            
            Text(achievement.title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            RarityBadge(rarity: achievement.rarity)
        }
        .frame(width: 100, height: 100)
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
                .stroke(Color(hex: achievement.rarity.color)?.opacity(0.3) ?? .gray, lineWidth: 1)
        )
    }
}

struct SettingsView: View {
    @AppStorage("playerName") private var playerName = "Player"
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @State private var showingNameAlert = false
    @State private var newPlayerName = ""
    @State private var showingResetAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 40, weight: .light))
                        .foregroundColor(Color(hex: "#FE284A"))
                    
                    Text("Settings")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.top, 20)
                
                // Player Settings
                SettingsSection(title: "Player") {
                    SettingsRow(
                        title: "Player Name",
                        subtitle: playerName,
                        icon: "person.circle",
                        action: {
                            newPlayerName = playerName
                            showingNameAlert = true
                        }
                    )
                }
                
                // App Settings
                SettingsSection(title: "App") {
                    SettingsRow(
                        title: "Show Onboarding",
                        subtitle: "View the welcome tutorial again",
                        icon: "info.circle",
                        action: {
                            hasCompletedOnboarding = false
                        }
                    )
                    
                    SettingsRow(
                        title: "Reset All Data",
                        subtitle: "Clear all scores and achievements",
                        icon: "trash.circle",
                        isDestructive: true,
                        action: {
                            showingResetAlert = true
                        }
                    )
                }
                
                Spacer(minLength: 100) // Space for tab bar
            }
            .padding(.horizontal, 20)
        }
        .alert("Change Player Name", isPresented: $showingNameAlert) {
            TextField("Player Name", text: $newPlayerName)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                if !newPlayerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    playerName = newPlayerName.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        } message: {
            Text("Enter your new player name")
        }
        .alert("Reset All Data", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                DataService.shared.resetAllData()
            }
        } message: {
            Text("This will permanently delete all your scores, achievements, and statistics. This action cannot be undone.")
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 1) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(hex: "#1D1F30") ?? .black)
                    .shadow(
                        color: Color.black.opacity(0.3),
                        radius: 8,
                        x: 4,
                        y: 4
                    )
                    .shadow(
                        color: Color.white.opacity(0.05),
                        radius: 8,
                        x: -4,
                        y: -4
                    )
            )
        }
    }
}

struct SettingsRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let isDestructive: Bool
    let action: () -> Void
    
    init(title: String, subtitle: String, icon: String, isDestructive: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.isDestructive = isDestructive
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isDestructive ? .red : Color(hex: "#FE284A"))
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isDestructive ? .red : .white)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    private let tabs = [
        ("Home", "house.fill"),
        ("Quiz", "brain.head.profile"),
        ("Puzzle", "puzzlepiece.fill"),
        ("Scores", "trophy.fill"),
        ("Settings", "gearshape.fill")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 4) {
                        let isSelected = selectedTab == index
                        let iconSize: CGFloat = isSelected ? 20 : 18
                        let iconColor = isSelected ? (Color(hex: "#FE284A") ?? .red) : .white.opacity(0.6)
                        let textColor = isSelected ? (Color(hex: "#FE284A") ?? .red) : .white.opacity(0.6)
                        
                        Image(systemName: tabs[index].1)
                            .font(.system(size: iconSize, weight: .medium))
                            .foregroundColor(iconColor)
                        
                        Text(tabs[index].0)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(textColor)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedTab == index ? (Color(hex: "#FE284A") ?? .red).opacity(0.1) : Color.clear)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "#1D1F30") ?? .black)
                .shadow(
                    color: Color.black.opacity(0.3),
                    radius: 10,
                    x: 0,
                    y: -5
                )
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}

#Preview {
    ContentView()
}
