//
//  Goal.swift
//  ElevateAno
//
//  Created by Вячеслав on 9/30/25.
//

import Foundation

struct Goal: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var imageData: Data?
    var category: GoalCategory
    var priority: Priority
    var targetDate: Date?
    var isCompleted: Bool
    var createdDate: Date
    var completedDate: Date?
    var reflectionNotes: String
    
    init(title: String, description: String, category: GoalCategory, priority: Priority = .medium, targetDate: Date? = nil) {
        self.title = title
        self.description = description
        self.category = category
        self.priority = priority
        self.targetDate = targetDate
        self.isCompleted = false
        self.createdDate = Date()
        self.reflectionNotes = ""
    }
}

enum GoalCategory: String, CaseIterable, Codable {
    case health = "Health & Fitness"
    case career = "Career & Professional"
    case relationships = "Relationships"
    case personal = "Personal Growth"
    case financial = "Financial"
    case education = "Education & Learning"
    case creativity = "Creativity & Hobbies"
    case spirituality = "Spirituality & Mindfulness"
    
    var icon: String {
        switch self {
        case .health: return "heart.fill"
        case .career: return "briefcase.fill"
        case .relationships: return "person.2.fill"
        case .personal: return "person.fill"
        case .financial: return "dollarsign.circle.fill"
        case .education: return "book.fill"
        case .creativity: return "paintbrush.fill"
        case .spirituality: return "leaf.fill"
        }
    }
}

enum Priority: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "orange"
        case .high: return "red"
        }
    }
}

// Vision Board Item for daily vision boards
struct VisionBoardItem: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var imageData: Data?
    var position: CGPoint
    var createdDate: Date
    
    init(title: String, description: String, position: CGPoint = CGPoint(x: 100, y: 100)) {
        self.title = title
        self.description = description
        self.position = position
        self.createdDate = Date()
    }
}

struct DailyVisionBoard: Identifiable, Codable {
    let id = UUID()
    var date: Date
    var items: [VisionBoardItem]
    var reflectionText: String
    var mood: Mood?
    
    init(date: Date = Date()) {
        self.date = date
        self.items = []
        self.reflectionText = ""
    }
}

enum Mood: String, CaseIterable, Codable {
    case excited = "Excited"
    case motivated = "Motivated"
    case peaceful = "Peaceful"
    case focused = "Focused"
    case grateful = "Grateful"
    case confident = "Confident"
    
    var emoji: String {
        switch self {
        case .excited: return "🤩"
        case .motivated: return "💪"
        case .peaceful: return "😌"
        case .focused: return "🎯"
        case .grateful: return "🙏"
        case .confident: return "😎"
        }
    }
}
