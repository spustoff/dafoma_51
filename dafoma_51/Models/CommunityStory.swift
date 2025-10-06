//
//  CommunityStory.swift
//  ElevateAno
//
//  Created by Вячеслав on 9/30/25.
//

import Foundation

struct CommunityStory: Identifiable, Codable {
    let id = UUID()
    var title: String
    var content: String
    var category: StoryCategory
    var isAnonymous: Bool
    var authorName: String? // Only if not anonymous
    var createdDate: Date
    var likes: Int
    var isLikedByUser: Bool
    var tags: [String]
    var milestone: String? // e.g., "30 days smoke-free", "Lost 20 pounds"
    var inspirationLevel: InspirationLevel
    
    init(title: String, content: String, category: StoryCategory, isAnonymous: Bool = true, authorName: String? = nil, milestone: String? = nil, inspirationLevel: InspirationLevel = .moderate, tags: [String] = []) {
        self.title = title
        self.content = content
        self.category = category
        self.isAnonymous = isAnonymous
        self.authorName = isAnonymous ? nil : authorName
        self.createdDate = Date()
        self.likes = 0
        self.isLikedByUser = false
        self.milestone = milestone
        self.inspirationLevel = inspirationLevel
        self.tags = tags
    }
    
    mutating func toggleLike() {
        if isLikedByUser {
            likes -= 1
        } else {
            likes += 1
        }
        isLikedByUser.toggle()
    }
    
    var displayAuthor: String {
        return isAnonymous ? "Anonymous" : (authorName ?? "Anonymous")
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdDate, relativeTo: Date())
    }
}

enum StoryCategory: String, CaseIterable, Codable {
    case healthFitness = "Health & Fitness"
    case mentalHealth = "Mental Health"
    case career = "Career Growth"
    case relationships = "Relationships"
    case addiction = "Overcoming Addiction"
    case education = "Education & Learning"
    case creativity = "Creative Journey"
    case spirituality = "Spiritual Growth"
    case financial = "Financial Freedom"
    case general = "General Growth"
    
    var icon: String {
        switch self {
        case .healthFitness: return "figure.run"
        case .mentalHealth: return "brain.head.profile"
        case .career: return "briefcase"
        case .relationships: return "heart.2"
        case .addiction: return "shield.checkered"
        case .education: return "graduationcap"
        case .creativity: return "paintbrush.pointed"
        case .spirituality: return "leaf"
        case .financial: return "dollarsign.circle"
        case .general: return "star"
        }
    }
    
    var color: String {
        switch self {
        case .healthFitness: return "green"
        case .mentalHealth: return "purple"
        case .career: return "blue"
        case .relationships: return "pink"
        case .addiction: return "orange"
        case .education: return "indigo"
        case .creativity: return "yellow"
        case .spirituality: return "mint"
        case .financial: return "brown"
        case .general: return "gray"
        }
    }
}

enum InspirationLevel: String, CaseIterable, Codable {
    case low = "Gentle"
    case moderate = "Motivating"
    case high = "Transformational"
    
    var emoji: String {
        switch self {
        case .low: return "🌱"
        case .moderate: return "🌟"
        case .high: return "🚀"
        }
    }
    
    var description: String {
        switch self {
        case .low: return "Small steps, big impact"
        case .moderate: return "Inspiring progress"
        case .high: return "Life-changing journey"
        }
    }
}

// Sample community stories for the app
extension CommunityStory {
    static let sampleStories: [CommunityStory] = [
        CommunityStory(
            title: "From Couch to 5K: My Running Journey",
            content: "Six months ago, I couldn't run for more than 30 seconds without getting winded. Today, I completed my first 5K race! The key was starting small - just walking for 10 minutes a day, then gradually adding short running intervals.\n\nThe hardest part wasn't the physical challenge, but overcoming the voice in my head that said I wasn't a 'runner.' Every small victory built my confidence. Now I look forward to my morning runs - they've become my meditation time.\n\nTo anyone starting their fitness journey: be patient with yourself. Progress isn't always linear, but consistency beats perfection every time.",
            category: .healthFitness,
            milestone: "Completed first 5K",
            inspirationLevel: .high,
            tags: ["running", "fitness", "perseverance", "beginner"]
        ),
        CommunityStory(
            title: "Learning to Say No: Setting Boundaries at Work",
            content: "I used to say yes to everything at work, thinking it would make me indispensable. Instead, I became overwhelmed, stressed, and my quality of work suffered. Learning to set boundaries was scary but necessary.\n\nI started by evaluating each request against my core responsibilities and goals. I practiced saying 'Let me check my capacity and get back to you' instead of immediately agreeing. I also learned to propose alternatives when I couldn't take on additional work.\n\nThe result? Better work quality, less stress, and surprisingly, more respect from colleagues. Boundaries aren't walls - they're guidelines for healthy relationships.",
            category: .career,
            milestone: "Reduced overtime by 50%",
            inspirationLevel: .moderate,
            tags: ["boundaries", "workplace", "stress management", "communication"]
        ),
        CommunityStory(
            title: "Finding Peace Through Daily Meditation",
            content: "Anxiety controlled my life for years. Simple decisions felt overwhelming, and I was constantly worried about the future. A friend suggested meditation, but I thought it was too 'woo-woo' for me.\n\nI started with just 3 minutes a day using a simple breathing technique. It felt awkward at first, but I committed to 30 days. Gradually, I noticed small changes - I could pause before reacting, sleep came easier, and that constant mental chatter quieted down.\n\nNow, 8 months later, meditation is non-negotiable in my routine. It's not about emptying your mind - it's about changing your relationship with your thoughts. This practice gave me my life back.",
            category: .mentalHealth,
            milestone: "8 months of daily meditation",
            inspirationLevel: .high,
            tags: ["meditation", "anxiety", "mindfulness", "mental health"]
        ),
        CommunityStory(
            title: "Rebuilding After Financial Rock Bottom",
            content: "Two years ago, I had $50 to my name and was living paycheck to paycheck. Credit cards were maxed out, and I felt hopeless about my financial future. The turning point came when I finally faced the numbers honestly.\n\nI created a simple budget, started tracking every expense, and found small ways to cut costs. I picked up a weekend side job and put every extra dollar toward debt. The progress was slow but steady.\n\nToday, I have an emergency fund and I'm debt-free except for my mortgage. The journey taught me that financial freedom isn't about making more money - it's about being intentional with what you have.",
            category: .financial,
            milestone: "Debt-free in 18 months",
            inspirationLevel: .high,
            tags: ["debt", "budgeting", "financial planning", "discipline"]
        )
    ]
}

