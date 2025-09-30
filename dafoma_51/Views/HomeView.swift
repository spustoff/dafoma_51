//
//  HomeView.swift
//  ElevateAno
//
//  Created by Вячеслав on 9/30/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var goalViewModel: GoalViewModel
    @EnvironmentObject var habitViewModel: HabitViewModel
    @State private var showingAddGoal = false
    @State private var showingAddHabit = false
    @State private var showingAddVisionItem = false
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Quick Stats
                    quickStatsSection
                    
                    // Today's Focus
                    todaysFocusSection
                    
                    // Recent Activity
                    recentActivitySection
                    
                    // Motivational Section
                    motivationalSection
                }
                .padding(.horizontal)
                .padding(.bottom, 100) // Extra padding for tab bar
            }
            .background(Color.white.ignoresSafeArea())
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .refreshable {
            goalViewModel.loadGoals()
            habitViewModel.loadHabits()
        }
        .sheet(isPresented: $showingAddGoal) {
            AddGoalView { goal in
                goalViewModel.addGoal(goal)
            }
        }
        .sheet(isPresented: $showingAddHabit) {
            AddHabitView { habit in
                habitViewModel.addHabit(habit)
            }
        }
        .sheet(isPresented: $showingAddVisionItem) {
            AddVisionBoardItemView { item in
                let todaysBoard = goalViewModel.getTodaysVisionBoard()
                goalViewModel.addVisionBoardItem(item, to: todaysBoard)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greeting)
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("Ready to elevate your day?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primary)
                }
                
                Spacer()
                
                // Profile/Settings button
                Button(action: {
                    // Navigate to settings
                }) {
                    Image(systemName: "person.circle.fill")
                        .font(.title)
                        .foregroundColor(Color(hex: "#FF3C00"))
                }
            }
            
            // Date
            Text(Date().formatted(date: .complete, time: .omitted))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top, 20)
    }
    
    private var quickStatsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Today's Progress")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            HStack(spacing: 16) {
                // Goals Progress
                StatCard(
                    title: "Goals",
                    value: "\(goalViewModel.getCompletedGoalsCount())",
                    subtitle: "of \(goalViewModel.goals.count) completed",
                    icon: "target",
                    color: Color(hex: "#FF3C00"),
                    progress: goalViewModel.getGoalsCompletionRate()
                )
                
                // Habits Progress
                StatCard(
                    title: "Habits",
                    value: "\(habitViewModel.getCompletedTodayCount())",
                    subtitle: "of \(habitViewModel.getActiveHabitsCount()) done today",
                    icon: "checkmark.circle.fill",
                    color: Color(hex: "#FF3C00"),
                    progress: habitViewModel.getTodayCompletionRate()
                )
            }
            
            HStack(spacing: 16) {
                // Current Streak
                StatCard(
                    title: "Streak",
                    value: "\(habitViewModel.getCurrentStreak())",
                    subtitle: "days current best",
                    icon: "flame.fill",
                    color: .orange,
                    progress: nil
                )
                
                // Vision Board Streak
                StatCard(
                    title: "Vision",
                    value: "\(goalViewModel.getVisionBoardStreak())",
                    subtitle: "days of vision boards",
                    icon: "eye.fill",
                    color: .purple,
                    progress: nil
                )
            }
        }
    }
    
    private var todaysFocusSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Today's Focus")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            let todaysBoard = goalViewModel.getTodaysVisionBoard()
            
            if todaysBoard.items.isEmpty {
                // Empty state
                VStack(spacing: 12) {
                    Image(systemName: "target")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("Set your daily intentions")
                        .font(.headline)
                        .foregroundColor(Color.primary)
                    
                    Text("Create a vision board to focus your energy today")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Create Vision Board") {
                        showingAddVisionItem = true
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color(hex: "#FF3C00"))
                    .cornerRadius(20)
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
            } else {
                // Show vision board items
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    ForEach(todaysBoard.items.prefix(4)) { item in
                        VisionBoardItemCard(item: item)
                    }
                }
                
                if todaysBoard.items.count > 4 {
                    Text("+ \(todaysBoard.items.count - 4) more items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var recentActivitySection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                // Recent completed goals
                ForEach(goalViewModel.getRecentlyCompletedGoals(limit: 3)) { goal in
                    ActivityRow(
                        icon: "checkmark.circle.fill",
                        iconColor: .green,
                        title: goal.title,
                        subtitle: "Goal completed",
                        time: goal.completedDate?.formatted(date: .omitted, time: .shortened) ?? ""
                    )
                }
                
                // Habits completed today
                ForEach(habitViewModel.habits.filter { $0.isCompletedToday() }.prefix(3)) { habit in
                    ActivityRow(
                        icon: "checkmark.circle.fill",
                        iconColor: Color(hex: "#FF3C00"),
                        title: habit.name,
                        subtitle: "Habit completed",
                        time: "Today"
                    )
                }
                
                if goalViewModel.getRecentlyCompletedGoals(limit: 3).isEmpty && 
                   habitViewModel.habits.filter({ $0.isCompletedToday() }).isEmpty {
                    Text("No recent activity")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 20)
                }
            }
        }
    }
    
    private var motivationalSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Daily Inspiration")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                Text(habitViewModel.getRandomMotivationalQuote())
                    .font(.body)
                    .italic()
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.primary)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "#FF3C00").opacity(0.1))
                    )
                
                // Quick actions
                HStack(spacing: 12) {
                    QuickActionButton(
                        title: "Add Goal",
                        icon: "plus.circle.fill",
                        color: Color(hex: "#FF3C00")
                    ) {
                        showingAddGoal = true
                    }
                    
                    QuickActionButton(
                        title: "Add Habit",
                        icon: "plus.circle.fill",
                        color: .blue
                    ) {
                        showingAddHabit = true
                    }
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    let progress: Double?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.primary)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            if let progress = progress {
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: color))
                    .scaleEffect(y: 0.8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct VisionBoardItemCard: View {
    let item: VisionBoardItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)
                .foregroundColor(Color.primary)
            
            if !item.description.isEmpty {
                Text(item.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#FF3C00").opacity(0.1))
        .cornerRadius(8)
    }
}

struct ActivityRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let time: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.primary)
                    .lineLimit(1)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(color)
            .cornerRadius(20)
        }
    }
}

struct AddGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory: GoalCategory = .personal
    
    let onAdd: (Goal) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Goal Details") {
                    TextField("Goal title", text: $title)
                    TextField("Description (optional)", text: $description)
                        .lineLimit(3)
                }
                
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(GoalCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
            }
            .navigationTitle("Add Goal")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Add") {
                    let goal = Goal(
                        title: title,
                        description: description,
                        category: selectedCategory
                    )
                    onAdd(goal)
                    dismiss()
                }
                .disabled(title.isEmpty)
            )
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(GoalViewModel())
        .environmentObject(HabitViewModel())
}