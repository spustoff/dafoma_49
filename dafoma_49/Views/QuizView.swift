//
//  QuizView.swift
//  dafoma_49
//
//  Created by Вячеслав on 9/29/25.
//

import SwiftUI

struct QuizView: View {
    @StateObject private var viewModel = QuizViewModel()
    @State private var showQuizSetup = false
    @State private var selectedCategory: QuizCategory?
    @State private var selectedDifficulty: QuizDifficulty?
    @State private var questionCount = 10
    @State private var showAchievementSheet = false
    
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
                
                if viewModel.isQuizActive {
                    QuizActiveView(viewModel: viewModel)
                } else if viewModel.showResults {
                    QuizResultsView(viewModel: viewModel)
                } else {
                    QuizMenuView(
                        viewModel: viewModel,
                        showQuizSetup: $showQuizSetup,
                        selectedCategory: $selectedCategory,
                        selectedDifficulty: $selectedDifficulty,
                        questionCount: $questionCount
                    )
                }
            }
        }
        .sheet(isPresented: $showQuizSetup) {
            QuizSetupView(
                selectedCategory: $selectedCategory,
                selectedDifficulty: $selectedDifficulty,
                questionCount: $questionCount,
                onStartQuiz: { category, difficulty, count in
                    viewModel.startQuiz(
                        category: category,
                        difficulty: difficulty,
                        questionCount: count
                    )
                    showQuizSetup = false
                }
            )
        }
        .sheet(isPresented: $viewModel.showAchievements) {
            AchievementView(achievements: viewModel.newAchievements) {
                viewModel.dismissAchievements()
            }
        }
    }
}

struct QuizMenuView: View {
    @ObservedObject var viewModel: QuizViewModel
    @Binding var showQuizSetup: Bool
    @Binding var selectedCategory: QuizCategory?
    @Binding var selectedDifficulty: QuizDifficulty?
    @Binding var questionCount: Int
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 10) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(Color(hex: "#FE284A"))
                    .shadow(color: Color(hex: "#FE284A")?.opacity(0.3) ?? .red, radius: 20)
                
                Text("Quiz Challenge")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Test your knowledge across various topics")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 50)
            
            Spacer()
            
            // Quick Start Options
            VStack(spacing: 20) {
                QuizMenuButton(
                    title: "Quick Quiz",
                    subtitle: "10 random questions",
                    icon: "bolt.fill",
                    color: Color(hex: "#FE284A") ?? .red
                ) {
                    viewModel.startQuiz(questionCount: 10)
                }
                
                QuizMenuButton(
                    title: "Custom Quiz",
                    subtitle: "Choose category & difficulty",
                    icon: "slider.horizontal.3",
                    color: Color(hex: "#2196F3") ?? .blue
                ) {
                    showQuizSetup = true
                }
                
                QuizMenuButton(
                    title: "Adaptive Quiz",
                    subtitle: "Questions match your level",
                    icon: "brain",
                    color: Color(hex: "#4CAF50") ?? .green
                ) {
                    // Get player level from statistics
                    let playerStats = DataService.shared.getPlayerStatistics(for: "Player")
                    viewModel.startAdaptiveQuiz(playerLevel: playerStats.level.level)
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            // Categories Preview
            VStack(spacing: 15) {
                Text("Categories")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 15) {
                    ForEach(QuizCategory.allCases.prefix(8), id: \.self) { category in
                        CategoryIcon(category: category)
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
    }
}

struct QuizActiveView: View {
    @ObservedObject var viewModel: QuizViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with progress and timer
            QuizHeaderView(viewModel: viewModel)
            
            // Question Content
            if let session = viewModel.currentSession,
               let currentQuestion = session.currentQuestion {
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Question
                        QuestionCard(
                            question: currentQuestion,
                            selectedAnswer: viewModel.selectedAnswer,
                            showExplanation: viewModel.showExplanation,
                            onAnswerSelected: { index in
                                viewModel.submitAnswer(index)
                            }
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Navigation Buttons
                        if viewModel.showExplanation {
                            HStack(spacing: 20) {
                                if viewModel.canGoToPreviousQuestion() {
                                    Button("Previous") {
                                        viewModel.previousQuestion()
                                    }
                                    .buttonStyle(NeumorphicButtonStyle(
                                        backgroundColor: Color(hex: "#1D1F30") ?? .black,
                                        isPressed: false
                                    ))
                                }
                                
                                Spacer()
                                
                                if viewModel.canGoToNextQuestion() {
                                    Button("Next") {
                                        viewModel.nextQuestion()
                                    }
                                    .buttonStyle(NeumorphicButtonStyle(
                                        backgroundColor: Color(hex: "#FE284A") ?? .red,
                                        isPressed: false
                                    ))
                                } else {
                                    Button("Finish") {
                                        viewModel.finishQuiz()
                                    }
                                    .buttonStyle(NeumorphicButtonStyle(
                                        backgroundColor: Color(hex: "#4CAF50") ?? .green,
                                        isPressed: false
                                    ))
                                }
                            }
                            .padding(.horizontal, 30)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .background(
            LinearGradient(
                colors: [
                    Color(hex: "#1D1F30") ?? .black,
                    Color(hex: "#2A2D47") ?? .gray
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct QuizHeaderView: View {
    @ObservedObject var viewModel: QuizViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            // Top bar with exit and timer
            HStack {
                Button(action: {
                    viewModel.exitQuiz()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.3))
                        )
                }
                
                Spacer()
                
                if viewModel.timeRemaining > 0 {
                    HStack(spacing: 5) {
                        Image(systemName: "timer")
                            .font(.system(size: 14))
                        Text(viewModel.getFormattedTimeRemaining())
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.3))
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Progress bar
            if let session = viewModel.currentSession {
                VStack(spacing: 8) {
                    HStack {
                        Text("Question \(session.currentQuestionIndex + 1) of \(session.questions.count)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                        
                        Text("Score: \(session.score)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#FE284A"))
                    }
                    
                    ProgressView(value: session.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#FE284A") ?? .red))
                        .scaleEffect(y: 2)
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 10)
    }
}

struct QuestionCard: View {
    let question: QuizQuestion
    let selectedAnswer: Int?
    let showExplanation: Bool
    let onAnswerSelected: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            // Category and Difficulty
            HStack {
                CategoryBadge(category: question.category)
                Spacer()
                DifficultyBadge(difficulty: question.difficulty)
            }
            
            // Question Text
            Text(question.question)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .padding(.horizontal, 10)
            
            // Answer Options
            VStack(spacing: 15) {
                ForEach(0..<question.options.count, id: \.self) { index in
                    AnswerButton(
                        text: question.options[index],
                        index: index,
                        isSelected: selectedAnswer == index,
                        isCorrect: showExplanation && index == question.correctAnswerIndex,
                        isWrong: showExplanation && selectedAnswer == index && index != question.correctAnswerIndex,
                        showExplanation: showExplanation
                    ) {
                        if selectedAnswer == nil {
                            onAnswerSelected(index)
                        }
                    }
                }
            }
            
            // Explanation
            if showExplanation {
                VStack(spacing: 10) {
                    Divider()
                        .background(Color.white.opacity(0.3))
                    
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                        Text("Explanation")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                    Text(question.explanation)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.top, 10)
            }
        }
        .padding(25)
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

struct AnswerButton: View {
    let text: String
    let index: Int
    let isSelected: Bool
    let isCorrect: Bool
    let isWrong: Bool
    let showExplanation: Bool
    let action: () -> Void
    
    var backgroundColor: Color {
        if showExplanation {
            if isCorrect {
                return Color(hex: "#4CAF50") ?? .green
            } else if isWrong {
                return Color(hex: "#F44336") ?? .red
            }
        }
        return isSelected ? (Color(hex: "#FE284A") ?? .red) : (Color(hex: "#2A2D47") ?? .gray)
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text("\(["A", "B", "C", "D"][index])")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.3))
                    )
                
                Text(text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if showExplanation {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : (isWrong ? "xmark.circle.fill" : ""))
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(backgroundColor)
                    .shadow(
                        color: Color.black.opacity(0.2),
                        radius: isSelected ? 2 : 5,
                        x: isSelected ? 1 : 3,
                        y: isSelected ? 1 : 3
                    )
            )
        }
        .disabled(showExplanation)
        .scaleEffect(isSelected ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isSelected)
    }
}

struct CategoryBadge: View {
    let category: QuizCategory
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: category.icon)
                .font(.system(size: 12))
            Text(category.rawValue)
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(Color(hex: category.color) ?? .blue)
        )
    }
}

struct DifficultyBadge: View {
    let difficulty: QuizDifficulty
    
    var body: some View {
        Text(difficulty.rawValue)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.3))
            )
    }
}

struct QuizMenuButton: View {
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

struct CategoryIcon: View {
    let category: QuizCategory
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: category.icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: category.color))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color(hex: category.color)?.opacity(0.2) ?? .blue.opacity(0.2))
                )
            
            Text(category.rawValue)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    QuizView()
}
