//
//  CommunityViewModel.swift
//  ElevateAno
//
//  Created by Вячеслав on 9/30/25.
//

import Foundation
import SwiftUI

class CommunityViewModel: ObservableObject {
    @Published var stories: [CommunityStory] = []
    @Published var selectedStory: CommunityStory?
    @Published var selectedCategory: StoryCategory?
    @Published var selectedInspirationLevel: InspirationLevel?
    @Published var searchQuery: String = ""
    @Published var showingStoryDetail = false
    @Published var showingAddStory = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let communityService = CommunityService.shared
    
    init() {
        loadStories()
        
        // Observe changes from the service
        communityService.$stories
            .assign(to: &$stories)
        
        communityService.$isLoading
            .assign(to: &$isLoading)
        
        communityService.$errorMessage
            .assign(to: &$errorMessage)
    }
    
    // MARK: - Stories Management
    
    func loadStories() {
        communityService.loadStories()
    }
    
    func addStory(_ story: CommunityStory) {
        let validationResult = communityService.validateStory(story)
        
        if validationResult.isValid {
            communityService.addStory(story)
            errorMessage = nil
        } else {
            errorMessage = validationResult.errors.first
        }
    }
    
    func toggleLike(for story: CommunityStory) {
        communityService.toggleLike(for: story.id)
    }
    
    func deleteStory(with id: UUID) {
        communityService.deleteStory(with: id)
    }
    
    // MARK: - Filtering and Search
    
    var filteredStories: [CommunityStory] {
        var filtered = stories
        
        // Apply category filter
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Apply inspiration level filter
        if let inspirationLevel = selectedInspirationLevel {
            filtered = filtered.filter { $0.inspirationLevel == inspirationLevel }
        }
        
        // Apply search query
        if !searchQuery.isEmpty {
            filtered = communityService.searchStories(query: searchQuery)
        }
        
        return filtered.sorted { $0.createdDate > $1.createdDate }
    }
    
    func getStories(for category: StoryCategory) -> [CommunityStory] {
        return communityService.getStories(for: category)
    }
    
    func getStories(with inspirationLevel: InspirationLevel) -> [CommunityStory] {
        return communityService.getStories(with: inspirationLevel)
    }
    
    func getMostLikedStories(limit: Int = 10) -> [CommunityStory] {
        return communityService.getMostLikedStories(limit: limit)
    }
    
    func getRecentStories(limit: Int = 10) -> [CommunityStory] {
        return communityService.getRecentStories(limit: limit)
    }
    
    // MARK: - Analytics and Insights
    
    func getTotalStoriesCount() -> Int {
        return stories.count
    }
    
    func getTotalLikes() -> Int {
        return communityService.getTotalLikes()
    }
    
    func getAverageStoryLength() -> Int {
        return communityService.getAverageStoryLength()
    }
    
    func getCategoryDistribution() -> [CategoryStoryCount] {
        let categories = StoryCategory.allCases
        var distribution: [CategoryStoryCount] = []
        
        for category in categories {
            let count = communityService.getStoriesCount(for: category)
            if count > 0 {
                distribution.append(CategoryStoryCount(
                    category: category,
                    count: count
                ))
            }
        }
        
        return distribution.sorted { $0.count > $1.count }
    }
    
    func getInspirationLevelDistribution() -> [InspirationLevelCount] {
        let levels = InspirationLevel.allCases
        var distribution: [InspirationLevelCount] = []
        
        for level in levels {
            let count = stories.filter { $0.inspirationLevel == level }.count
            if count > 0 {
                distribution.append(InspirationLevelCount(
                    level: level,
                    count: count
                ))
            }
        }
        
        return distribution.sorted { $0.count > $1.count }
    }
    
    func getPopularTags(limit: Int = 10) -> [TagCount] {
        let allTags = stories.flatMap { $0.tags }
        let tagFrequency = Dictionary(grouping: allTags, by: { $0 })
            .mapValues { $0.count }
        
        return tagFrequency
            .map { TagCount(tag: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
            .prefix(limit)
            .map { $0 }
    }
    
    // MARK: - Story Templates
    
    func getStoryTemplates() -> [StoryTemplate] {
        return communityService.getStoryTemplates()
    }
    
    func createStoryFromTemplate(_ template: StoryTemplate, title: String, content: String, isAnonymous: Bool = true, authorName: String? = nil) -> CommunityStory {
        return CommunityStory(
            title: title,
            content: content,
            category: template.category,
            isAnonymous: isAnonymous,
            authorName: authorName,
            tags: template.suggestedTags
        )
    }
    
    // MARK: - Inspiration and Motivation
    
    func getInspirationalStories(limit: Int = 5) -> [CommunityStory] {
        return stories
            .filter { $0.inspirationLevel == .high }
            .sorted { $0.likes > $1.likes }
            .prefix(limit)
            .map { $0 }
    }
    
    func getStoriesWithMilestones() -> [CommunityStory] {
        return stories.filter { $0.milestone != nil }
    }
    
    func getRandomInspirationalStory() -> CommunityStory? {
        let inspirationalStories = stories.filter { 
            $0.inspirationLevel == .high || $0.inspirationLevel == .moderate 
        }
        return inspirationalStories.randomElement()
    }
    
    // MARK: - User Engagement
    
    func getUserLikedStories() -> [CommunityStory] {
        return stories.filter { $0.isLikedByUser }
    }
    
    func getStoriesUserCanRelateToBasedOnCategories(_ userCategories: [StoryCategory]) -> [CommunityStory] {
        return stories.filter { story in
            userCategories.contains(story.category)
        }.sorted { $0.likes > $1.likes }
    }
    
    // MARK: - Content Moderation
    
    func reportStory(_ story: CommunityStory, reason: String) {
        // In a real app, this would send a report to moderators
        // For now, we'll just log it
        print("Story reported: \(story.title) - Reason: \(reason)")
    }
    
    func validateStoryContent(_ story: CommunityStory) -> ValidationResult {
        return communityService.validateStory(story)
    }
    
    // MARK: - Reset Filters
    
    func resetFilters() {
        selectedCategory = nil
        selectedInspirationLevel = nil
        searchQuery = ""
    }
    
    // MARK: - Sharing and Export
    
    func getShareableText(for story: CommunityStory) -> String {
        let author = story.displayAuthor
        let milestone = story.milestone != nil ? " - \(story.milestone!)" : ""
        
        return """
        "\(story.title)"\(milestone)
        
        \(story.content)
        
        - \(author)
        
        Shared from ElevateAno - Your Personal Growth Companion
        """
    }
    
    // MARK: - Statistics for User
    
    func getReadingStats() -> CommunityReadingStats {
        let totalStories = stories.count
        let likedStories = getUserLikedStories().count
        let categoriesExplored = Set(stories.map { $0.category }).count
        let averageStoryLength = getAverageStoryLength()
        
        return CommunityReadingStats(
            totalStoriesRead: totalStories,
            storiesLiked: likedStories,
            categoriesExplored: categoriesExplored,
            averageStoryLength: averageStoryLength
        )
    }
}

// MARK: - Supporting Models

struct CategoryStoryCount: Identifiable {
    let id = UUID()
    let category: StoryCategory
    let count: Int
}

struct InspirationLevelCount: Identifiable {
    let id = UUID()
    let level: InspirationLevel
    let count: Int
}

struct TagCount: Identifiable {
    let id = UUID()
    let tag: String
    let count: Int
}

struct CommunityReadingStats {
    let totalStoriesRead: Int
    let storiesLiked: Int
    let categoriesExplored: Int
    let averageStoryLength: Int
}
