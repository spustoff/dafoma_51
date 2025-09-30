//
//  HabitTrackerView.swift
//  ElevateAno
//
//  Created by Вячеслав on 9/30/25.
//

import SwiftUI

struct HabitTrackerView: View {
    @EnvironmentObject var habitViewModel: HabitViewModel
    @State private var showingAddHabit = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Stats
                    headerStatsSection
                    
                    // Today's Habits
                    todaysHabitsSection
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
            .background(Color.white.ignoresSafeArea())
            .navigationTitle("Habit Tracker")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: 
                Button(action: {
                    showingAddHabit = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color(hex: "#FF3C00"))
                }
            )
        }
        .sheet(isPresented: $showingAddHabit) {
            AddHabitView { habit in
                habitViewModel.addHabit(habit)
            }
        }
    }
    
    private var headerStatsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Today's Progress")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Completed",
                    value: "\(habitViewModel.getCompletedTodayCount())",
                    subtitle: "of \(habitViewModel.getActiveHabitsCount()) habits",
                    icon: "checkmark.circle.fill",
                    color: .green,
                    progress: habitViewModel.getTodayCompletionRate()
                )
                
                StatCard(
                    title: "Current Streak",
                    value: "\(habitViewModel.getCurrentStreak())",
                    subtitle: "days",
                    icon: "flame.fill",
                    color: .orange,
                    progress: nil
                )
            }
        }
    }
    
    private var todaysHabitsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Today's Habits")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                
                Text("\(habitViewModel.getCompletedTodayCount())/\(habitViewModel.getActiveHabitsCount())")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            let activeHabits = habitViewModel.habits.filter { $0.isActive }
            
            if activeHabits.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("No Active Habits")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(Color.primary)
                    
                    Text("Start building positive habits to track your progress")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Add Your First Habit") {
                        showingAddHabit = true
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color(hex: "#FF3C00"))
                    .cornerRadius(20)
                }
                .padding(.vertical, 30)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(activeHabits) { habit in
                        HabitRowView(habit: habit)
                            .environmentObject(habitViewModel)
                    }
                }
            }
        }
    }
}

struct HabitRowView: View {
    let habit: Habit
    @EnvironmentObject var habitViewModel: HabitViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Category icon
            Image(systemName: habit.category.icon)
                .font(.title2)
                .foregroundColor(Color(habit.category.color))
                .frame(width: 30)
            
            // Habit info
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.primary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(habit.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if habit.streak > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "flame.fill")
                                .font(.caption2)
                                .foregroundColor(.orange)
                            Text("\(habit.streak)")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Progress indicator
            VStack(alignment: .trailing, spacing: 4) {
                if habit.isCompletedToday() {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                } else {
                    Button(action: {
                        habitViewModel.completeHabit(habit)
                    }) {
                        Image(systemName: "circle")
                            .font(.title2)
                            .foregroundColor(Color(hex: "#FF3C00"))
                    }
                }
                
                Text("\(habit.targetValue) \(habit.unit)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var selectedCategory: HabitCategory = .health
    
    let onAdd: (Habit) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Habit Details") {
                    TextField("Habit name", text: $name)
                }
                
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(HabitCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
            }
            .navigationTitle("Add Habit")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Add") {
                    let habit = Habit(
                        name: name,
                        description: "",
                        category: selectedCategory,
                        frequency: .daily
                    )
                    onAdd(habit)
                    dismiss()
                }
                .disabled(name.isEmpty)
            )
        }
    }
}

#Preview {
    HabitTrackerView()
        .environmentObject(HabitViewModel())
}