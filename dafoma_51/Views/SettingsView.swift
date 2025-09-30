//
//  SettingsView.swift
//  ElevateAno
//
//  Created by Вячеслав on 9/30/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var goalViewModel: GoalViewModel
    @EnvironmentObject var habitViewModel: HabitViewModel
    @EnvironmentObject var tipViewModel: TipViewModel
    @EnvironmentObject var communityViewModel: CommunityViewModel
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @State private var userPreferences = UserPreferences()
    @State private var showingResetAlert = false
    @State private var showingDataExport = false
    @State private var showingAbout = false
    @State private var exportData: Data?
    
    var body: some View {
        NavigationView {
            List {
                // Profile Section
                profileSection
                
                // App Preferences
                preferencesSection
                
                // Data & Privacy
                dataSection
                
                // Support & Feedback
//                supportSection
                
                // About
                aboutSection
                
                // Reset Options
                resetSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadUserPreferences()
            }
        }
        .alert("Reset App Data", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetAppData()
            }
        } message: {
            Text("This will delete all your goals, habits, and progress. This action cannot be undone.")
        }
        .sheet(isPresented: $showingDataExport) {
            DataExportView(exportData: exportData)
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
    
    private var profileSection: some View {
        Section {
            HStack(spacing: 16) {
                // Profile image placeholder
                Circle()
                    .fill(Color(hex: "#FF3C00").opacity(0.1))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.title)
                            .foregroundColor(Color(hex: "#FF3C00"))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("ElevateAno User")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.primary)
                    
                    Text("Personal Growth Journey")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Quick stats
                    HStack(spacing: 16) {
                        StatBadge(
                            value: "\(goalViewModel.getCompletedGoalsCount())",
                            label: "Goals",
                            color: .green
                        )
                        
                        StatBadge(
                            value: "\(habitViewModel.getCurrentStreak())",
                            label: "Streak",
                            color: .orange
                        )
                        
                        StatBadge(
                            value: "\(tipViewModel.getReadTipsCount())",
                            label: "Tips Read",
                            color: .blue
                        )
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
    
    private var preferencesSection: some View {
        Section("Preferences") {
            // Daily reminder time
            if userPreferences.notificationsEnabled {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    Text("Daily Reminder")
                    
                    Spacer()
                    
                    DatePicker("", selection: $userPreferences.dailyReminderTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .onChange(of: userPreferences.dailyReminderTime) { _ in
                            saveUserPreferences()
                        }
                }
            }
            
            // Week starts on Monday
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.purple)
                    .frame(width: 24)
                
                Toggle("Week Starts on Monday", isOn: $userPreferences.weekStartsOnMonday)
                    .onChange(of: userPreferences.weekStartsOnMonday) { _ in
                        saveUserPreferences()
                    }
            }
            
            // Show motivational quotes
            HStack {
                Image(systemName: "quote.bubble.fill")
                    .foregroundColor(.green)
                    .frame(width: 24)
                
                Toggle("Motivational Quotes", isOn: $userPreferences.showMotivationalQuotes)
                    .onChange(of: userPreferences.showMotivationalQuotes) { _ in
                        saveUserPreferences()
                    }
            }
        }
    }
    
    private var dataSection: some View {
        Section("Data & Privacy") {
            
            // Storage info
            HStack {
                Image(systemName: "internaldrive")
                    .foregroundColor(.gray)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Storage Used")
                        .foregroundColor(Color.primary)
                    
                    Text("Local storage only - your data stays on your device")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Privacy info
            HStack {
                Image(systemName: "lock.shield")
                    .foregroundColor(.green)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Privacy")
                        .foregroundColor(Color.primary)
                    
                    Text("No data is shared with third parties")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
    }
    
    private var supportSection: some View {
        Section("Support & Feedback") {
            // Help & FAQ
            Button(action: {
                // Open help
            }) {
                HStack {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    Text("Help & FAQ")
                        .foregroundColor(Color.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Contact support
            Button(action: {
                // Open email
            }) {
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.green)
                        .frame(width: 24)
                    
                    Text("Contact Support")
                        .foregroundColor(Color.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Rate app
            Button(action: {
                // Open App Store rating
            }) {
                HStack {
                    Image(systemName: "star")
                        .foregroundColor(.yellow)
                        .frame(width: 24)
                    
                    Text("Rate ElevateAno")
                        .foregroundColor(Color.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Share app
            Button(action: {
                // Share app
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.purple)
                        .frame(width: 24)
                    
                    Text("Share ElevateAno")
                        .foregroundColor(Color.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var aboutSection: some View {
        Section("About") {
            Button(action: {
                showingAbout = true
            }) {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    Text("About ElevateAno")
                        .foregroundColor(Color.primary)
                    
                    Spacer()
                    
                    Text("v1.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private var resetSection: some View {
        Section("Reset") {
            // Restart onboarding
            Button(action: {
                hasCompletedOnboarding = false
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.orange)
                        .frame(width: 24)
                    
                    Text("Restart Onboarding")
                        .foregroundColor(Color.primary)
                    
                    Spacer()
                }
            }
            
            // Reset all data
            Button(action: {
                showingResetAlert = true
            }) {
                HStack {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .frame(width: 24)
                    
                    Text("Reset All Data")
                        .foregroundColor(.red)
                    
                    Spacer()
                }
            }
        }
    }
    
    private func loadUserPreferences() {
        userPreferences = DataStorageService.shared.loadUserPreferences()
    }
    
    private func saveUserPreferences() {
        DataStorageService.shared.saveUserPreferences(userPreferences)
    }
    
    private func exportUserData() {
        exportData = DataStorageService.shared.exportUserData()
        showingDataExport = true
    }
    
    private func resetAppData() {
        DataStorageService.shared.resetToDefaults()
        
        // Reload all view models
        goalViewModel.loadGoals()
        habitViewModel.loadHabits()
        tipViewModel.loadTips()
        communityViewModel.loadStories()
        
        // Reset onboarding
        hasCompletedOnboarding = false
    }
}

struct StatBadge: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct DataExportView: View {
    let exportData: Data?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "square.and.arrow.up.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "#FF3C00"))
                
                VStack(spacing: 12) {
                    Text("Export Your Data")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.primary)
                    
                    Text("Your personal data has been prepared for export. You can save it to Files or share it with another app.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                VStack(spacing: 16) {
                    if let data = exportData {
                        Text("Export size: \(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            // Share functionality for iOS 15.6
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Data")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(hex: "#FF3C00"))
                            .cornerRadius(12)
                        }
                    } else {
                        Text("No data available for export")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: 
                Button("Done") {
                    dismiss()
                }
            )
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // App icon and name
                    VStack(spacing: 16) {
                        Image(systemName: "target")
                            .font(.system(size: 80))
                            .foregroundColor(Color(hex: "#FF3C00"))
                        
                        Text("ElevateAno")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color.primary)
                        
                        Text("Your Personal Growth Companion")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text("Version 1.0")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About ElevateAno")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("ElevateAno is designed to enhance your daily living by promoting personal growth and helping you achieve your goals. Our app provides clear, actionable content rooted in self-improvement and productivity.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Key Features")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            FeatureRow(
                                icon: "target",
                                title: "Daily Vision Board",
                                description: "Visualize and set your daily intentions with interactive tools"
                            )
                            
                            FeatureRow(
                                icon: "checkmark.circle.fill",
                                title: "Habit Tracker",
                                description: "Build positive habits with automated reminders and progress charts"
                            )
                            
                            FeatureRow(
                                icon: "lightbulb.fill",
                                title: "Personal Growth Tips",
                                description: "Access curated articles on mindfulness, productivity, and wellness"
                            )
                            
                            FeatureRow(
                                icon: "person.2.fill",
                                title: "Community Stories",
                                description: "Share and read anonymous growth stories for inspiration"
                            )
                        }
                    }
                    
                    // Privacy
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Privacy & Security")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Your privacy is our priority. All your data is stored locally on your device and is never shared with third parties. You have complete control over your personal information.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    
                    // Contact
                    VStack(spacing: 12) {
                        Text("Made with ❤️ for personal growth")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text("© 2025 ElevateAno. All rights reserved.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: 
                Button("Done") {
                    dismiss()
                }
            )
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color(hex: "#FF3C00"))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(GoalViewModel())
        .environmentObject(HabitViewModel())
        .environmentObject(TipViewModel())
        .environmentObject(CommunityViewModel())
}
