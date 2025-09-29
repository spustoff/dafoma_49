//
//  DataService.swift
//  dafoma_49
//
//  Created by Вячеслав on 9/29/25.
//

import Foundation
import CoreData

class DataService: ObservableObject {
    static let shared = DataService()
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "QuizTrekModel")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data error: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {}
    
    // MARK: - Core Data Operations
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
    
    func delete<T: NSManagedObject>(_ object: T) {
        context.delete(object)
        save()
    }
    
    func fetch<T: NSManagedObject>(_ request: NSFetchRequest<T>) -> [T] {
        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch: \(error)")
            return []
        }
    }
    
    // MARK: - Score Management
    func saveScore(_ scoreEntry: ScoreEntry) {
        let entity = ScoreEntity(context: context)
        entity.id = scoreEntry.id
        entity.playerName = scoreEntry.playerName
        entity.score = Int32(scoreEntry.score)
        entity.gameType = scoreEntry.gameType.rawValue
        entity.difficulty = scoreEntry.difficulty
        entity.date = scoreEntry.date
        entity.timeSpent = scoreEntry.timeSpent
        
        // Save achievements as JSON
        if let achievementsData = try? JSONEncoder().encode(scoreEntry.achievements) {
            entity.achievements = achievementsData
        }
        
        save()
    }
    
    func fetchScores(gameType: GameType? = nil, limit: Int? = nil) -> [ScoreEntry] {
        let request: NSFetchRequest<ScoreEntity> = ScoreEntity.fetchRequest()
        
        if let gameType = gameType {
            request.predicate = NSPredicate(format: "gameType == %@", gameType.rawValue)
        }
        
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ScoreEntity.score, ascending: false)]
        
        if let limit = limit {
            request.fetchLimit = limit
        }
        
        let entities = fetch(request)
        return entities.compactMap { entity in
            guard let id = entity.id,
                  let playerName = entity.playerName,
                  let gameTypeString = entity.gameType,
                  let gameType = GameType(rawValue: gameTypeString),
                  let difficulty = entity.difficulty,
                  let date = entity.date else {
                return nil
            }
            
            var achievements: [Achievement] = []
            if let achievementsData = entity.achievements,
               let decodedAchievements = try? JSONDecoder().decode([Achievement].self, from: achievementsData) {
                achievements = decodedAchievements
            }
            
            return ScoreEntry(
                playerName: playerName,
                score: Int(entity.score),
                gameType: gameType,
                difficulty: difficulty,
                date: date,
                timeSpent: entity.timeSpent,
                achievements: achievements
            )
        }
    }
    
    func getTopScores(gameType: GameType, limit: Int = 10) -> [ScoreEntry] {
        return fetchScores(gameType: gameType, limit: limit)
    }
    
    func getPlayerBestScore(playerName: String, gameType: GameType) -> Int {
        let request: NSFetchRequest<ScoreEntity> = ScoreEntity.fetchRequest()
        request.predicate = NSPredicate(format: "playerName == %@ AND gameType == %@", playerName, gameType.rawValue)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ScoreEntity.score, ascending: false)]
        request.fetchLimit = 1
        
        let entities = fetch(request)
        return Int(entities.first?.score ?? 0)
    }
    
    // MARK: - Achievement Management
    func saveAchievement(_ achievement: Achievement, for playerName: String) {
        let entity = AchievementEntity(context: context)
        entity.id = achievement.id
        entity.playerName = playerName
        entity.title = achievement.title
        entity.achievementDescription = achievement.description
        entity.icon = achievement.icon
        entity.rarity = achievement.rarity.rawValue
        entity.unlockedDate = achievement.unlockedDate
        entity.category = achievement.category.rawValue
        
        save()
    }
    
    func fetchAchievements(for playerName: String) -> [Achievement] {
        let request: NSFetchRequest<AchievementEntity> = AchievementEntity.fetchRequest()
        request.predicate = NSPredicate(format: "playerName == %@", playerName)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AchievementEntity.unlockedDate, ascending: false)]
        
        let entities = fetch(request)
        return entities.compactMap { entity in
            guard let id = entity.id,
                  let title = entity.title,
                  let description = entity.achievementDescription,
                  let icon = entity.icon,
                  let rarityString = entity.rarity,
                  let rarity = AchievementRarity(rawValue: rarityString),
                  let unlockedDate = entity.unlockedDate,
                  let categoryString = entity.category,
                  let category = AchievementCategory(rawValue: categoryString) else {
                return nil
            }
            
            return Achievement(
                title: title,
                description: description,
                icon: icon,
                rarity: rarity,
                unlockedDate: unlockedDate,
                category: category
            )
        }
    }
    
    // MARK: - Statistics
    func getPlayerStatistics(for playerName: String) -> PlayerStatistics {
        let scores = fetchScores().filter { $0.playerName == playerName }
        let achievements = fetchAchievements(for: playerName)
        
        let totalGamesPlayed = scores.count
        let totalScore = scores.reduce(0) { $0 + $1.score }
        let totalTimeSpent = scores.reduce(0) { $0 + $1.timeSpent }
        let averageScore = totalGamesPlayed > 0 ? Double(totalScore) / Double(totalGamesPlayed) : 0
        let bestScore = scores.max(by: { $0.score < $1.score })?.score ?? 0
        
        let totalExperience = totalScore + achievements.reduce(0) { $0 + $1.rarity.points }
        let level = PlayerLevel.calculateLevel(from: totalExperience)
        
        return PlayerStatistics(
            totalGamesPlayed: totalGamesPlayed,
            totalScore: totalScore,
            totalTimeSpent: totalTimeSpent,
            averageScore: averageScore,
            bestScore: bestScore,
            currentStreak: calculateCurrentStreak(for: playerName),
            longestStreak: calculateLongestStreak(for: playerName),
            achievements: achievements,
            level: level,
            quizStats: nil, // Will be populated by QuizDataService
            puzzleStats: nil // Will be populated by PuzzleDataService
        )
    }
    
    private func calculateCurrentStreak(for playerName: String) -> Int {
        // Implementation for calculating current streak
        return 0 // Placeholder
    }
    
    private func calculateLongestStreak(for playerName: String) -> Int {
        // Implementation for calculating longest streak
        return 0 // Placeholder
    }
    
    // MARK: - Data Reset
    func resetAllData() {
        let entities = ["ScoreEntity", "AchievementEntity"]
        
        for entityName in entities {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            
            do {
                try context.execute(deleteRequest)
            } catch {
                print("Failed to delete \(entityName): \(error)")
            }
        }
        
        save()
    }
}

// MARK: - Core Data Entities (These would normally be generated by Core Data)
@objc(ScoreEntity)
class ScoreEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var playerName: String?
    @NSManaged var score: Int32
    @NSManaged var gameType: String?
    @NSManaged var difficulty: String?
    @NSManaged var date: Date?
    @NSManaged var timeSpent: TimeInterval
    @NSManaged var achievements: Data?
}

extension ScoreEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<ScoreEntity> {
        return NSFetchRequest<ScoreEntity>(entityName: "ScoreEntity")
    }
}

@objc(AchievementEntity)
class AchievementEntity: NSManagedObject {
    @NSManaged var id: UUID?
    @NSManaged var playerName: String?
    @NSManaged var title: String?
    @NSManaged var achievementDescription: String?
    @NSManaged var icon: String?
    @NSManaged var rarity: String?
    @NSManaged var unlockedDate: Date?
    @NSManaged var category: String?
}

extension AchievementEntity {
    @nonobjc class func fetchRequest() -> NSFetchRequest<AchievementEntity> {
        return NSFetchRequest<AchievementEntity>(entityName: "AchievementEntity")
    }
}
