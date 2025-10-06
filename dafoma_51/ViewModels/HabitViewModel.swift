//
//  HabitViewModel.swift
//  ElevateAno
//
//  Created by Вячеслав on 9/30/25.
//

import Foundation
import SwiftUI

class HabitViewModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var selectedHabit: Habit?
    @Published var showingAddHabit = false
    @Published var showingHabitDetail = false
    @Published var selectedTimePeriod: TimePeriod = .week
    
    private let dataStorage = DataStorageService.shared
    
    // Motivational quotes for habits
    private let motivationalQuotes = [
        "Small steps every day lead to big changes every year.",
        "You don't have to be great to get started, but you have to get started to be great.",
        "Success is the sum of small efforts repeated day in and day out.",
        "The secret of getting ahead is getting started.",
        "Don't watch the clock; do what it does. Keep going.",
        "Progress, not perfection.",
        "Every expert was once a beginner.",
        "The best time to plant a tree was 20 years ago. The second best time is now.",
        "Consistency is the mother of mastery.",
        "Your future self will thank you for the habits you build today."
    ]
    
    init() {
        loadHabits()
    }
    
    // MARK: - Habits Management
    
    func loadHabits() {
        habits = dataStorage.loadHabits()
        updateAllStreaks()
    }
    
    func addHabit(_ habit: Habit) {
        var newHabit = habit
        newHabit.motivationalQuote = motivationalQuotes.randomElement()
        habits.append(newHabit)
        saveHabits()
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            saveHabits()
        }
    }
    
    func deleteHabit(with id: UUID) {
        habits.removeAll { $0.id == id }
        saveHabits()
    }
    
    func toggleHabitActive(_ habit: Habit) {
        var updatedHabit = habit
        updatedHabit.isActive.toggle()
        updateHabit(updatedHabit)
    }
    
    private func saveHabits() {
        dataStorage.saveHabits(habits)
    }
    
    // MARK: - Habit Completion
    
    func completeHabit(_ habit: Habit, value: Int = 1, notes: String? = nil) {
        var updatedHabit = habit
        let completion = HabitCompletion(value: value, notes: notes)
        updatedHabit.completions.append(completion)
        updatedHabit.updateStreak()
        updateHabit(updatedHabit)
    }
    
    func undoHabitCompletion(_ habit: Habit) {
        guard habit.isCompletedToday() else { return }
        
        var updatedHabit = habit
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        updatedHabit.completions.removeAll { completion in
            calendar.isDate(completion.date, inSameDayAs: today)
        }
        
        updatedHabit.updateStreak()
        updateHabit(updatedHabit)
    }
    
    func updateAllStreaks() {
        for i in 0..<habits.count {
            habits[i].updateStreak()
        }
        saveHabits()
    }
    
    // MARK: - Analytics and Insights
    
    func getActiveHabitsCount() -> Int {
        return habits.filter { $0.isActive }.count
    }
    
    func getCompletedTodayCount() -> Int {
        return habits.filter { $0.isActive && $0.isCompletedToday() }.count
    }
    
    func getTodayCompletionRate() -> Double {
        let activeHabits = habits.filter { $0.isActive }
        guard !activeHabits.isEmpty else { return 0.0 }
        
        let completedToday = activeHabits.filter { $0.isCompletedToday() }.count
        return Double(completedToday) / Double(activeHabits.count)
    }
    
    func getCurrentStreak() -> Int {
        return habits.filter { $0.isActive }.map { $0.streak }.max() ?? 0
    }
    
    func getLongestStreak() -> Int {
        return habits.map { $0.longestStreak }.max() ?? 0
    }
    
    func getHabitsNeedingAttention() -> [Habit] {
        return habits.filter { habit in
            habit.isActive && 
            !habit.isCompletedToday() && 
            habit.streak > 0 // Has a streak to maintain
        }
    }
    
    func getHabitsByCategory(_ category: HabitCategory) -> [Habit] {
        return habits.filter { $0.category == category }
    }
    
    func getTopPerformingHabits(limit: Int = 5) -> [Habit] {
        return habits
            .filter { $0.isActive }
            .sorted { $0.streak > $1.streak }
            .prefix(limit)
            .map { $0 }
    }
    
    // MARK: - Chart Data
    
    func getWeeklyCompletionData(for habit: Habit) -> [ChartDataPoint] {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        var dataPoints: [ChartDataPoint] = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: i, to: weekStart) ?? weekStart
            let dayName = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
            
            let completions = habit.completions.filter { completion in
                calendar.isDate(completion.date, inSameDayAs: date)
            }
            
            let totalValue = completions.reduce(0) { $0 + $1.value }
            let completionRate = min(Double(totalValue) / Double(habit.targetValue), 1.0)
            
            dataPoints.append(ChartDataPoint(
                label: dayName,
                value: completionRate,
                date: date
            ))
        }
        
        return dataPoints
    }
    
    func getMonthlyCompletionData(for habit: Habit) -> [ChartDataPoint] {
        let calendar = Calendar.current
        let today = Date()
        let monthStart = calendar.dateInterval(of: .month, for: today)?.start ?? today
        let daysInMonth = calendar.range(of: .day, in: .month, for: today)?.count ?? 30
        
        var dataPoints: [ChartDataPoint] = []
        
        for i in 0..<min(daysInMonth, 30) { // Limit to 30 days for chart readability
            let date = calendar.date(byAdding: .day, value: i, to: monthStart) ?? monthStart
            let dayNumber = calendar.component(.day, from: date)
            
            let completions = habit.completions.filter { completion in
                calendar.isDate(completion.date, inSameDayAs: date)
            }
            
            let totalValue = completions.reduce(0) { $0 + $1.value }
            let completionRate = min(Double(totalValue) / Double(habit.targetValue), 1.0)
            
            dataPoints.append(ChartDataPoint(
                label: "\(dayNumber)",
                value: completionRate,
                date: date
            ))
        }
        
        return dataPoints
    }
    
    func getOverallProgressData() -> [CategoryProgress] {
        let categories = HabitCategory.allCases
        var progressData: [CategoryProgress] = []
        
        for category in categories {
            let categoryHabits = habits.filter { $0.category == category && $0.isActive }
            guard !categoryHabits.isEmpty else { continue }
            
            let totalCompletions = categoryHabits.reduce(0) { $0 + $1.completions.count }
            let averageStreak = categoryHabits.reduce(0) { $0 + $1.streak } / categoryHabits.count
            
            progressData.append(CategoryProgress(
                category: category,
                habitCount: categoryHabits.count,
                totalCompletions: totalCompletions,
                averageStreak: averageStreak
            ))
        }
        
        return progressData.sorted { $0.totalCompletions > $1.totalCompletions }
    }
    
    // MARK: - Reminders and Notifications
    
    func getHabitsWithReminders() -> [Habit] {
        return habits.filter { $0.isActive && $0.reminderTime != nil }
    }
    
    func updateReminderTime(for habit: Habit, time: Date?) {
        var updatedHabit = habit
        updatedHabit.reminderTime = time
        updateHabit(updatedHabit)
    }
    
    // MARK: - Search and Filter
    
    func searchHabits(query: String) -> [Habit] {
        guard !query.isEmpty else { return habits }
        
        let lowercasedQuery = query.lowercased()
        return habits.filter { habit in
            habit.name.lowercased().contains(lowercasedQuery) ||
            habit.description.lowercased().contains(lowercasedQuery) ||
            habit.category.rawValue.lowercased().contains(lowercasedQuery)
        }
    }
    
    func getHabits(for frequency: HabitFrequency) -> [Habit] {
        return habits.filter { $0.frequency == frequency }
    }
    
    // MARK: - Motivational Content
    
    func getRandomMotivationalQuote() -> String {
        return motivationalQuotes.randomElement() ?? "Keep going!"
    }
    
    func updateHabitQuote(for habit: Habit) {
        var updatedHabit = habit
        updatedHabit.motivationalQuote = motivationalQuotes.randomElement()
        updateHabit(updatedHabit)
    }
}

// MARK: - Supporting Models

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let date: Date
}

struct CategoryProgress: Identifiable {
    let id = UUID()
    let category: HabitCategory
    let habitCount: Int
    let totalCompletions: Int
    let averageStreak: Int
}

