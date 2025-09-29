//
//  QuizResultsView.swift
//  dafoma_49
//
//  Created by Вячеслав on 9/29/25.
//

import SwiftUI

struct QuizResultsView: View {
    @ObservedObject var viewModel: QuizViewModel
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
                        if let session = viewModel.currentSession {
                            ScoreCard(session: session, viewModel: viewModel)
                        }
                        
                        // Statistics
                        if let session = viewModel.currentSession {
                            StatisticsCard(session: session, viewModel: viewModel)
                        }
                        
                        // Question Review
                        if let session = viewModel.currentSession {
                            QuestionReviewCard(session: session)
                        }
                        
                        // Action Buttons
                        VStack(spacing: 15) {
                            HStack(spacing: 15) {
                                Button("Play Again") {
                                    viewModel.restartQuiz()
                                }
                                .buttonStyle(NeumorphicButtonStyle(
                                    backgroundColor: Color(hex: "#FE284A") ?? .red,
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
                                viewModel.exitQuiz()
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
            if let session = viewModel.currentSession {
                ShareSheet(items: [createShareText(session: session)])
            }
        }
    }
    
    private func getPerformanceIcon() -> String {
        let accuracy = viewModel.getAccuracy()
        
        switch accuracy {
        case 0.9...1.0: return "star.fill"
        case 0.7..<0.9: return "hand.thumbsup.fill"
        case 0.5..<0.7: return "face.smiling"
        default: return "arrow.up.circle.fill"
        }
    }
    
    private func getPerformanceColor() -> Color {
        let accuracy = viewModel.getAccuracy()
        
        switch accuracy {
        case 0.9...1.0: return Color(hex: "#FFD700") ?? .yellow
        case 0.7..<0.9: return Color(hex: "#4CAF50") ?? .green
        case 0.5..<0.7: return Color(hex: "#FF9800") ?? .orange
        default: return Color(hex: "#FE284A") ?? .red
        }
    }
    
    private func getPerformanceTitle() -> String {
        let accuracy = viewModel.getAccuracy()
        
        switch accuracy {
        case 0.9...1.0: return "Outstanding!"
        case 0.7..<0.9: return "Great Job!"
        case 0.5..<0.7: return "Good Effort!"
        default: return "Keep Trying!"
        }
    }
    
    private func getPerformanceSubtitle() -> String {
        let accuracy = viewModel.getAccuracy()
        
        switch accuracy {
        case 0.9...1.0: return "You're a quiz master!"
        case 0.7..<0.9: return "You're doing really well!"
        case 0.5..<0.7: return "You're on the right track!"
        default: return "Practice makes perfect!"
        }
    }
    
    private func createShareText(session: QuizSession) -> String {
        let accuracy = Int(viewModel.getAccuracy() * 100)
        return """
        🎯 Just completed a QuizTrek Vada quiz!
        
        📊 Score: \(session.score) points
        ✅ Accuracy: \(accuracy)%
        ⏱️ Time: \(viewModel.getFormattedTime())
        📚 Questions: \(session.questions.count)
        
        #QuizTrekVada #BrainTraining #Quiz
        """
    }
}

struct ScoreCard: View {
    let session: QuizSession
    let viewModel: QuizViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Main Score
            VStack(spacing: 10) {
                Text("\(session.score)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#FE284A"))
                
                Text("POINTS")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .tracking(2)
            }
            
            // Score Breakdown
            HStack(spacing: 30) {
                ScoreMetric(
                    title: "Correct",
                    value: "\(viewModel.getCorrectAnswersCount())/\(session.questions.count)",
                    color: Color(hex: "#4CAF50") ?? .green
                )
                
                ScoreMetric(
                    title: "Accuracy",
                    value: "\(Int(viewModel.getAccuracy() * 100))%",
                    color: Color(hex: "#2196F3") ?? .blue
                )
                
                ScoreMetric(
                    title: "Time",
                    value: viewModel.getFormattedTime(),
                    color: Color(hex: "#FF9800") ?? .orange
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

struct ScoreMetric: View {
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

struct StatisticsCard: View {
    let session: QuizSession
    let viewModel: QuizViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(Color(hex: "#FE284A"))
                Text("Statistics")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            
            VStack(spacing: 12) {
                StatisticRow(
                    title: "Questions Answered",
                    value: "\(session.questions.count)"
                )
                
                StatisticRow(
                    title: "Average Time per Question",
                    value: String(format: "%.1fs", session.timeElapsed / Double(session.questions.count))
                )
                
                StatisticRow(
                    title: "Categories Covered",
                    value: "\(Set(session.questions.map { $0.category }).count)"
                )
                
                StatisticRow(
                    title: "Difficulty Distribution",
                    value: getDifficultyDistribution()
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
    
    private func getDifficultyDistribution() -> String {
        let difficulties = session.questions.map { $0.difficulty }
        let easy = difficulties.filter { $0 == .easy }.count
        let medium = difficulties.filter { $0 == .medium }.count
        let hard = difficulties.filter { $0 == .hard }.count
        
        var parts: [String] = []
        if easy > 0 { parts.append("\(easy) Easy") }
        if medium > 0 { parts.append("\(medium) Medium") }
        if hard > 0 { parts.append("\(hard) Hard") }
        
        return parts.joined(separator: ", ")
    }
}

struct StatisticRow: View {
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

struct QuestionReviewCard: View {
    let session: QuizSession
    @State private var showAllQuestions = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "list.bullet.clipboard")
                    .foregroundColor(Color(hex: "#FE284A"))
                Text("Question Review")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                
                Button(showAllQuestions ? "Show Less" : "Show All") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showAllQuestions.toggle()
                    }
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "#FE284A"))
            }
            
            let questionsToShow = showAllQuestions ? session.questions : Array(session.questions.prefix(3))
            
            ForEach(Array(questionsToShow.enumerated()), id: \.offset) { index, question in
                QuestionReviewRow(
                    question: question,
                    userAnswer: session.userAnswers[index],
                    questionNumber: index + 1
                )
                
                if index < questionsToShow.count - 1 {
                    Divider()
                        .background(Color.white.opacity(0.2))
                }
            }
            
            if !showAllQuestions && session.questions.count > 3 {
                Text("... and \(session.questions.count - 3) more questions")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 5)
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
}

struct QuestionReviewRow: View {
    let question: QuizQuestion
    let userAnswer: Int?
    let questionNumber: Int
    
    var isCorrect: Bool {
        guard let userAnswer = userAnswer else { return false }
        return userAnswer == question.correctAnswerIndex
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Q\(questionNumber)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
                
                Spacer()
                
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isCorrect ? Color(hex: "#4CAF50") : Color(hex: "#F44336"))
                    .font(.system(size: 16))
            }
            
            Text(question.question)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(2)
            
            HStack {
                CategoryBadge(category: question.category)
                DifficultyBadge(difficulty: question.difficulty)
                Spacer()
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    QuizResultsView(viewModel: QuizViewModel())
}
