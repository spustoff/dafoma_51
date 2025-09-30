//
//  TipViewModel.swift
//  ElevateAno
//
//  Created by Вячеслав on 9/30/25.
//

import Foundation
import SwiftUI

class TipViewModel: ObservableObject {
    @Published var tips: [Tip] = []
    @Published var selectedTip: Tip?
    @Published var selectedCategory: TipCategory?
    @Published var selectedDifficulty: TipDifficulty?
    @Published var searchQuery: String = ""
    @Published var showingTipDetail = false
    @Published var showFavoritesOnly = false
    @Published var showUnreadOnly = false
    
    private let dataStorage = DataStorageService.shared
    
    init() {
        loadTips()
    }
    
    // MARK: - Tips Management
    
    func loadTips() {
        tips = dataStorage.loadTips()
    }
    
    func addTip(_ tip: Tip) {
        tips.append(tip)
        saveTips()
    }
    
    func updateTip(_ tip: Tip) {
        if let index = tips.firstIndex(where: { $0.id == tip.id }) {
            tips[index] = tip
            saveTips()
        }
    }
    
    func deleteTip(with id: UUID) {
        tips.removeAll { $0.id == id }
        saveTips()
    }
    
    func markTipAsRead(_ tip: Tip) {
        var updatedTip = tip
        updatedTip.markAsRead()
        updateTip(updatedTip)
    }
    
    func toggleTipFavorite(_ tip: Tip) {
        var updatedTip = tip
        updatedTip.toggleFavorite()
        updateTip(updatedTip)
    }
    
    private func saveTips() {
        dataStorage.saveTips(tips)
    }
    
    // MARK: - Filtering and Search
    
    var filteredTips: [Tip] {
        var filtered = tips
        
        // Apply category filter
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Apply difficulty filter
        if let difficulty = selectedDifficulty {
            filtered = filtered.filter { $0.difficulty == difficulty }
        }
        
        // Apply favorites filter
        if showFavoritesOnly {
            filtered = filtered.filter { $0.isFavorite }
        }
        
        // Apply unread filter
        if showUnreadOnly {
            filtered = filtered.filter { !$0.isRead }
        }
        
        // Apply search query
        if !searchQuery.isEmpty {
            let lowercasedQuery = searchQuery.lowercased()
            filtered = filtered.filter { tip in
                tip.title.lowercased().contains(lowercasedQuery) ||
                tip.content.lowercased().contains(lowercasedQuery) ||
                tip.tags.contains { $0.lowercased().contains(lowercasedQuery) } ||
                tip.category.rawValue.lowercased().contains(lowercasedQuery)
            }
        }
        
        return filtered.sorted { tip1, tip2 in
            // Sort by favorites first, then by creation date
            if tip1.isFavorite != tip2.isFavorite {
                return tip1.isFavorite && !tip2.isFavorite
            }
            return tip1.createdDate > tip2.createdDate
        }
    }
    
    func getTips(for category: TipCategory) -> [Tip] {
        return tips.filter { $0.category == category }
    }
    
    func getTips(with difficulty: TipDifficulty) -> [Tip] {
        return tips.filter { $0.difficulty == difficulty }
    }
    
    func getFavoriteTips() -> [Tip] {
        return tips.filter { $0.isFavorite }
    }
    
    func getUnreadTips() -> [Tip] {
        return tips.filter { !$0.isRead }
    }
    
    func getRecentlyReadTips(limit: Int = 5) -> [Tip] {
        return tips
            .filter { $0.isRead && $0.readDate != nil }
            .sorted { $0.readDate! > $1.readDate! }
            .prefix(limit)
            .map { $0 }
    }
    
    // MARK: - Analytics and Insights
    
    func getTotalTipsCount() -> Int {
        return tips.count
    }
    
    func getReadTipsCount() -> Int {
        return tips.filter { $0.isRead }.count
    }
    
    func getFavoriteTipsCount() -> Int {
        return tips.filter { $0.isFavorite }.count
    }
    
    func getReadingProgress() -> Double {
        guard !tips.isEmpty else { return 0.0 }
        return Double(getReadTipsCount()) / Double(getTotalTipsCount())
    }
    
    func getCategoryProgress() -> [CategoryReadingProgress] {
        let categories = TipCategory.allCases
        var progressData: [CategoryReadingProgress] = []
        
        for category in categories {
            let categoryTips = tips.filter { $0.category == category }
            guard !categoryTips.isEmpty else { continue }
            
            let readCount = categoryTips.filter { $0.isRead }.count
            let favoriteCount = categoryTips.filter { $0.isFavorite }.count
            let progress = Double(readCount) / Double(categoryTips.count)
            
            progressData.append(CategoryReadingProgress(
                category: category,
                totalTips: categoryTips.count,
                readTips: readCount,
                favoriteTips: favoriteCount,
                progress: progress
            ))
        }
        
        return progressData.sorted { $0.progress > $1.progress }
    }
    
    func getDifficultyDistribution() -> [DifficultyDistribution] {
        let difficulties = TipDifficulty.allCases
        var distribution: [DifficultyDistribution] = []
        
        for difficulty in difficulties {
            let count = tips.filter { $0.difficulty == difficulty }.count
            let readCount = tips.filter { $0.difficulty == difficulty && $0.isRead }.count
            
            distribution.append(DifficultyDistribution(
                difficulty: difficulty,
                totalCount: count,
                readCount: readCount
            ))
        }
        
        return distribution
    }
    
    func getAverageReadingTime() -> Int {
        let readTips = tips.filter { $0.isRead }
        guard !readTips.isEmpty else { return 0 }
        
        let totalTime = readTips.reduce(0) { $0 + $1.estimatedReadTime }
        return totalTime / readTips.count
    }
    
    func getTotalReadingTime() -> Int {
        return tips.filter { $0.isRead }.reduce(0) { $0 + $1.estimatedReadTime }
    }
    
    // MARK: - Recommendations
    
    func getRecommendedTips(limit: Int = 5) -> [Tip] {
        // Recommend unread tips from categories the user has shown interest in
        let readCategories = tips.filter { $0.isRead }.map { $0.category }
        let categoryFrequency = Dictionary(grouping: readCategories, by: { $0 })
            .mapValues { $0.count }
        
        let preferredCategories = categoryFrequency
            .sorted { $0.value > $1.value }
            .prefix(3)
            .map { $0.key }
        
        var recommended = tips.filter { tip in
            !tip.isRead && preferredCategories.contains(tip.category)
        }
        
        // If not enough recommendations, add other unread tips
        if recommended.count < limit {
            let additionalTips = tips.filter { tip in
                !tip.isRead && !recommended.contains(where: { $0.id == tip.id })
            }
            recommended.append(contentsOf: additionalTips)
        }
        
        return Array(recommended.prefix(limit))
    }
    
    func getQuickReadTips(maxReadTime: Int = 3) -> [Tip] {
        return tips.filter { !$0.isRead && $0.estimatedReadTime <= maxReadTime }
    }
    
    func getBeginnerFriendlyTips() -> [Tip] {
        return tips.filter { !$0.isRead && $0.difficulty == .beginner }
    }
    
    // MARK: - Daily Tip
    
    func getDailyTip() -> Tip? {
        let unreadTips = getUnreadTips()
        guard !unreadTips.isEmpty else {
            // If all tips are read, return a random favorite or any tip
            return getFavoriteTips().randomElement() ?? tips.randomElement()
        }
        
        // Prefer shorter tips for daily reading
        let quickTips = unreadTips.filter { $0.estimatedReadTime <= 5 }
        return quickTips.randomElement() ?? unreadTips.randomElement()
    }
    
    // MARK: - Tags Management
    
    func getAllTags() -> [String] {
        let allTags = tips.flatMap { $0.tags }
        return Array(Set(allTags)).sorted()
    }
    
    func getTips(with tag: String) -> [Tip] {
        return tips.filter { $0.tags.contains(tag) }
    }
    
    func getPopularTags(limit: Int = 10) -> [TagFrequency] {
        let allTags = tips.flatMap { $0.tags }
        let tagFrequency = Dictionary(grouping: allTags, by: { $0 })
            .mapValues { $0.count }
        
        return tagFrequency
            .map { TagFrequency(tag: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
            .prefix(limit)
            .map { $0 }
    }
    
    // MARK: - Reset Filters
    
    func resetFilters() {
        selectedCategory = nil
        selectedDifficulty = nil
        searchQuery = ""
        showFavoritesOnly = false
        showUnreadOnly = false
    }
}

// MARK: - Supporting Models

struct CategoryReadingProgress: Identifiable {
    let id = UUID()
    let category: TipCategory
    let totalTips: Int
    let readTips: Int
    let favoriteTips: Int
    let progress: Double
}

struct DifficultyDistribution: Identifiable {
    let id = UUID()
    let difficulty: TipDifficulty
    let totalCount: Int
    let readCount: Int
}

struct TagFrequency: Identifiable {
    let id = UUID()
    let tag: String
    let count: Int
}
