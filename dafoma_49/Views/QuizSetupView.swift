//
//  QuizSetupView.swift
//  dafoma_49
//
//  Created by Вячеслав on 9/29/25.
//

import SwiftUI

struct QuizSetupView: View {
    @Binding var selectedCategory: QuizCategory?
    @Binding var selectedDifficulty: QuizDifficulty?
    @Binding var questionCount: Int
    let onStartQuiz: (QuizCategory?, QuizDifficulty?, Int) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
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
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 10) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 40, weight: .light))
                                .foregroundColor(Color(hex: "#FE284A"))
                            
                            Text("Customize Your Quiz")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Choose your preferred settings")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 20)
                        
                        // Category Selection
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "folder.fill")
                                    .foregroundColor(Color(hex: "#FE284A"))
                                Text("Category")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                Spacer()
                                if selectedCategory != nil {
                                    Button("Clear") {
                                        selectedCategory = nil
                                    }
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "#FE284A"))
                                }
                            }
                            
                            Text(selectedCategory?.rawValue ?? "All Categories")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.leading, 25)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                                ForEach(QuizCategory.allCases, id: \.self) { category in
                                    CategorySelectionCard(
                                        category: category,
                                        isSelected: selectedCategory == category
                                    ) {
                                        selectedCategory = selectedCategory == category ? nil : category
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Difficulty Selection
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "gauge.medium")
                                    .foregroundColor(Color(hex: "#FE284A"))
                                Text("Difficulty")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                Spacer()
                                if selectedDifficulty != nil {
                                    Button("Clear") {
                                        selectedDifficulty = nil
                                    }
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "#FE284A"))
                                }
                            }
                            
                            Text(selectedDifficulty?.rawValue ?? "Mixed Difficulty")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.leading, 25)
                            
                            HStack(spacing: 10) {
                                ForEach(QuizDifficulty.allCases, id: \.self) { difficulty in
                                    DifficultySelectionCard(
                                        difficulty: difficulty,
                                        isSelected: selectedDifficulty == difficulty
                                    ) {
                                        selectedDifficulty = selectedDifficulty == difficulty ? nil : difficulty
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Question Count
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "number")
                                    .foregroundColor(Color(hex: "#FE284A"))
                                Text("Number of Questions")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            
                            VStack(spacing: 10) {
                                HStack {
                                    Text("\(questionCount) Questions")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                    Spacer()
                                    Text("~\(questionCount * 30) seconds")
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .padding(.leading, 25)
                                
                                Slider(value: Binding(
                                    get: { Double(questionCount) },
                                    set: { questionCount = Int($0) }
                                ), in: 5...25, step: 1)
                                .accentColor(Color(hex: "#FE284A"))
                                .padding(.horizontal, 25)
                                
                                HStack {
                                    Text("5")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.white.opacity(0.5))
                                    Spacer()
                                    Text("25")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .padding(.horizontal, 25)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Start Button
                        Button("Start Quiz") {
                            onStartQuiz(selectedCategory, selectedDifficulty, questionCount)
                        }
                        .buttonStyle(NeumorphicButtonStyle(
                            backgroundColor: Color(hex: "#FE284A") ?? .red,
                            isPressed: false
                        ))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Quiz Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#FE284A"))
                }
            }
        }
    }
}

struct CategorySelectionCard: View {
    let category: QuizCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: category.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : Color(hex: category.color))
                
                Text(category.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ? (Color(hex: category.color) ?? .blue) : Color(hex: "#1D1F30") ?? .black)
                    .shadow(
                        color: Color.black.opacity(0.3),
                        radius: isSelected ? 2 : 5,
                        x: isSelected ? 1 : 3,
                        y: isSelected ? 1 : 3
                    )
                    .shadow(
                        color: Color.white.opacity(0.05),
                        radius: isSelected ? 1 : 5,
                        x: isSelected ? -1 : -3,
                        y: isSelected ? -1 : -3
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(
                        isSelected ? Color.white.opacity(0.3) : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isSelected)
    }
}

struct DifficultySelectionCard: View {
    let difficulty: QuizDifficulty
    let isSelected: Bool
    let action: () -> Void
    
    var backgroundColor: Color {
        switch difficulty {
        case .easy: return Color(hex: "#4CAF50") ?? .green
        case .medium: return Color(hex: "#FF9800") ?? .orange
        case .hard: return Color(hex: "#F44336") ?? .red
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(difficulty.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                
                Text("×\(String(format: "%.1f", difficulty.multiplier))")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .white.opacity(0.6))
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? backgroundColor : Color(hex: "#1D1F30") ?? .black)
                    .shadow(
                        color: Color.black.opacity(0.3),
                        radius: isSelected ? 2 : 5,
                        x: isSelected ? 1 : 3,
                        y: isSelected ? 1 : 3
                    )
                    .shadow(
                        color: Color.white.opacity(0.05),
                        radius: isSelected ? 1 : 5,
                        x: isSelected ? -1 : -3,
                        y: isSelected ? -1 : -3
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.white.opacity(0.3) : backgroundColor.opacity(0.3),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isSelected)
    }
}

#Preview {
    QuizSetupView(
        selectedCategory: .constant(nil),
        selectedDifficulty: .constant(nil),
        questionCount: .constant(10)
    ) { _, _, _ in }
}
