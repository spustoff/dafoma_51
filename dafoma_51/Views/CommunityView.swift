//
//  CommunityView.swift
//  ElevateAno
//
//  Created by Вячеслав on 9/30/25.
//

import SwiftUI

struct CommunityView: View {
    @EnvironmentObject var communityViewModel: CommunityViewModel
    @State private var showingAddStory = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Stories list
                    storiesListSection
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
            .background(Color.white.ignoresSafeArea())
            .navigationTitle("Community")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: 
                Button(action: {
                    showingAddStory = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color(hex: "#FF3C00"))
                }
            )
        }
        .sheet(isPresented: $showingAddStory) {
            AddStoryView()
                .environmentObject(communityViewModel)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Growth Stories")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.primary)
                    
                    Text("Share your journey, inspire others")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
    }
    
    private var storiesListSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Stories")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(communityViewModel.filteredStories.count) stories")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if communityViewModel.filteredStories.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "person.2")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("No Stories Found")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(Color.primary)
                    
                    Text("Be the first to share your growth journey!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Share Your Story") {
                        showingAddStory = true
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
                LazyVStack(spacing: 16) {
                    ForEach(communityViewModel.filteredStories) { story in
                        StoryRowView(story: story)
                            .environmentObject(communityViewModel)
                    }
                }
            }
        }
    }
}

struct StoryRowView: View {
    let story: CommunityStory
    @EnvironmentObject var communityViewModel: CommunityViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: story.category.icon)
                        .font(.subheadline)
                        .foregroundColor(Color(story.category.color))
                    
                    Text(story.category.rawValue)
                        .font(.caption)
                        .foregroundColor(Color(story.category.color))
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                Text(story.inspirationLevel.emoji)
                    .font(.subheadline)
            }
            
            // Content
            Text(story.title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(Color.primary)
                .lineLimit(2)
            
            Text(story.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            // Footer
            HStack {
                Text("by \(story.displayAuthor)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("• \(story.timeAgo)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    communityViewModel.toggleLike(for: story)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: story.isLikedByUser ? "heart.fill" : "heart")
                            .font(.subheadline)
                            .foregroundColor(story.isLikedByUser ? .red : .gray)
                        
                        Text("\(story.likes)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct AddStoryView: View {
    @EnvironmentObject var communityViewModel: CommunityViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var content = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Story Details") {
                    TextField("Title", text: $title)
                    TextField("Content", text: $content)
                        .lineLimit(5)
                }
            }
            .navigationTitle("Share Your Story")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Share") {
                    let story = CommunityStory(
                        title: title,
                        content: content,
                        category: .general
                    )
                    communityViewModel.addStory(story)
                    dismiss()
                }
                .disabled(title.isEmpty || content.isEmpty)
            )
        }
    }
}

#Preview {
    CommunityView()
        .environmentObject(CommunityViewModel())
}