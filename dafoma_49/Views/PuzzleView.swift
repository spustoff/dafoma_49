//
//  PuzzleView.swift
//  dafoma_49
//
//  Created by Вячеслав on 9/29/25.
//

import SwiftUI

struct PuzzleView: View {
    @StateObject private var viewModel = PuzzleViewModel()
    @State private var showPuzzleSetup = false
    @State private var selectedType: PuzzleType?
    @State private var selectedDifficulty: PuzzleDifficulty = .beginner
    
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
                
                if viewModel.isPuzzleActive {
                    PuzzleActiveView(viewModel: viewModel)
                } else if viewModel.showResults {
                    PuzzleResultsView(viewModel: viewModel)
                } else {
                    PuzzleMenuView(
                        viewModel: viewModel,
                        showPuzzleSetup: $showPuzzleSetup,
                        selectedType: $selectedType,
                        selectedDifficulty: $selectedDifficulty
                    )
                }
            }
        }
        .sheet(isPresented: $showPuzzleSetup) {
            PuzzleSetupView(
                selectedType: $selectedType,
                selectedDifficulty: $selectedDifficulty,
                onStartPuzzle: { type, difficulty in
                    if let type = type {
                        viewModel.startPuzzle(type: type, difficulty: difficulty)
                    } else {
                        viewModel.startRandomPuzzle(difficulty: difficulty)
                    }
                    showPuzzleSetup = false
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

struct PuzzleMenuView: View {
    @ObservedObject var viewModel: PuzzleViewModel
    @Binding var showPuzzleSetup: Bool
    @Binding var selectedType: PuzzleType?
    @Binding var selectedDifficulty: PuzzleDifficulty
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 10) {
                Image(systemName: "puzzlepiece.fill")
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(Color(hex: "#4CAF50"))
                    .shadow(color: Color(hex: "#4CAF50")?.opacity(0.3) ?? .green, radius: 20)
                
                Text("Puzzle Challenge")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Exercise your mind with brain teasers")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 50)
            
            Spacer()
            
            // Quick Start Options
            VStack(spacing: 20) {
                PuzzleMenuButton(
                    title: "Random Puzzle",
                    subtitle: "Surprise me with any puzzle",
                    icon: "shuffle",
                    color: Color(hex: "#4CAF50") ?? .green
                ) {
                    viewModel.startRandomPuzzle(difficulty: selectedDifficulty)
                }
                
                PuzzleMenuButton(
                    title: "Choose Puzzle",
                    subtitle: "Select type & difficulty",
                    icon: "slider.horizontal.3",
                    color: Color(hex: "#2196F3") ?? .blue
                ) {
                    showPuzzleSetup = true
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            // Puzzle Types Preview
            VStack(spacing: 15) {
                Text("Puzzle Types")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                    ForEach(PuzzleType.allCases.prefix(6), id: \.self) { type in
                        PuzzleTypeIcon(type: type)
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
    }
}

struct PuzzleActiveView: View {
    @ObservedObject var viewModel: PuzzleViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            PuzzleHeaderView(viewModel: viewModel)
            
            // Puzzle Content
            ScrollView {
                VStack(spacing: 20) {
                    if let puzzle = viewModel.currentPuzzle {
                        switch puzzle.type {
                        case .wordSearch:
                            WordSearchPuzzleView(viewModel: viewModel)
                        case .numberSequence:
                            NumberSequencePuzzleView(viewModel: viewModel)
                        case .patternMatching:
                            PatternMatchingPuzzleView(viewModel: viewModel)
                        default:
                            Text("Puzzle type not implemented")
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
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

struct PuzzleHeaderView: View {
    @ObservedObject var viewModel: PuzzleViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            // Top bar
            HStack {
                Button(action: {
                    viewModel.exitPuzzle()
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
                
                HStack(spacing: 5) {
                    Image(systemName: "timer")
                        .font(.system(size: 14))
                    Text(viewModel.getFormattedTime())
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
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Progress and info
            if let puzzle = viewModel.currentPuzzle {
                VStack(spacing: 8) {
                    HStack {
                        Text(puzzle.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("Score: \(puzzle.score)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "#4CAF50"))
                    }
                    
                    ProgressView(value: viewModel.getProgress())
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "#4CAF50") ?? .green))
                        .scaleEffect(y: 2)
                    
                    HStack {
                        Text("\(viewModel.getCompletionPercentage())% Complete")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Spacer()
                        
                        if viewModel.canShowHint() {
                            let hintColor = Color(hex: "#FF9800") ?? .orange
                            Button("💡 Hint") {
                                // Show hint
                            }
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(hintColor)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 10)
    }
}

struct WordSearchPuzzleView: View {
    @ObservedObject var viewModel: PuzzleViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Words to find
            VStack(alignment: .leading, spacing: 10) {
                Text("Find these words:")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(viewModel.getWordsToFind(), id: \.self) { word in
                        let isFound = viewModel.isWordFound(word)
                        let textColor = isFound ? (Color(hex: "#4CAF50") ?? .green) : .white.opacity(0.8)
                        let backgroundColor = isFound ? (Color(hex: "#4CAF50") ?? .green).opacity(0.2) : Color.black.opacity(0.3)
                        
                        Text(word)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(textColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(backgroundColor)
                            )
                    }
                }
            }
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(hex: "#1D1F30") ?? .black)
                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 3, y: 3)
            )
            
            // Grid
            WordSearchGrid(viewModel: viewModel)
        }
    }
}

struct WordSearchGrid: View {
    @ObservedObject var viewModel: PuzzleViewModel
    
    var body: some View {
        let grid = viewModel.getWordSearchGrid()
        let gridSize = grid.count
        
        VStack(spacing: 2) {
            ForEach(0..<gridSize, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<gridSize, id: \.self) { col in
                        Text(grid[row][col])
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(width: 25, height: 25)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(hex: "#2A2D47") ?? .gray)
                            )
                    }
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(hex: "#1D1F30") ?? .black)
                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 3, y: 3)
        )
    }
}

struct NumberSequencePuzzleView: View {
    @ObservedObject var viewModel: PuzzleViewModel
    @State private var inputValues: [String] = []
    
    var body: some View {
        VStack(spacing: 20) {
            // Hint
            if let hint = viewModel.getHint() {
                Text("💡 \(hint)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#FF9800"))
                    .padding(15)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(hex: "#FF9800")?.opacity(0.1) ?? .orange.opacity(0.1))
                    )
            }
            
            // Sequence
            let sequence = viewModel.getSequence()
            let missingIndices = viewModel.getMissingIndices()
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: min(sequence.count, 5)), spacing: 10) {
                ForEach(0..<sequence.count, id: \.self) { index in
                    if missingIndices.contains(index) {
                        TextField("?", text: Binding<String>(
                            get: { 
                                if inputValues.count > index {
                                    return inputValues[index]
                                }
                                return ""
                            },
                            set: { newValue in
                                while inputValues.count <= index {
                                    inputValues.append("")
                                }
                                inputValues[index] = newValue
                                
                                if let value = Int(newValue) {
                                    viewModel.submitSequenceAnswer(at: index, value: value)
                                }
                            }
                        ))
                        .textFieldStyle(NumberSequenceTextFieldStyle())
                        .keyboardType(.numberPad)
                    } else {
                        Text("\(sequence[index])")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(hex: "#2A2D47") ?? .gray)
                            )
                    }
                }
            }
        }
        .onAppear {
            let sequence = viewModel.getSequence()
            inputValues = Array(repeating: "", count: sequence.count)
        }
    }
}

struct PatternMatchingPuzzleView: View {
    @ObservedObject var viewModel: PuzzleViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            // Instructions
            Text("Match the patterns by tapping a pattern and then its matching option")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(15)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black.opacity(0.3))
                )
            
            // Patterns
            VStack(alignment: .leading, spacing: 15) {
                Text("Patterns:")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                    ForEach(viewModel.getPatterns()) { pattern in
                        PatternItemView(
                            item: pattern,
                            isSelected: viewModel.isPatternSelected(pattern.id),
                            isMatched: viewModel.isPatternMatched(pattern.id)
                        ) {
                            viewModel.selectPattern(pattern.id)
                        }
                    }
                }
            }
            
            // Options
            VStack(alignment: .leading, spacing: 15) {
                Text("Options:")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 15) {
                    ForEach(viewModel.getOptions()) { option in
                        PatternItemView(
                            item: option,
                            isSelected: viewModel.isOptionSelected(option.id),
                            isMatched: viewModel.isOptionUsed(option.id)
                        ) {
                            viewModel.selectOption(option.id)
                        }
                    }
                }
            }
        }
    }
}

struct PatternItemView: View {
    let item: PatternItem
    let isSelected: Bool
    let isMatched: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Pattern shape
                Image(systemName: getShapeIcon())
                    .font(.system(size: item.size.value))
                    .foregroundColor(Color(hex: item.color.hexValue) ?? .blue)
                
                // Size indicator
                Text(item.size.rawValue.capitalized)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isMatched ? (Color(hex: "#4CAF50") ?? .green).opacity(0.3) : (isSelected ? (Color(hex: "#FE284A") ?? .red).opacity(0.3) : (Color(hex: "#1D1F30") ?? .black)))
                    .shadow(
                        color: Color.black.opacity(0.3),
                        radius: isSelected ? 2 : 5,
                        x: isSelected ? 1 : 3,
                        y: isSelected ? 1 : 3
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isMatched ? (Color(hex: "#4CAF50") ?? .green) : (isSelected ? (Color(hex: "#FE284A") ?? .red) : Color.clear),
                        lineWidth: 2
                    )
            )
        }
        .disabled(isMatched)
        .scaleEffect(isSelected ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isSelected)
    }
    
    private func getShapeIcon() -> String {
        switch item.shape {
        case .circle: return "circle.fill"
        case .square: return "square.fill"
        case .triangle: return "triangle.fill"
        case .diamond: return "diamond.fill"
        case .star: return "star.fill"
        case .hexagon: return "hexagon.fill"
        }
    }
}

struct PuzzleMenuButton: View {
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

struct PuzzleTypeIcon: View {
    let type: PuzzleType
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: type.icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "#4CAF50"))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color(hex: "#4CAF50")?.opacity(0.2) ?? .green.opacity(0.2))
                )
            
            Text(type.rawValue)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
    }
}

struct NumberSequenceTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .frame(width: 50, height: 50)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "#1D1F30") ?? .black)
                    .shadow(
                        color: Color.black.opacity(0.3),
                        radius: 3,
                        x: 2,
                        y: 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(hex: "#FE284A")?.opacity(0.5) ?? .red, lineWidth: 1)
            )
    }
}

#Preview {
    PuzzleView()
}
