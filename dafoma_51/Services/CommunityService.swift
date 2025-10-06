//
//  CommunityService.swift
//  ElevateAno
//
//  Created by Вячеслав on 9/30/25.
//

import Foundation

class CommunityService: ObservableObject {
    static let shared = CommunityService()
    
    private let dataStorage = DataStorageService.shared
    @Published var stories: [CommunityStory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {
        loadStories()
    }
    
    // MARK: - Story Management
    
    func loadStories() {
        isLoading = true
        
        // Simulate network delay for realistic UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.stories = self.dataStorage.loadCommunityStories()
                .sorted { $0.createdDate > $1.createdDate } // Most recent first
            self.isLoading = false
        }
    }
    
    func addStory(_ story: CommunityStory) {
        var newStory = story
        newStory.createdDate = Date()
        
        stories.insert(newStory, at: 0) // Add to beginning
        saveStories()
        
        // Simulate success feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Could show success message here
        }
    }
    
    func toggleLike(for storyId: UUID) {
        guard let index = stories.firstIndex(where: { $0.id == storyId }) else { return }
        
        stories[index].toggleLike()
        saveStories()
    }
    
    func deleteStory(with id: UUID) {
        stories.removeAll { $0.id == id }
        saveStories()
    }
    
    private func saveStories() {
        dataStorage.saveCommunityStories(stories)
    }
    
    // MARK: - Filtering and Searching
    
    func getStories(for category: StoryCategory) -> [CommunityStory] {
        return stories.filter { $0.category == category }
    }
    
    func getStories(with inspirationLevel: InspirationLevel) -> [CommunityStory] {
        return stories.filter { $0.inspirationLevel == inspirationLevel }
    }
    
    func searchStories(query: String) -> [CommunityStory] {
        guard !query.isEmpty else { return stories }
        
        let lowercasedQuery = query.lowercased()
        return stories.filter { story in
            story.title.lowercased().contains(lowercasedQuery) ||
            story.content.lowercased().contains(lowercasedQuery) ||
            story.tags.contains { $0.lowercased().contains(lowercasedQuery) } ||
            story.milestone?.lowercased().contains(lowercasedQuery) == true
        }
    }
    
    func getMostLikedStories(limit: Int = 10) -> [CommunityStory] {
        return stories
            .sorted { $0.likes > $1.likes }
            .prefix(limit)
            .map { $0 }
    }
    
    func getRecentStories(limit: Int = 10) -> [CommunityStory] {
        return stories
            .sorted { $0.createdDate > $1.createdDate }
            .prefix(limit)
            .map { $0 }
    }
    
    // MARK: - Story Analytics (for user insights)
    
    func getStoriesCount(for category: StoryCategory) -> Int {
        return stories.filter { $0.category == category }.count
    }
    
    func getTotalLikes() -> Int {
        return stories.reduce(0) { $0 + $1.likes }
    }
    
    func getAverageStoryLength() -> Int {
        guard !stories.isEmpty else { return 0 }
        let totalLength = stories.reduce(0) { $0 + $1.content.count }
        return totalLength / stories.count
    }
    
    // MARK: - Story Validation
    
    func validateStory(_ story: CommunityStory) -> ValidationResult {
        var errors: [String] = []
        
        if story.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Title cannot be empty")
        }
        
        if story.title.count > 100 {
            errors.append("Title must be 100 characters or less")
        }
        
        if story.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Story content cannot be empty")
        }
        
        if story.content.count < 50 {
            errors.append("Story must be at least 50 characters long")
        }
        
        if story.content.count > 2000 {
            errors.append("Story must be 2000 characters or less")
        }
        
        // Check for inappropriate content (basic filtering)
        let inappropriateWords = ["spam", "advertisement", "buy now", "click here"]
        let lowercasedContent = story.content.lowercased()
        let lowercasedTitle = story.title.lowercased()
        
        for word in inappropriateWords {
            if lowercasedContent.contains(word) || lowercasedTitle.contains(word) {
                errors.append("Content appears to contain promotional material")
                break
            }
        }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors)
    }
    
    // MARK: - Story Templates (to help users get started)
    
    func getStoryTemplates() -> [StoryTemplate] {
        return [
            StoryTemplate(
                title: "Overcoming a Challenge",
                prompt: "Share about a personal challenge you faced and how you overcame it. What strategies worked? What would you tell someone facing a similar situation?",
                category: .general,
                suggestedTags: ["challenge", "growth", "perseverance"]
            ),
            StoryTemplate(
                title: "Building a New Habit",
                prompt: "Tell us about a positive habit you've developed. How did you start? What kept you motivated? What changes have you noticed?",
                category: .healthFitness,
                suggestedTags: ["habits", "routine", "consistency"]
            ),
            StoryTemplate(
                title: "Career Breakthrough",
                prompt: "Describe a moment or period that significantly impacted your career. What did you learn? How did it change your perspective?",
                category: .career,
                suggestedTags: ["career", "professional growth", "breakthrough"]
            ),
            StoryTemplate(
                title: "Mindfulness Journey",
                prompt: "Share your experience with meditation, mindfulness, or mental health practices. What techniques have helped you find peace and clarity?",
                category: .mentalHealth,
                suggestedTags: ["mindfulness", "meditation", "mental health"]
            )
        ]
    }
}

// MARK: - Supporting Models

struct ValidationResult {
    let isValid: Bool
    let errors: [String]
}

struct StoryTemplate {
    let title: String
    let prompt: String
    let category: StoryCategory
    let suggestedTags: [String]
}

