//
//  PuzzleResultsView.swift
//  dafoma_49
//
//  Created by Вячеслав on 9/29/25.
//

import SwiftUI

struct PuzzleResultsView: View {
    @ObservedObject var viewModel: PuzzleViewModel
    @State private var showShareSheet = false
    @State private var animateScore = false
    
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
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 15) {
                            // Celebration Icon
                            Image(systemName: getPerformanceIcon())
                                .font(.system(size: 60, weight: .light))
                                .foregroundColor(getPerformanceColor())
                                .shadow(color: getPerformanceColor().opacity(0.3), radius: 20)
                                .scaleEffect(animateScore ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 0.6).repeatCount(3, autoreverses: true), value: animateScore)
                            
                            Text(getPerformanceTitle())
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            Text(getPerformanceSubtitle())
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 30)
                        
                        // Score Card
                        if let puzzle = viewModel.currentPuzzle {
                            PuzzleScoreCard(puzzle: puzzle, viewModel: viewModel)
                        }
                        
                        // Statistics
                        if let puzzle = viewModel.currentPuzzle {
                            PuzzleStatisticsCard(puzzle: puzzle, viewModel: viewModel)
                        }
                        
                        // Performance Analysis
                        if let puzzle = viewModel.currentPuzzle {
                            PuzzlePerformanceCard(puzzle: puzzle, viewModel: viewModel)
                        }
                        
                        // Action Buttons
                        VStack(spacing: 15) {
                            HStack(spacing: 15) {
                                Button("Try Again") {
                                    // Start same type of puzzle
                                    if let puzzle = viewModel.currentPuzzle {
                                        viewModel.startPuzzle(type: puzzle.type, difficulty: puzzle.difficulty)
                                    }
                                }
                                .buttonStyle(NeumorphicButtonStyle(
                                    backgroundColor: Color(hex: "#4CAF50") ?? .green,
                                    isPressed: false
                                ))
                                
                                Button("Share Results") {
                                    showShareSheet = true
                                }
                                .buttonStyle(NeumorphicButtonStyle(
                                    backgroundColor: Color(hex: "#2196F3") ?? .blue,
                                    isPressed: false
                                ))
                            }
                            
                            Button("Back to Menu") {
                                viewModel.exitPuzzle()
                            }
                            .buttonStyle(NeumorphicButtonStyle(
                                backgroundColor: Color(hex: "#1D1F30") ?? .black,
                                isPressed: false
                            ))
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .onAppear {
            animateScore = true
        }
        .sheet(isPresented: $showShareSheet) {
            if let puzzle = viewModel.currentPuzzle {
                ShareSheet(items: [createShareText(puzzle: puzzle)])
            }
        }
    }
    
    private func getPerformanceIcon() -> String {
        guard let puzzle = viewModel.currentPuzzle else { return "puzzlepiece" }
        
        if puzzle.isCompleted {
            let progress = viewModel.getProgress()
            switch progress {
            case 1.0: return "star.fill"
            case 0.8..<1.0: return "hand.thumbsup.fill"
            default: return "checkmark.circle.fill"
            }
        } else {
            return "clock.fill"
        }
    }
    
    private func getPerformanceColor() -> Color {
        guard let puzzle = viewModel.currentPuzzle else { return Color(hex: "#4CAF50") ?? .green }
        
        if puzzle.isCompleted {
            let progress = viewModel.getProgress()
            switch progress {
            case 1.0: return Color(hex: "#FFD700") ?? .yellow
            case 0.8..<1.0: return Color(hex: "#4CAF50") ?? .green
            default: return Color(hex: "#FF9800") ?? .orange
            }
        } else {
            return Color(hex: "#2196F3") ?? .blue
        }
    }
    
    private func getPerformanceTitle() -> String {
        guard let puzzle = viewModel.currentPuzzle else { return "Puzzle Complete" }
        
        if puzzle.isCompleted {
            let progress = viewModel.getProgress()
            switch progress {
            case 1.0: return "Perfect!"
            case 0.8..<1.0: return "Excellent!"
            default: return "Well Done!"
            }
        } else {
            return "Time's Up!"
        }
    }
    
    private func getPerformanceSubtitle() -> String {
        guard let puzzle = viewModel.currentPuzzle else { return "Great effort!" }
        
        if puzzle.isCompleted {
            let progress = viewModel.getProgress()
            switch progress {
            case 1.0: return "You solved it completely!"
            case 0.8..<1.0: return "Almost perfect solution!"
            default: return "Good progress made!"
            }
        } else {
            return "Keep practicing to improve!"
        }
    }
    
    private func createShareText(puzzle: any Puzzle) -> String {
        let progress = Int(viewModel.getProgress() * 100)
        return """
        🧩 Just completed a \(puzzle.type.rawValue) puzzle in QuizTrek Vada!
        
        📊 Score: \(puzzle.score) points
        ✅ Progress: \(progress)%
        ⏱️ Time: \(viewModel.getFormattedTime())
        🎯 Difficulty: \(puzzle.difficulty.rawValue)
        
        #QuizTrekVada #BrainTraining #Puzzle
        """
    }
}

struct PuzzleScoreCard: View {
    let puzzle: any Puzzle
    let viewModel: PuzzleViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Main Score
            VStack(spacing: 10) {
                Text("\(puzzle.score)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#4CAF50"))
                
                Text("POINTS")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .tracking(2)
            }
            
            // Score Breakdown
            HStack(spacing: 30) {
                PuzzleScoreMetric(
                    title: "Progress",
                    value: "\(viewModel.getCompletionPercentage())%",
                    color: Color(hex: "#4CAF50") ?? .green
                )
                
                PuzzleScoreMetric(
                    title: "Time",
                    value: viewModel.getFormattedTime(),
                    color: Color(hex: "#FF9800") ?? .orange
                )
                
                PuzzleScoreMetric(
                    title: "Difficulty",
                    value: puzzle.difficulty.rawValue,
                    color: Color(hex: puzzle.difficulty.color) ?? .gray
                )
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
        .padding(.horizontal, 20)
    }
}

struct PuzzleScoreMetric: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

struct PuzzleStatisticsCard: View {
    let puzzle: any Puzzle
    let viewModel: PuzzleViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(Color(hex: "#4CAF50"))
                Text("Statistics")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(spacing: 12) {
                PuzzleStatisticRow(
                    title: "Puzzle Type",
                    value: puzzle.type.rawValue
                )
                
                PuzzleStatisticRow(
                    title: "Estimated Time",
                    value: formatTime(puzzle.estimatedTime)
                )
                
                PuzzleStatisticRow(
                    title: "Actual Time",
                    value: viewModel.getFormattedTime()
                )
                
                PuzzleStatisticRow(
                    title: "Time Efficiency",
                    value: getTimeEfficiency()
                )
                
                PuzzleStatisticRow(
                    title: "Score Multiplier",
                    value: "×\(String(format: "%.1f", puzzle.difficulty.multiplier))"
                )
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
        .padding(.horizontal, 20)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func getTimeEfficiency() -> String {
        let actualTime = viewModel.timeElapsed
        let estimatedTime = puzzle.estimatedTime
        
        if actualTime <= estimatedTime {
            let efficiency = (estimatedTime - actualTime) / estimatedTime * 100
            return String(format: "+%.0f%%", efficiency)
        } else {
            let overtime = (actualTime - estimatedTime) / estimatedTime * 100
            return String(format: "-%.0f%%", overtime)
        }
    }
}

struct PuzzleStatisticRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

struct PuzzlePerformanceCard: View {
    let puzzle: any Puzzle
    let viewModel: PuzzleViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "target")
                    .foregroundColor(Color(hex: "#4CAF50"))
                Text("Performance Analysis")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(spacing: 15) {
                // Progress Bar
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Completion")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                        
                        Text("\(viewModel.getCompletionPercentage())%")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#4CAF50"))
                    }
                    
                    ProgressView(value: viewModel.getProgress())
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#4CAF50") ?? .green))
                        .scaleEffect(y: 2)
                }
                
                // Performance Insights
                VStack(alignment: .leading, spacing: 8) {
                    Text("Insights")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(getPerformanceInsights(), id: \.self) { insight in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .foregroundColor(Color(hex: "#4CAF50"))
                                Text(insight)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.white.opacity(0.7))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
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
        .padding(.horizontal, 20)
    }
    
    private func getPerformanceInsights() -> [String] {
        var insights: [String] = []
        
        let progress = viewModel.getProgress()
        let timeElapsed = viewModel.timeElapsed
        let estimatedTime = puzzle.estimatedTime
        
        // Progress insights
        if progress == 1.0 {
            insights.append("Perfect completion! You solved the entire puzzle.")
        } else if progress >= 0.8 {
            insights.append("Excellent progress! You're almost there.")
        } else if progress >= 0.5 {
            insights.append("Good progress! Keep practicing to improve.")
        } else {
            insights.append("This puzzle type might need more practice.")
        }
        
        // Time insights
        if timeElapsed < estimatedTime * 0.7 {
            insights.append("Impressive speed! You completed this faster than expected.")
        } else if timeElapsed < estimatedTime {
            insights.append("Good timing! You finished within the estimated time.")
        } else {
            insights.append("Take your time to think through the solution.")
        }
        
        // Difficulty insights
        switch puzzle.difficulty {
        case .beginner:
            insights.append("Try intermediate difficulty for more challenge.")
        case .intermediate:
            if progress >= 0.8 {
                insights.append("Ready for advanced difficulty!")
            }
        case .advanced:
            if progress >= 0.8 {
                insights.append("You're becoming an expert at this!")
            }
        case .expert:
            insights.append("Master level puzzle - great job attempting this!")
        }
        
        return insights
    }
}

#Preview {
    PuzzleResultsView(viewModel: PuzzleViewModel())
}
