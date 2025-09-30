//
//  DataStorageService.swift
//  ElevateAno
//
//  Created by Вячеслав on 9/30/25.
//

import Foundation

class DataStorageService: ObservableObject {
    static let shared = DataStorageService()
    
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // Keys for UserDefaults
    private enum Keys {
        static let goals = "elevate_goals"
        static let habits = "elevate_habits"
        static let tips = "elevate_tips"
        static let communityStories = "elevate_community_stories"
        static let visionBoards = "elevate_vision_boards"
        static let hasCompletedOnboarding = "elevate_onboarding_completed"
        static let userPreferences = "elevate_user_preferences"
    }
    
    private init() {
        // Initialize with sample data if first launch
        if !hasCompletedOnboarding {
            initializeSampleData()
        }
    }
    
    // MARK: - Goals Management
    
    func saveGoals(_ goals: [Goal]) {
        if let encoded = try? encoder.encode(goals) {
            userDefaults.set(encoded, forKey: Keys.goals)
        }
    }
    
    func loadGoals() -> [Goal] {
        guard let data = userDefaults.data(forKey: Keys.goals),
              let goals = try? decoder.decode([Goal].self, from: data) else {
            return []
        }
        return goals
    }
    
    // MARK: - Habits Management
    
    func saveHabits(_ habits: [Habit]) {
        if let encoded = try? encoder.encode(habits) {
            userDefaults.set(encoded, forKey: Keys.habits)
        }
    }
    
    func loadHabits() -> [Habit] {
        guard let data = userDefaults.data(forKey: Keys.habits),
              let habits = try? decoder.decode([Habit].self, from: data) else {
            return []
        }
        return habits
    }
    
    // MARK: - Tips Management
    
    func saveTips(_ tips: [Tip]) {
        if let encoded = try? encoder.encode(tips) {
            userDefaults.set(encoded, forKey: Keys.tips)
        }
    }
    
    func loadTips() -> [Tip] {
        guard let data = userDefaults.data(forKey: Keys.tips),
              let tips = try? decoder.decode([Tip].self, from: data) else {
            return Tip.sampleTips // Return sample tips if none saved
        }
        return tips
    }
    
    // MARK: - Community Stories Management
    
    func saveCommunityStories(_ stories: [CommunityStory]) {
        if let encoded = try? encoder.encode(stories) {
            userDefaults.set(encoded, forKey: Keys.communityStories)
        }
    }
    
    func loadCommunityStories() -> [CommunityStory] {
        guard let data = userDefaults.data(forKey: Keys.communityStories),
              let stories = try? decoder.decode([CommunityStory].self, from: data) else {
            return CommunityStory.sampleStories // Return sample stories if none saved
        }
        return stories
    }
    
    // MARK: - Vision Boards Management
    
    func saveVisionBoards(_ visionBoards: [DailyVisionBoard]) {
        if let encoded = try? encoder.encode(visionBoards) {
            userDefaults.set(encoded, forKey: Keys.visionBoards)
        }
    }
    
    func loadVisionBoards() -> [DailyVisionBoard] {
        guard let data = userDefaults.data(forKey: Keys.visionBoards),
              let visionBoards = try? decoder.decode([DailyVisionBoard].self, from: data) else {
            return []
        }
        return visionBoards
    }
    
    // MARK: - User Preferences
    
    var hasCompletedOnboarding: Bool {
        get { userDefaults.bool(forKey: Keys.hasCompletedOnboarding) }
        set { userDefaults.set(newValue, forKey: Keys.hasCompletedOnboarding) }
    }
    
    func saveUserPreferences(_ preferences: UserPreferences) {
        if let encoded = try? encoder.encode(preferences) {
            userDefaults.set(encoded, forKey: Keys.userPreferences)
        }
    }
    
    func loadUserPreferences() -> UserPreferences {
        guard let data = userDefaults.data(forKey: Keys.userPreferences),
              let preferences = try? decoder.decode(UserPreferences.self, from: data) else {
            return UserPreferences() // Return default preferences
        }
        return preferences
    }
    
    // MARK: - Data Management
    
    func clearAllData() {
        let keys = [Keys.goals, Keys.habits, Keys.tips, Keys.communityStories, Keys.visionBoards, Keys.userPreferences]
        keys.forEach { userDefaults.removeObject(forKey: $0) }
    }
    
    func resetToDefaults() {
        clearAllData()
        hasCompletedOnboarding = false
        initializeSampleData()
    }
    
    private func initializeSampleData() {
        // Initialize with sample tips and community stories
        saveTips(Tip.sampleTips)
        saveCommunityStories(CommunityStory.sampleStories)
        
        // Initialize with empty arrays for user-generated content
        saveGoals([])
        saveHabits([])
        saveVisionBoards([])
        saveUserPreferences(UserPreferences())
    }
    
    // MARK: - Export/Import (for future use)
    
    func exportUserData() -> Data? {
        let userData = UserData(
            goals: loadGoals(),
            habits: loadHabits(),
            tips: loadTips(),
            communityStories: loadCommunityStories(),
            visionBoards: loadVisionBoards(),
            preferences: loadUserPreferences()
        )
        
        return try? encoder.encode(userData)
    }
    
    func importUserData(_ data: Data) -> Bool {
        guard let userData = try? decoder.decode(UserData.self, from: data) else {
            return false
        }
        
        saveGoals(userData.goals)
        saveHabits(userData.habits)
        saveTips(userData.tips)
        saveCommunityStories(userData.communityStories)
        saveVisionBoards(userData.visionBoards)
        saveUserPreferences(userData.preferences)
        
        return true
    }
}

// MARK: - Supporting Models

struct UserPreferences: Codable {
    var notificationsEnabled: Bool = true
    var dailyReminderTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    var preferredCategories: [String] = []
    var darkModeEnabled: Bool = false
    var weekStartsOnMonday: Bool = true
    var showMotivationalQuotes: Bool = true
    
    init() {}
}

struct UserData: Codable {
    let goals: [Goal]
    let habits: [Habit]
    let tips: [Tip]
    let communityStories: [CommunityStory]
    let visionBoards: [DailyVisionBoard]
    let preferences: UserPreferences
}
