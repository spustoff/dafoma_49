//
//  OnboardingView.swift
//  dafoma_49
//
//  Created by Вячеслав on 9/29/25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("playerName") private var playerName = ""
    @State private var currentPage = 0
    @State private var tempPlayerName = ""
    
    private let onboardingPages = [
        OnboardingPage(
            title: "Welcome to QuizTrek Vada",
            description: "Embark on an exciting journey of knowledge and brain training with our innovative quiz and puzzle platform.",
            imageName: "brain.head.profile",
            color: Color(hex: "#FE284A") ?? .red
        ),
        OnboardingPage(
            title: "Challenge Your Mind",
            description: "Test your knowledge across multiple categories including Science, History, Geography, Technology, and more.",
            imageName: "questionmark.circle.fill",
            color: Color(hex: "#2196F3") ?? .blue
        ),
        OnboardingPage(
            title: "Solve Engaging Puzzles",
            description: "Exercise your logical thinking with word searches, number sequences, pattern matching, and other brain teasers.",
            imageName: "puzzlepiece.fill",
            color: Color(hex: "#4CAF50") ?? .green
        ),
        OnboardingPage(
            title: "Track Your Progress",
            description: "Monitor your improvement, earn achievements, and compete on the global leaderboard.",
            imageName: "chart.line.uptrend.xyaxis",
            color: Color(hex: "#FF9800") ?? .orange
        ),
        OnboardingPage(
            title: "Let's Get Started",
            description: "Enter your name to begin your QuizTrek Vada adventure and start building your knowledge empire.",
            imageName: "person.circle.fill",
            color: Color(hex: "#9C27B0") ?? .purple
        )
    ]
    
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
                    // Page Content
                    TabView(selection: $currentPage) {
                        ForEach(0..<onboardingPages.count, id: \.self) { index in
                            OnboardingPageView(
                                page: onboardingPages[index],
                                isLastPage: index == onboardingPages.count - 1,
                                playerName: $tempPlayerName
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.5), value: currentPage)
                    
                    // Bottom Controls
                    VStack(spacing: 20) {
                        // Page Indicator
                        HStack(spacing: 8) {
                            ForEach(0..<onboardingPages.count, id: \.self) { index in
                                Circle()
                                    .fill(currentPage == index ? 
                                          (Color(hex: "#FE284A") ?? .red) : 
                                          Color.white.opacity(0.3))
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(currentPage == index ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.3), value: currentPage)
                            }
                        }
                        .padding(.bottom, 10)
                        
                        // Navigation Buttons
                        HStack(spacing: 20) {
                            if currentPage > 0 {
                                Button("Previous") {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentPage -= 1
                                    }
                                }
                                .buttonStyle(NeumorphicButtonStyle(
                                    backgroundColor: Color(hex: "#1D1F30") ?? .black,
                                    isPressed: false
                                ))
                            }
                            
                            Spacer()
                            
                            if currentPage < onboardingPages.count - 1 {
                                Button("Next") {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentPage += 1
                                    }
                                }
                                .buttonStyle(NeumorphicButtonStyle(
                                    backgroundColor: Color(hex: "#FE284A") ?? .red,
                                    isPressed: false
                                ))
                            } else {
                                Button("Start Adventure") {
                                    completeOnboarding()
                                }
                                .buttonStyle(NeumorphicButtonStyle(
                                    backgroundColor: Color(hex: "#FE284A") ?? .red,
                                    isPressed: false
                                ))
                                .disabled(tempPlayerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
    }
    
    private func completeOnboarding() {
        let trimmedName = tempPlayerName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty {
            playerName = trimmedName
            hasCompletedOnboarding = true
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isLastPage: Bool
    @Binding var playerName: String
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            Image(systemName: page.imageName)
                .font(.system(size: 80, weight: .light))
                .foregroundColor(page.color)
                .shadow(color: page.color.opacity(0.3), radius: 20, x: 0, y: 10)
            
            // Content
            VStack(spacing: 20) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 20)
            }
            
            // Name Input (only on last page)
            if isLastPage {
                VStack(spacing: 15) {
                    Text("What should we call you?")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                    
                    TextField("Enter your name", text: $playerName)
                        .textFieldStyle(NeumorphicTextFieldStyle())
                        .padding(.horizontal, 40)
                }
                .padding(.top, 20)
            }
            
            Spacer()
        }
        .padding(.horizontal, 30)
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
    let color: Color
}

// MARK: - Neumorphic Styles
struct NeumorphicButtonStyle: ButtonStyle {
    let backgroundColor: Color
    let isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(backgroundColor)
                    .shadow(
                        color: Color.black.opacity(0.3),
                        radius: configuration.isPressed ? 2 : 8,
                        x: configuration.isPressed ? 1 : 4,
                        y: configuration.isPressed ? 1 : 4
                    )
                    .shadow(
                        color: Color.white.opacity(0.1),
                        radius: configuration.isPressed ? 1 : 4,
                        x: configuration.isPressed ? -1 : -2,
                        y: configuration.isPressed ? -1 : -2
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct NeumorphicTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(hex: "#1D1F30") ?? .black)
                    .shadow(
                        color: Color.black.opacity(0.3),
                        radius: 4,
                        x: 2,
                        y: 2
                    )
                    .shadow(
                        color: Color.white.opacity(0.05),
                        radius: 4,
                        x: -2,
                        y: -2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}

#Preview {
    OnboardingView()
}
