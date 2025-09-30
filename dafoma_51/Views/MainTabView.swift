//
//  MainTabView.swift
//  ElevateAno
//
//  Created by Вячеслав on 9/30/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var goalViewModel = GoalViewModel()
    @StateObject private var habitViewModel = HabitViewModel()
    @StateObject private var tipViewModel = TipViewModel()
    @StateObject private var communityViewModel = CommunityViewModel()
    
    var body: some View {
        TabView {
            HomeView()
                .environmentObject(goalViewModel)
                .environmentObject(habitViewModel)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            VisionBoardView()
                .environmentObject(goalViewModel)
                .tabItem {
                    Image(systemName: "target")
                    Text("Vision")
                }
            
            HabitTrackerView()
                .environmentObject(habitViewModel)
                .tabItem {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Habits")
                }
            
            TipsLibraryView()
                .environmentObject(tipViewModel)
                .tabItem {
                    Image(systemName: "lightbulb.fill")
                    Text("Tips")
                }
            
            CommunityView()
                .environmentObject(communityViewModel)
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Community")
                }
            
            SettingsView()
                .environmentObject(goalViewModel)
                .environmentObject(habitViewModel)
                .environmentObject(tipViewModel)
                .environmentObject(communityViewModel)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .accentColor(Color(hex: "#FF3C00"))
    }
}

// Color extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    MainTabView()
}
