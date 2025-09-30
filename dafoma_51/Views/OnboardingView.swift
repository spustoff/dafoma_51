//
//  OnboardingView.swift
//  ElevateAno
//
//  Created by Вячеслав on 9/30/25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    
    private let pages = [
        OnboardingPage(
            title: "Welcome to ElevateAno",
            subtitle: "Your Personal Growth Companion",
            description: "Transform your daily life with intentional goal setting, habit tracking, and inspiring community stories.",
            imageName: "figure.mind.and.body",
            color: Color(hex: "#FF3C00")
        ),
        OnboardingPage(
            title: "Visualize Your Dreams",
            subtitle: "Daily Vision Boards",
            description: "Create interactive vision boards to set daily intentions and track your progress with reflective journaling.",
            imageName: "target",
            color: Color(hex: "#FF3C00")
        ),
        OnboardingPage(
            title: "Build Lasting Habits",
            subtitle: "Smart Habit Tracking",
            description: "Develop positive habits with automated reminders, progress charts, and motivational insights.",
            imageName: "checkmark.circle.fill",
            color: Color(hex: "#FF3C00")
        )
    ]
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress indicator
                HStack {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index <= currentPage ? Color(hex: "#FF3C00") : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal)
                
                // Content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Buttons
                VStack(spacing: 16) {
                    if currentPage == pages.count - 1 {
                        Button("Get Started") {
                            completeOnboarding()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(hex: "#FF3C00"))
                        .cornerRadius(12)
                        
                        Button("Skip") {
                            completeOnboarding()
                        }
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#FF3C00"))
                    } else {
                        Button("Continue") {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(hex: "#FF3C00"))
                        .cornerRadius(12)
                        
                        Button("Skip") {
                            completeOnboarding()
                        }
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func completeOnboarding() {
        hasCompletedOnboarding = true
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            Image(systemName: page.imageName)
                .font(.system(size: 80, weight: .light))
                .foregroundColor(page.color)
                .padding(.bottom, 20)
            
            // Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.primary)
                
                Text(page.subtitle)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(page.color)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let imageName: String
    let color: Color
}

#Preview {
    OnboardingView()
}