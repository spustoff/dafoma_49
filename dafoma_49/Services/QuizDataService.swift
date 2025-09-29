//
//  QuizDataService.swift
//  dafoma_49
//
//  Created by Вячеслав on 9/29/25.
//

import Foundation

class QuizDataService: ObservableObject {
    static let shared = QuizDataService()
    
    private init() {}
    
    // MARK: - Sample Quiz Data
    private let sampleQuestions: [QuizQuestion] = [
        // Science Questions
        QuizQuestion(
            question: "What is the chemical symbol for gold?",
            options: ["Go", "Gd", "Au", "Ag"],
            correctAnswerIndex: 2,
            category: .science,
            difficulty: .easy,
            explanation: "Au comes from the Latin word 'aurum' meaning gold."
        ),
        QuizQuestion(
            question: "Which planet is known as the Red Planet?",
            options: ["Venus", "Mars", "Jupiter", "Saturn"],
            correctAnswerIndex: 1,
            category: .science,
            difficulty: .easy,
            explanation: "Mars appears red due to iron oxide (rust) on its surface."
        ),
        QuizQuestion(
            question: "What is the speed of light in a vacuum?",
            options: ["299,792,458 m/s", "300,000,000 m/s", "299,000,000 m/s", "301,000,000 m/s"],
            correctAnswerIndex: 0,
            category: .science,
            difficulty: .hard,
            explanation: "The exact speed of light in a vacuum is 299,792,458 meters per second."
        ),
        
        // History Questions
        QuizQuestion(
            question: "In which year did World War II end?",
            options: ["1944", "1945", "1946", "1947"],
            correctAnswerIndex: 1,
            category: .history,
            difficulty: .easy,
            explanation: "World War II ended in 1945 with the surrender of Japan in September."
        ),
        QuizQuestion(
            question: "Who was the first person to walk on the moon?",
            options: ["Buzz Aldrin", "Neil Armstrong", "John Glenn", "Alan Shepard"],
            correctAnswerIndex: 1,
            category: .history,
            difficulty: .easy,
            explanation: "Neil Armstrong was the first person to walk on the moon on July 20, 1969."
        ),
        QuizQuestion(
            question: "Which ancient wonder of the world was located in Alexandria?",
            options: ["Hanging Gardens", "Lighthouse of Alexandria", "Colossus of Rhodes", "Temple of Artemis"],
            correctAnswerIndex: 1,
            category: .history,
            difficulty: .medium,
            explanation: "The Lighthouse of Alexandria was one of the Seven Wonders of the Ancient World."
        ),
        
        // Geography Questions
        QuizQuestion(
            question: "What is the capital of Australia?",
            options: ["Sydney", "Melbourne", "Canberra", "Perth"],
            correctAnswerIndex: 2,
            category: .geography,
            difficulty: .medium,
            explanation: "Canberra is the capital city of Australia, not Sydney or Melbourne."
        ),
        QuizQuestion(
            question: "Which is the longest river in the world?",
            options: ["Amazon", "Nile", "Mississippi", "Yangtze"],
            correctAnswerIndex: 1,
            category: .geography,
            difficulty: .easy,
            explanation: "The Nile River is the longest river in the world at approximately 6,650 km."
        ),
        QuizQuestion(
            question: "Mount Everest is located on the border of which two countries?",
            options: ["India and China", "Nepal and China", "Nepal and India", "Bhutan and China"],
            correctAnswerIndex: 1,
            category: .geography,
            difficulty: .medium,
            explanation: "Mount Everest is located on the border between Nepal and China (Tibet)."
        ),
        
        // Technology Questions
        QuizQuestion(
            question: "Who founded Apple Inc.?",
            options: ["Bill Gates", "Steve Jobs and Steve Wozniak", "Mark Zuckerberg", "Larry Page"],
            correctAnswerIndex: 1,
            category: .technology,
            difficulty: .easy,
            explanation: "Apple Inc. was founded by Steve Jobs, Steve Wozniak, and Ronald Wayne in 1976."
        ),
        QuizQuestion(
            question: "What does 'HTTP' stand for?",
            options: ["HyperText Transfer Protocol", "High Tech Transfer Protocol", "HyperText Transport Protocol", "High Transfer Text Protocol"],
            correctAnswerIndex: 0,
            category: .technology,
            difficulty: .medium,
            explanation: "HTTP stands for HyperText Transfer Protocol, used for web communication."
        ),
        QuizQuestion(
            question: "Which programming language was developed by Apple for iOS development?",
            options: ["Objective-C", "Swift", "Java", "Python"],
            correctAnswerIndex: 1,
            category: .technology,
            difficulty: .medium,
            explanation: "Swift was developed by Apple specifically for iOS, macOS, and other Apple platform development."
        ),
        
        // Sports Questions
        QuizQuestion(
            question: "How many players are on a basketball team on the court at one time?",
            options: ["4", "5", "6", "7"],
            correctAnswerIndex: 1,
            category: .sports,
            difficulty: .easy,
            explanation: "Each basketball team has 5 players on the court at any given time."
        ),
        QuizQuestion(
            question: "In which sport would you perform a slam dunk?",
            options: ["Volleyball", "Tennis", "Basketball", "Baseball"],
            correctAnswerIndex: 2,
            category: .sports,
            difficulty: .easy,
            explanation: "A slam dunk is a basketball move where a player jumps and scores by putting the ball directly through the hoop."
        ),
        QuizQuestion(
            question: "Which country has won the most FIFA World Cups?",
            options: ["Germany", "Argentina", "Brazil", "Italy"],
            correctAnswerIndex: 2,
            category: .sports,
            difficulty: .medium,
            explanation: "Brazil has won the FIFA World Cup 5 times, more than any other country."
        ),
        
        // Entertainment Questions
        QuizQuestion(
            question: "Which movie won the Academy Award for Best Picture in 2020?",
            options: ["1917", "Joker", "Parasite", "Once Upon a Time in Hollywood"],
            correctAnswerIndex: 2,
            category: .entertainment,
            difficulty: .medium,
            explanation: "Parasite won the Academy Award for Best Picture in 2020, making history as the first non-English film to win."
        ),
        QuizQuestion(
            question: "Who composed the music for the movie 'Star Wars'?",
            options: ["Hans Zimmer", "John Williams", "Danny Elfman", "Alan Silvestri"],
            correctAnswerIndex: 1,
            category: .entertainment,
            difficulty: .easy,
            explanation: "John Williams composed the iconic music for the Star Wars saga."
        ),
        QuizQuestion(
            question: "Which streaming service produced 'Stranger Things'?",
            options: ["Amazon Prime", "Hulu", "Netflix", "Disney+"],
            correctAnswerIndex: 2,
            category: .entertainment,
            difficulty: .easy,
            explanation: "Stranger Things is a Netflix original series that premiered in 2016."
        ),
        
        // Literature Questions
        QuizQuestion(
            question: "Who wrote the novel '1984'?",
            options: ["Aldous Huxley", "George Orwell", "Ray Bradbury", "Kurt Vonnegut"],
            correctAnswerIndex: 1,
            category: .literature,
            difficulty: .medium,
            explanation: "George Orwell wrote the dystopian novel '1984', published in 1949."
        ),
        QuizQuestion(
            question: "In which Shakespeare play does the character Hamlet appear?",
            options: ["Macbeth", "Romeo and Juliet", "Hamlet", "Othello"],
            correctAnswerIndex: 2,
            category: .literature,
            difficulty: .easy,
            explanation: "Hamlet is the protagonist of Shakespeare's tragedy 'Hamlet, Prince of Denmark'."
        ),
        QuizQuestion(
            question: "Who wrote 'Pride and Prejudice'?",
            options: ["Charlotte Brontë", "Emily Brontë", "Jane Austen", "Virginia Woolf"],
            correctAnswerIndex: 2,
            category: .literature,
            difficulty: .easy,
            explanation: "Jane Austen wrote 'Pride and Prejudice', published in 1813."
        ),
        
        // Art Questions
        QuizQuestion(
            question: "Who painted the Mona Lisa?",
            options: ["Michelangelo", "Leonardo da Vinci", "Raphael", "Donatello"],
            correctAnswerIndex: 1,
            category: .art,
            difficulty: .easy,
            explanation: "Leonardo da Vinci painted the Mona Lisa between 1503 and 1519."
        ),
        QuizQuestion(
            question: "Which art movement was Pablo Picasso associated with?",
            options: ["Impressionism", "Cubism", "Surrealism", "Abstract Expressionism"],
            correctAnswerIndex: 1,
            category: .art,
            difficulty: .medium,
            explanation: "Pablo Picasso was one of the founders of the Cubism art movement."
        ),
        QuizQuestion(
            question: "In which museum is the Mona Lisa displayed?",
            options: ["British Museum", "Metropolitan Museum", "Louvre Museum", "Uffizi Gallery"],
            correctAnswerIndex: 2,
            category: .art,
            difficulty: .medium,
            explanation: "The Mona Lisa is displayed in the Louvre Museum in Paris, France."
        )
    ]
    
    // MARK: - Quiz Generation
    func generateQuiz(category: QuizCategory? = nil, difficulty: QuizDifficulty? = nil, questionCount: Int = 10) -> QuizSession {
        var filteredQuestions = sampleQuestions
        
        if let category = category {
            filteredQuestions = filteredQuestions.filter { $0.category == category }
        }
        
        if let difficulty = difficulty {
            filteredQuestions = filteredQuestions.filter { $0.difficulty == difficulty }
        }
        
        let selectedQuestions = Array(filteredQuestions.shuffled().prefix(questionCount))
        var session = QuizSession(questions: selectedQuestions)
        session.userAnswers = Array(repeating: nil, count: selectedQuestions.count)
        
        return session
    }
    
    func generateMixedQuiz(questionCount: Int = 10) -> QuizSession {
        let selectedQuestions = Array(sampleQuestions.shuffled().prefix(questionCount))
        var session = QuizSession(questions: selectedQuestions)
        session.userAnswers = Array(repeating: nil, count: selectedQuestions.count)
        
        return session
    }
    
    func generateAdaptiveQuiz(playerLevel: Int, questionCount: Int = 10) -> QuizSession {
        var easyCount = 0
        var mediumCount = 0
        var hardCount = 0
        
        // Adjust difficulty distribution based on player level
        switch playerLevel {
        case 1...5:
            easyCount = 7
            mediumCount = 3
            hardCount = 0
        case 6...15:
            easyCount = 4
            mediumCount = 5
            hardCount = 1
        case 16...30:
            easyCount = 2
            mediumCount = 5
            hardCount = 3
        default:
            easyCount = 1
            mediumCount = 4
            hardCount = 5
        }
        
        let easyQuestions = Array(sampleQuestions.filter { $0.difficulty == .easy }.shuffled().prefix(easyCount))
        let mediumQuestions = Array(sampleQuestions.filter { $0.difficulty == .medium }.shuffled().prefix(mediumCount))
        let hardQuestions = Array(sampleQuestions.filter { $0.difficulty == .hard }.shuffled().prefix(hardCount))
        
        let allQuestions = (easyQuestions + mediumQuestions + hardQuestions).shuffled()
        let selectedQuestions = Array(allQuestions.prefix(questionCount))
        
        var session = QuizSession(questions: selectedQuestions)
        session.userAnswers = Array(repeating: nil, count: selectedQuestions.count)
        
        return session
    }
    
    // MARK: - Quiz Statistics
    func getQuizStatistics(for playerName: String) -> QuizStatistics {
        let scores = DataService.shared.fetchScores(gameType: .quiz).filter { $0.playerName == playerName }
        
        let totalQuizzes = scores.count
        let totalScore = scores.reduce(0) { $0 + $1.score }
        let averageScore = totalQuizzes > 0 ? Double(totalScore) / Double(totalQuizzes) : 0
        let bestScore = scores.max(by: { $0.score < $1.score })?.score ?? 0
        let totalTimeSpent = scores.reduce(0) { $0 + $1.timeSpent }
        
        // Calculate category stats (simplified for now)
        var categoryStats: [QuizCategory: CategoryStats] = [:]
        for category in QuizCategory.allCases {
            categoryStats[category] = CategoryStats(
                questionsAnswered: 0,
                correctAnswers: 0,
                averageScore: 0
            )
        }
        
        return QuizStatistics(
            totalQuizzes: totalQuizzes,
            totalScore: totalScore,
            averageScore: averageScore,
            bestScore: bestScore,
            totalTimeSpent: totalTimeSpent,
            categoryStats: categoryStats
        )
    }
    
    // MARK: - Achievement Checking
    func checkForAchievements(session: QuizSession, playerName: String) -> [Achievement] {
        var newAchievements: [Achievement] = []
        let playerStats = DataService.shared.getPlayerStatistics(for: playerName)
        
        // Perfect Score Achievement
        if session.score == session.questions.count * 100 {
            let achievement = Achievement(
                title: "Perfect Score!",
                description: "Answer all questions correctly in a quiz",
                icon: "star.fill",
                rarity: .rare,
                unlockedDate: Date(),
                category: .accuracy
            )
            newAchievements.append(achievement)
        }
        
        // Speed Demon Achievement
        if session.timeElapsed < 60 && session.questions.count >= 10 {
            let achievement = Achievement(
                title: "Speed Demon",
                description: "Complete a 10-question quiz in under 1 minute",
                icon: "bolt.fill",
                rarity: .epic,
                unlockedDate: Date(),
                category: .speed
            )
            newAchievements.append(achievement)
        }
        
        // First Quiz Achievement
        if playerStats.totalGamesPlayed == 0 {
            let achievement = Achievement(
                title: "First Steps",
                description: "Complete your first quiz",
                icon: "flag.fill",
                rarity: .common,
                unlockedDate: Date(),
                category: .quiz
            )
            newAchievements.append(achievement)
        }
        
        // Quiz Master Achievement
        if playerStats.totalGamesPlayed >= 100 {
            let achievement = Achievement(
                title: "Quiz Master",
                description: "Complete 100 quizzes",
                icon: "crown.fill",
                rarity: .legendary,
                unlockedDate: Date(),
                category: .dedication
            )
            newAchievements.append(achievement)
        }
        
        // Save new achievements
        for achievement in newAchievements {
            DataService.shared.saveAchievement(achievement, for: playerName)
        }
        
        return newAchievements
    }
    
    // MARK: - Question Management
    func getQuestionsForCategory(_ category: QuizCategory) -> [QuizQuestion] {
        return sampleQuestions.filter { $0.category == category }
    }
    
    func getQuestionsForDifficulty(_ difficulty: QuizDifficulty) -> [QuizQuestion] {
        return sampleQuestions.filter { $0.difficulty == difficulty }
    }
    
    func getRandomQuestion(excluding: [UUID] = []) -> QuizQuestion? {
        let availableQuestions = sampleQuestions.filter { !excluding.contains($0.id) }
        return availableQuestions.randomElement()
    }
}
