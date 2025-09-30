//
//  VisionBoardView.swift
//  ElevateAno
//
//  Created by Вячеслав on 9/30/25.
//

import SwiftUI

struct VisionBoardView: View {
    @EnvironmentObject var goalViewModel: GoalViewModel
    @State private var currentVisionBoard: DailyVisionBoard
    @State private var showingAddItem = false
    
    init() {
        _currentVisionBoard = State(initialValue: DailyVisionBoard())
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Vision Board Canvas
                    visionBoardCanvas
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
            .background(Color.white.ignoresSafeArea())
            .navigationTitle("Vision Board")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: 
                Button(action: {
                    showingAddItem = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color(hex: "#FF3C00"))
                }
            )
        }
        .onAppear {
            currentVisionBoard = goalViewModel.getTodaysVisionBoard()
        }
        .sheet(isPresented: $showingAddItem) {
            AddVisionBoardItemView { item in
                goalViewModel.addVisionBoardItem(item, to: currentVisionBoard)
                currentVisionBoard = goalViewModel.getTodaysVisionBoard()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Vision")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.primary)
                    
                    Text(currentVisionBoard.date.formatted(date: .complete, time: .omitted))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
    }
    
    private var visionBoardCanvas: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Vision Canvas")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            ZStack {
                // Canvas background
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.05))
                    .frame(height: 400)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 2, dash: [10]))
                    )
                
                if currentVisionBoard.items.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "target")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("Create Your Vision")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(Color.primary)
                        
                        Text("Tap + to add your goals and intentions for today")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Add First Item") {
                            showingAddItem = true
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color(hex: "#FF3C00"))
                        .cornerRadius(20)
                    }
                } else {
                    // Vision board items
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(currentVisionBoard.items) { item in
                            VisionBoardItemView(item: item)
                        }
                    }
                }
            }
        }
    }
}

struct VisionBoardItemView: View {
    let item: VisionBoardItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Color.primary)
                .lineLimit(2)
            
            if !item.description.isEmpty {
                Text(item.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct AddVisionBoardItemView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    
    let onAdd: (VisionBoardItem) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Vision Item Details") {
                    TextField("Title", text: $title)
                    TextField("Description (optional)", text: $description)
                        .lineLimit(3)
                }
            }
            .navigationTitle("Add Vision Item")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Add") {
                    let item = VisionBoardItem(
                        title: title,
                        description: description
                    )
                    onAdd(item)
                    dismiss()
                }
                .disabled(title.isEmpty)
            )
        }
    }
}

#Preview {
    VisionBoardView()
        .environmentObject(GoalViewModel())
}