//
//  TipsLibraryView.swift
//  ElevateAno
//
//  Created by Вячеслав on 9/30/25.
//

import SwiftUI

struct TipsLibraryView: View {
    @EnvironmentObject var tipViewModel: TipViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Daily tip
                    dailyTipSection
                    
                    // Tips list
                    tipsListSection
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
            .background(Color.white.ignoresSafeArea())
            .navigationTitle("Tips Library")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var dailyTipSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Daily Tip")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            if let dailyTip = tipViewModel.getDailyTip() {
                DailyTipCard(tip: dailyTip)
                    .environmentObject(tipViewModel)
            } else {
                Text("All tips have been read! Great job!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
            }
        }
    }
    
    private var tipsListSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Tips")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(tipViewModel.filteredTips.count) tips")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(tipViewModel.filteredTips) { tip in
                    TipRowView(tip: tip)
                        .environmentObject(tipViewModel)
                }
            }
        }
    }
}

struct DailyTipCard: View {
    let tip: Tip
    @EnvironmentObject var tipViewModel: TipViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: tip.category.icon)
                        .font(.subheadline)
                        .foregroundColor(Color(tip.category.color))
                    
                    Text(tip.category.rawValue)
                        .font(.caption)
                        .foregroundColor(Color(tip.category.color))
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text("\(tip.estimatedReadTime) min")
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
            }
            
            Text(tip.title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(Color.primary)
                .lineLimit(2)
            
            Text(tip.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color(hex: "#FF3C00").opacity(0.1), Color(hex: "#FF3C00").opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
}

struct TipRowView: View {
    let tip: Tip
    @EnvironmentObject var tipViewModel: TipViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Category indicator
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(tip.category.color))
                .frame(width: 4, height: 60)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(tip.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color.primary)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    Text(tip.category.rawValue)
                        .font(.caption)
                        .foregroundColor(Color(tip.category.color))
                    
                    Text("\(tip.estimatedReadTime) min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Favorite button
            Button(action: {
                tipViewModel.toggleTipFavorite(tip)
            }) {
                Image(systemName: tip.isFavorite ? "heart.fill" : "heart")
                    .font(.subheadline)
                    .foregroundColor(tip.isFavorite ? .red : .gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    TipsLibraryView()
        .environmentObject(TipViewModel())
}