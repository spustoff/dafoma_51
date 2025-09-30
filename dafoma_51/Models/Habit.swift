//
//  Habit.swift
//  ElevateAno
//
//  Created by Вячеслав on 9/30/25.
//

import Foundation

struct Habit: Identifiable, Codable {
    let id = UUID()
    var name: String
    var description: String
    var category: HabitCategory
    var frequency: HabitFrequency
    var targetValue: Int // For quantifiable habits (e.g., 8 glasses of water)
    var unit: String // e.g., "glasses", "minutes", "times"
    var reminderTime: Date?
    var isActive: Bool
    var createdDate: Date
    var streak: Int
    var longestStreak: Int
    var completions: [HabitCompletion]
    var motivationalQuote: String?
    
    init(name: String, description: String, category: HabitCategory, frequency: HabitFrequency, targetValue: Int = 1, unit: String = "times") {
        self.name = name
        self.description = description
        self.category = category
        self.frequency = frequency
        self.targetValue = targetValue
        self.unit = unit
        self.isActive = true
        self.createdDate = Date()
        self.streak = 0
        self.longestStreak = 0
        self.completions = []
    }
    
    // Calculate current streak
    mutating func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Sort completions by date (most recent first)
        let sortedCompletions = completions.sorted { $0.date > $1.date }
        
        var currentStreak = 0
        var checkDate = today
        
        for completion in sortedCompletions {
            let completionDate = calendar.startOfDay(for: completion.date)
            
            if calendar.isDate(completionDate, inSameDayAs: checkDate) {
                currentStreak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else if completionDate < checkDate {
                break
            }
        }
        
        self.streak = currentStreak
        if currentStreak > longestStreak {
            self.longestStreak = currentStreak
        }
    }
    
    // Check if habit is completed today
    func isCompletedToday() -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return completions.contains { completion in
            calendar.isDate(completion.date, inSameDayAs: today)
        }
    }
    
    // Get completion percentage for current week/month
    func getCompletionRate(for period: TimePeriod) -> Double {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date
        switch period {
        case .week:
            startDate = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        case .month:
            startDate = calendar.dateInterval(of: .month, for: now)?.start ?? now
        case .year:
            startDate = calendar.dateInterval(of: .year, for: now)?.start ?? now
        }
        
        let relevantCompletions = completions.filter { $0.date >= startDate }
        let daysSinceStart = calendar.dateComponents([.day], from: startDate, to: now).day ?? 0
        
        return daysSinceStart > 0 ? Double(relevantCompletions.count) / Double(daysSinceStart + 1) : 0.0
    }
}

struct HabitCompletion: Identifiable, Codable {
    let id = UUID()
    var date: Date
    var value: Int // Actual value achieved (e.g., 6 out of 8 glasses)
    var notes: String?
    
    init(date: Date = Date(), value: Int, notes: String? = nil) {
        self.date = date
        self.value = value
        self.notes = notes
    }
}

enum HabitCategory: String, CaseIterable, Codable {
    case health = "Health & Fitness"
    case mindfulness = "Mindfulness"
    case productivity = "Productivity"
    case learning = "Learning"
    case social = "Social"
    case creativity = "Creativity"
    case selfCare = "Self Care"
    case nutrition = "Nutrition"
    
    var icon: String {
        switch self {
        case .health: return "figure.walk"
        case .mindfulness: return "brain.head.profile"
        case .productivity: return "checkmark.circle"
        case .learning: return "book.circle"
        case .social: return "person.2.circle"
        case .creativity: return "paintbrush.pointed"
        case .selfCare: return "heart.circle"
        case .nutrition: return "leaf.circle"
        }
    }
    
    var color: String {
        switch self {
        case .health: return "green"
        case .mindfulness: return "purple"
        case .productivity: return "blue"
        case .learning: return "orange"
        case .social: return "pink"
        case .creativity: return "yellow"
        case .selfCare: return "red"
        case .nutrition: return "mint"
        }
    }
}

enum HabitFrequency: String, CaseIterable, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case custom = "Custom"
    
    var description: String {
        switch self {
        case .daily: return "Every day"
        case .weekly: return "Once a week"
        case .custom: return "Custom schedule"
        }
    }
}

enum TimePeriod: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}
