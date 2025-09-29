//
//  AchievementView.swift
//  dafoma_49
//
//  Created by Вячеслав on 9/29/25.
//

import SwiftUI

struct AchievementView: View {
    let achievements: [Achievement]
    let onDismiss: () -> Void
    
    @State private var currentIndex = 0
    @State private var animateAchievement = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    if achievements.count == 1 || currentIndex == achievements.count - 1 {
                        onDismiss()
                    } else {
                        nextAchievement()
                    }
                }
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Text("🎉 Achievement Unlocked! 🎉")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    if achievements.count > 1 {
                        Text("\(currentIndex + 1) of \(achievements.count)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                // Achievement Card
                if currentIndex < achievements.count {
                    AchievementCard(achievement: achievements[currentIndex])
                        .scaleEffect(animateAchievement ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 0.6).repeatCount(2, autoreverses: true), value: animateAchievement)
                }
                
                // Navigation
                HStack(spacing: 20) {
                    if achievements.count > 1 && currentIndex < achievements.count - 1 {
                        Button("Next") {
                            nextAchievement()
                        }
                        .buttonStyle(NeumorphicButtonStyle(
                            backgroundColor: Color(hex: "#FE284A") ?? .red,
                            isPressed: false
                        ))
                    }
                    
                    Button(achievements.count == 1 || currentIndex == achievements.count - 1 ? "Continue" : "Skip") {
                        onDismiss()
                    }
                    .buttonStyle(NeumorphicButtonStyle(
                        backgroundColor: Color(hex: "#1D1F30") ?? .black,
                        isPressed: false
                    ))
                }
            }
            .padding(30)
        }
        .onAppear {
            animateAchievement = true
        }
    }
    
    private func nextAchievement() {
        if currentIndex < achievements.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentIndex += 1
            }
            animateAchievement = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateAchievement = true
            }
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 20) {
            // Rarity Badge
            HStack {
                Spacer()
                RarityBadge(rarity: achievement.rarity)
            }
            
            // Icon
            Image(systemName: achievement.icon)
                .font(.system(size: 60, weight: .light))
                .foregroundColor(Color(hex: achievement.rarity.color))
                .shadow(color: Color(hex: achievement.rarity.color)?.opacity(0.3) ?? .gray, radius: 20)
            
            // Title and Description
            VStack(spacing: 10) {
                Text(achievement.title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(achievement.description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
            
            // Category and Points
            HStack(spacing: 15) {
                CategoryTag(category: achievement.category)
                
                Spacer()
                
                PointsBadge(points: achievement.rarity.points)
            }
            
            // Date
            Text("Unlocked \(achievement.formattedDate)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(hex: "#1D1F30") ?? .black)
                .shadow(
                    color: Color.black.opacity(0.4),
                    radius: 15,
                    x: 8,
                    y: 8
                )
                .shadow(
                    color: Color.white.opacity(0.05),
                    radius: 15,
                    x: -8,
                    y: -8
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(hex: achievement.rarity.color)?.opacity(0.3) ?? .gray,
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
    }
}

struct RarityBadge: View {
    let rarity: AchievementRarity
    
    var body: some View {
        Text(rarity.rawValue.uppercased())
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color(hex: rarity.color) ?? .gray)
            )
    }
}

struct CategoryTag: View {
    let category: AchievementCategory
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: category.icon)
                .font(.system(size: 12))
            Text(category.rawValue)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(.white.opacity(0.8))
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.1))
        )
    }
}

struct PointsBadge: View {
    let points: Int
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill")
                .font(.system(size: 10))
                .foregroundColor(.yellow)
            Text("+\(points)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.3))
        )
    }
}

#Preview {
    AchievementView(
        achievements: [
            Achievement(
                title: "First Steps",
                description: "Complete your first quiz",
                icon: "flag.fill",
                rarity: .common,
                unlockedDate: Date(),
                category: .quiz
            ),
            Achievement(
                title: "Perfect Score",
                description: "Answer all questions correctly",
                icon: "star.fill",
                rarity: .rare,
                unlockedDate: Date(),
                category: .accuracy
            )
        ]
    ) {}
}
