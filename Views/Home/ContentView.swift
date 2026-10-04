//
//  ContentView.swift
//  NoteFlow
//
//  Created for NoteFlow iOS App.
//

import SwiftUI

/// Dashboard home screen for NoteFlow displaying search, category filters, and editorial note cards.
struct ContentView: View {
    @StateObject private var store = NoteStore()
    
    @State private var searchQuery: String = ""
    @State private var selectedCategory: String = AppConstants.allCategory
    @State private var isShowingAddSheet: Bool = false
    @State private var noteToDelete: Note?
    @State private var isShowingDeleteConfirmation: Bool = false
    
    private var displayedNotes: [Note] {
        store.filteredNotes(searchQuery: searchQuery, selectedCategory: selectedCategory)
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        // Header Section
                        headerSection
                        
                        // Search Bar
                        SearchBar(text: $searchQuery)
                            .padding(.top, 2)
                        
                        // Category Filter Chips
                        categoryFilterSection
                        
                        // Main Content: Notes List or Empty States
                        if store.notes.isEmpty {
                            EmptyStateView(type: .noNotes) {
                                isShowingAddSheet = true
                            }
                            .padding(.top, 30)
                        } else if displayedNotes.isEmpty {
                            EmptyStateView(type: .noSearchResults) {
                                searchQuery = ""
                                selectedCategory = AppConstants.allCategory
                            }
                            .padding(.top, 30)
                        } else {
                            notesGridSection
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 90) // Room for floating action button
                }
                .scrollDismissesKeyboard(.interactively)
                
                // Floating Action Button
                FloatingAddButton {
                    isShowingAddSheet = true
                }
                .padding(.trailing, 24)
                .padding(.bottom, 24)
            }
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            store.resetSampleData()
                        }) {
                            Label("Load Sample Notes", systemImage: "arrow.counterclockwise")
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.primary)
                    }
                    .accessibilityLabel("Settings and options")
                }
            }
            .sheet(isPresented: $isShowingAddSheet) {
                AddNoteView(store: store)
            }
            .alert("Delete Note?", isPresented: $isShowingDeleteConfirmation, presenting: noteToDelete) { note in
                Button("Cancel", role: .cancel) {
                    noteToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    store.deleteNote(note)
                    noteToDelete = nil
                }
            } message: { _ in
                Text("This note will be permanently removed.")
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text("Capture ideas.")
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(store.notes.count) \(store.notes.count == 1 ? "note" : "notes")")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(Capsule())
            }
            
            Text("Keep them structured and always within reach.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AppConstants.filterCategories, id: \.self) { category in
                    let count: Int = {
                        if category == AppConstants.allCategory {
                            return store.notes.count
                        } else {
                            return store.notes.filter { $0.category.caseInsensitiveCompare(category) == .orderedSame }.count
                        }
                    }()
                    
                    CategoryChip(
                        title: category,
                        isSelected: selectedCategory == category,
                        count: count,
                        action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                selectedCategory = category
                            }
                        }
                    )
                }
            }
            .padding(.vertical, 2)
        }
    }
    
    private var notesGridSection: some View {
        LazyVStack(spacing: 14) {
            ForEach(displayedNotes) { note in
                NavigationLink(destination: NoteDetailView(store: store, noteId: note.id)) {
                    NoteCard(
                        note: note,
                        onDelete: {
                            noteToDelete = note
                            isShowingDeleteConfirmation = true
                        },
                        onShare: {
                            // Can be triggered from context menu
                        }
                    )
                }
                .buttonStyle(PlainNavigationLinkButtonStyle())
            }
        }
        .animation(.easeInOut(duration: 0.25), value: displayedNotes)
    }
}

/// Custom button style ensuring smooth visual feedback without standard blue tint on NavigationLink
private struct PlainNavigationLinkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.88 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
