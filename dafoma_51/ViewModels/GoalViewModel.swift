//
//  GoalViewModel.swift
//  ElevateAno
//
//  Created by Вячеслав on 9/30/25.
//

import Foundation
import SwiftUI

class GoalViewModel: ObservableObject {
    @Published var goals: [Goal] = []
    @Published var visionBoards: [DailyVisionBoard] = []
    @Published var selectedGoal: Goal?
    @Published var showingAddGoal = false
    @Published var showingGoalDetail = false
    
    private let dataStorage = DataStorageService.shared
    
    init() {
        loadGoals()
        loadVisionBoards()
    }
    
    // MARK: - Goals Management
    
    func loadGoals() {
        goals = dataStorage.loadGoals()
    }
    
    func addGoal(_ goal: Goal) {
        goals.append(goal)
        saveGoals()
    }
    
    func updateGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            saveGoals()
        }
    }
    
    func deleteGoal(with id: UUID) {
        goals.removeAll { $0.id == id }
        saveGoals()
    }
    
    func toggleGoalCompletion(_ goal: Goal) {
        var updatedGoal = goal
        updatedGoal.isCompleted.toggle()
        
        if updatedGoal.isCompleted {
            updatedGoal.completedDate = Date()
        } else {
            updatedGoal.completedDate = nil
        }
        
        updateGoal(updatedGoal)
    }
    
    private func saveGoals() {
        dataStorage.saveGoals(goals)
    }
    
    // MARK: - Vision Boards Management
    
    func loadVisionBoards() {
        visionBoards = dataStorage.loadVisionBoards()
    }
    
    func getTodaysVisionBoard() -> DailyVisionBoard {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let todaysBoard = visionBoards.first(where: { 
            Calendar.current.isDate($0.date, inSameDayAs: today) 
        }) {
            return todaysBoard
        } else {
            let newBoard = DailyVisionBoard(date: today)
            visionBoards.append(newBoard)
            saveVisionBoards()
            return newBoard
        }
    }
    
    func updateVisionBoard(_ visionBoard: DailyVisionBoard) {
        if let index = visionBoards.firstIndex(where: { $0.id == visionBoard.id }) {
            visionBoards[index] = visionBoard
        } else {
            visionBoards.append(visionBoard)
        }
        saveVisionBoards()
    }
    
    func addVisionBoardItem(_ item: VisionBoardItem, to visionBoard: DailyVisionBoard) {
        var updatedBoard = visionBoard
        updatedBoard.items.append(item)
        updateVisionBoard(updatedBoard)
    }
    
    func removeVisionBoardItem(with id: UUID, from visionBoard: DailyVisionBoard) {
        var updatedBoard = visionBoard
        updatedBoard.items.removeAll { $0.id == id }
        updateVisionBoard(updatedBoard)
    }
    
    func updateVisionBoardReflection(_ reflection: String, for visionBoard: DailyVisionBoard) {
        var updatedBoard = visionBoard
        updatedBoard.reflectionText = reflection
        updateVisionBoard(updatedBoard)
    }
    
    func updateVisionBoardMood(_ mood: Mood, for visionBoard: DailyVisionBoard) {
        var updatedBoard = visionBoard
        updatedBoard.mood = mood
        updateVisionBoard(updatedBoard)
    }
    
    private func saveVisionBoards() {
        dataStorage.saveVisionBoards(visionBoards)
    }
    
    // MARK: - Analytics and Insights
    
    func getGoalsCount(for category: GoalCategory) -> Int {
        return goals.filter { $0.category == category }.count
    }
    
    func getCompletedGoalsCount() -> Int {
        return goals.filter { $0.isCompleted }.count
    }
    
    func getActiveGoalsCount() -> Int {
        return goals.filter { !$0.isCompleted }.count
    }
    
    func getGoalsCompletionRate() -> Double {
        guard !goals.isEmpty else { return 0.0 }
        return Double(getCompletedGoalsCount()) / Double(goals.count)
    }
    
    func getOverdueGoals() -> [Goal] {
        let now = Date()
        return goals.filter { goal in
            !goal.isCompleted && 
            goal.targetDate != nil && 
            goal.targetDate! < now
        }
    }
    
    func getUpcomingGoals(within days: Int = 7) -> [Goal] {
        let now = Date()
        let futureDate = Calendar.current.date(byAdding: .day, value: days, to: now) ?? now
        
        return goals.filter { goal in
            !goal.isCompleted &&
            goal.targetDate != nil &&
            goal.targetDate! >= now &&
            goal.targetDate! <= futureDate
        }.sorted { $0.targetDate! < $1.targetDate! }
    }
    
    func getGoalsByPriority(_ priority: Priority) -> [Goal] {
        return goals.filter { $0.priority == priority && !$0.isCompleted }
    }
    
    func getRecentlyCompletedGoals(limit: Int = 5) -> [Goal] {
        return goals
            .filter { $0.isCompleted && $0.completedDate != nil }
            .sorted { $0.completedDate! > $1.completedDate! }
            .prefix(limit)
            .map { $0 }
    }
    
    // MARK: - Vision Board Analytics
    
    func getVisionBoardStreak() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var streak = 0
        var checkDate = today
        
        while true {
            let hasVisionBoard = visionBoards.contains { visionBoard in
                calendar.isDate(visionBoard.date, inSameDayAs: checkDate) && 
                !visionBoard.items.isEmpty
            }
            
            if hasVisionBoard {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else {
                break
            }
        }
        
        return streak
    }
    
    func getVisionBoardsThisWeek() -> [DailyVisionBoard] {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        return visionBoards.filter { $0.date >= weekStart }
    }
    
    func getMostUsedMood() -> Mood? {
        let moods = visionBoards.compactMap { $0.mood }
        guard !moods.isEmpty else { return nil }
        
        let moodCounts = Dictionary(grouping: moods, by: { $0 })
            .mapValues { $0.count }
        
        return moodCounts.max(by: { $0.value < $1.value })?.key
    }
    
    // MARK: - Search and Filter
    
    func searchGoals(query: String) -> [Goal] {
        guard !query.isEmpty else { return goals }
        
        let lowercasedQuery = query.lowercased()
        return goals.filter { goal in
            goal.title.lowercased().contains(lowercasedQuery) ||
            goal.description.lowercased().contains(lowercasedQuery) ||
            goal.reflectionNotes.lowercased().contains(lowercasedQuery)
        }
    }
    
    func getGoals(for category: GoalCategory) -> [Goal] {
        return goals.filter { $0.category == category }
    }
    
    func getGoals(with priority: Priority) -> [Goal] {
        return goals.filter { $0.priority == priority }
    }
}
