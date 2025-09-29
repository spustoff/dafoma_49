//
//  PuzzleSetupView.swift
//  dafoma_49
//
//  Created by Вячеслав on 9/29/25.
//

import SwiftUI

struct PuzzleSetupView: View {
    @Binding var selectedType: PuzzleType?
    @Binding var selectedDifficulty: PuzzleDifficulty
    let onStartPuzzle: (PuzzleType?, PuzzleDifficulty) -> Void
    
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
                            Image(systemName: "puzzlepiece.extension.fill")
                                .font(.system(size: 40, weight: .light))
                                .foregroundColor(Color(hex: "#4CAF50"))
                            
                            Text("Choose Your Puzzle")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Select type and difficulty")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 20)
                        
                        // Puzzle Type Selection
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "square.grid.3x3.fill")
                                    .foregroundColor(Color(hex: "#4CAF50"))
                                Text("Puzzle Type")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                Spacer()
                                if selectedType != nil {
                                    Button("Random") {
                                        selectedType = nil
                                    }
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "#4CAF50"))
                                }
                            }
                            
                            Text(selectedType?.rawValue ?? "Random Puzzle")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.leading, 25)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                                ForEach(PuzzleType.allCases, id: \.self) { type in
                                    PuzzleTypeSelectionCard(
                                        type: type,
                                        isSelected: selectedType == type
                                    ) {
                                        selectedType = selectedType == type ? nil : type
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Difficulty Selection
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "gauge.medium")
                                    .foregroundColor(Color(hex: "#4CAF50"))
                                Text("Difficulty")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            
                            Text(selectedDifficulty.rawValue)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.leading, 25)
                            
                            VStack(spacing: 10) {
                                ForEach(PuzzleDifficulty.allCases, id: \.self) { difficulty in
                                    PuzzleDifficultySelectionCard(
                                        difficulty: difficulty,
                                        isSelected: selectedDifficulty == difficulty
                                    ) {
                                        selectedDifficulty = difficulty
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Estimated Time
                        if let estimatedTime = getEstimatedTime() {
                            VStack(spacing: 10) {
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(Color(hex: "#4CAF50"))
                                    Text("Estimated Time")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                
                                Text(formatTime(estimatedTime))
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(.leading, 45)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        
                        // Start Button
                        Button("Start Puzzle") {
                            onStartPuzzle(selectedType, selectedDifficulty)
                        }
                        .buttonStyle(NeumorphicButtonStyle(
                            backgroundColor: Color(hex: "#4CAF50") ?? .green,
                            isPressed: false
                        ))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Puzzle Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#4CAF50"))
                }
            }
        }
    }
    
    private func getEstimatedTime() -> TimeInterval? {
        // Return estimated time based on difficulty
        switch selectedDifficulty {
        case .beginner: return 300 // 5 minutes
        case .intermediate: return 600 // 10 minutes
        case .advanced: return 900 // 15 minutes
        case .expert: return 1200 // 20 minutes
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        return "\(minutes) minutes"
    }
}

struct PuzzleTypeSelectionCard: View {
    let type: PuzzleType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: type.icon)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .white : Color(hex: "#4CAF50"))
                
                VStack(spacing: 4) {
                    Text(type.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .white.opacity(0.9))
                        .multilineTextAlignment(.center)
                    
                    Text(type.description)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ? (Color(hex: "#4CAF50") ?? .green) : Color(hex: "#1D1F30") ?? .black)
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
                        isSelected ? Color.white.opacity(0.3) : Color(hex: "#4CAF50")?.opacity(0.3) ?? .green.opacity(0.3),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isSelected)
    }
}

struct PuzzleDifficultySelectionCard: View {
    let difficulty: PuzzleDifficulty
    let isSelected: Bool
    let action: () -> Void
    
    var backgroundColor: Color {
        return Color(hex: difficulty.color) ?? .gray
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                // Difficulty indicator
                HStack(spacing: 2) {
                    ForEach(0..<4) { index in
                        Circle()
                            .fill(index < getDifficultyLevel() ? backgroundColor : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(difficulty.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .white.opacity(0.9))
                    
                    Text("Score multiplier: ×\(String(format: "%.1f", difficulty.multiplier))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .white.opacity(0.6))
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
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
        .scaleEffect(isSelected ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isSelected)
    }
    
    private func getDifficultyLevel() -> Int {
        switch difficulty {
        case .beginner: return 1
        case .intermediate: return 2
        case .advanced: return 3
        case .expert: return 4
        }
    }
}

#Preview {
    PuzzleSetupView(
        selectedType: .constant(nil),
        selectedDifficulty: .constant(.beginner)
    ) { _, _ in }
}
