//
//  Tip.swift
//  ElevateAno
//
//  Created by Вячеслав on 9/30/25.
//

import Foundation

struct Tip: Identifiable, Codable {
    let id = UUID()
    var title: String
    var content: String
    var category: TipCategory
    var difficulty: TipDifficulty
    var estimatedReadTime: Int // in minutes
    var tags: [String]
    var isFavorite: Bool
    var isRead: Bool
    var readDate: Date?
    var createdDate: Date
    var author: String?
    var actionItems: [String] // Practical steps users can take
    
    init(title: String, content: String, category: TipCategory, difficulty: TipDifficulty = .beginner, estimatedReadTime: Int = 3, tags: [String] = [], author: String? = nil, actionItems: [String] = []) {
        self.title = title
        self.content = content
        self.category = category
        self.difficulty = difficulty
        self.estimatedReadTime = estimatedReadTime
        self.tags = tags
        self.isFavorite = false
        self.isRead = false
        self.createdDate = Date()
        self.author = author
        self.actionItems = actionItems
    }
    
    mutating func markAsRead() {
        self.isRead = true
        self.readDate = Date()
    }
    
    mutating func toggleFavorite() {
        self.isFavorite.toggle()
    }
}

enum TipCategory: String, CaseIterable, Codable {
    case mindfulness = "Mindfulness"
    case productivity = "Productivity"
    case wellness = "Wellness"
    case relationships = "Relationships"
    case career = "Career Development"
    case finance = "Financial Wellness"
    case creativity = "Creativity"
    case leadership = "Leadership"
    case communication = "Communication"
    case timeManagement = "Time Management"
    
    var icon: String {
        switch self {
        case .mindfulness: return "brain.head.profile"
        case .productivity: return "chart.line.uptrend.xyaxis"
        case .wellness: return "heart.text.square"
        case .relationships: return "person.2.wave.2"
        case .career: return "briefcase.circle"
        case .finance: return "dollarsign.circle"
        case .creativity: return "lightbulb"
        case .leadership: return "person.badge.key"
        case .communication: return "bubble.left.and.bubble.right"
        case .timeManagement: return "clock.circle"
        }
    }
    
    var color: String {
        switch self {
        case .mindfulness: return "purple"
        case .productivity: return "blue"
        case .wellness: return "green"
        case .relationships: return "pink"
        case .career: return "orange"
        case .finance: return "yellow"
        case .creativity: return "red"
        case .leadership: return "indigo"
        case .communication: return "teal"
        case .timeManagement: return "brown"
        }
    }
    
    var description: String {
        switch self {
        case .mindfulness: return "Meditation, awareness, and mental clarity"
        case .productivity: return "Efficiency, focus, and getting things done"
        case .wellness: return "Physical and mental health practices"
        case .relationships: return "Building and maintaining connections"
        case .career: return "Professional growth and development"
        case .finance: return "Money management and financial planning"
        case .creativity: return "Artistic expression and innovation"
        case .leadership: return "Guiding and inspiring others"
        case .communication: return "Effective speaking and listening"
        case .timeManagement: return "Organizing and prioritizing your time"
        }
    }
}

enum TipDifficulty: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var color: String {
        switch self {
        case .beginner: return "green"
        case .intermediate: return "orange"
        case .advanced: return "red"
        }
    }
    
    var icon: String {
        switch self {
        case .beginner: return "1.circle.fill"
        case .intermediate: return "2.circle.fill"
        case .advanced: return "3.circle.fill"
        }
    }
}

// Sample tips data for the app
extension Tip {
    static let sampleTips: [Tip] = [
        Tip(
            title: "The 5-Minute Morning Meditation",
            content: "Start your day with clarity and intention. Find a quiet space, sit comfortably, and focus on your breath for just 5 minutes. This simple practice can transform your entire day by reducing stress and increasing focus.\n\nBegin by taking three deep breaths, then allow your breathing to return to its natural rhythm. When thoughts arise, gently acknowledge them and return your attention to your breath. Remember, meditation is not about stopping thoughts, but about observing them without judgment.",
            category: .mindfulness,
            difficulty: .beginner,
            estimatedReadTime: 2,
            tags: ["meditation", "morning routine", "stress relief"],
            author: "ElevateAno Team",
            actionItems: [
                "Set aside 5 minutes each morning",
                "Find a quiet, comfortable space",
                "Focus on your natural breathing",
                "Practice daily for one week"
            ]
        ),
        Tip(
            title: "The Pomodoro Technique for Peak Productivity",
            content: "Boost your productivity with this time-tested technique. Work in focused 25-minute intervals followed by 5-minute breaks. After four cycles, take a longer 15-30 minute break.\n\nThis method helps maintain concentration while preventing burnout. Choose one task, eliminate distractions, and commit fully to the 25-minute work session. The timer creates urgency and helps you stay focused.",
            category: .productivity,
            difficulty: .beginner,
            estimatedReadTime: 3,
            tags: ["time management", "focus", "work efficiency"],
            author: "ElevateAno Team",
            actionItems: [
                "Choose one important task",
                "Set a timer for 25 minutes",
                "Work without distractions",
                "Take a 5-minute break",
                "Repeat for 4 cycles"
            ]
        ),
        Tip(
            title: "Building Authentic Relationships",
            content: "Authentic relationships are built on genuine interest in others. Practice active listening by giving your full attention when someone speaks. Ask thoughtful questions and remember details from previous conversations.\n\nVulnerability creates connection. Share your own experiences and challenges appropriately. Be consistent in your interactions and follow through on commitments. Quality relationships require time and intentional effort.",
            category: .relationships,
            difficulty: .intermediate,
            estimatedReadTime: 4,
            tags: ["communication", "empathy", "connection"],
            author: "ElevateAno Team",
            actionItems: [
                "Practice active listening daily",
                "Ask one meaningful question in conversations",
                "Remember and reference past conversations",
                "Share something personal when appropriate",
                "Follow through on all commitments"
            ]
        )
    ]
}

