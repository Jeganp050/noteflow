//
//  NoteStore.swift
//  NoteFlow
//
//  Created for NoteFlow iOS App.
//

import SwiftUI
import Combine

/// Single source of truth managing Note persistence, lifecycle, searching, and filtering.
final class NoteStore: ObservableObject {
    @Published var notes: [Note] = []
    
    private let userDefaults: UserDefaults
    private let storageKey: String
    private let firstLaunchKey: String
    
    init(
        userDefaults: UserDefaults = .standard,
        storageKey: String = AppConstants.notesStorageKey,
        firstLaunchKey: String = AppConstants.hasLaunchedBeforeKey
    ) {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
        self.firstLaunchKey = firstLaunchKey
        
        loadNotes()
    }
    
    // MARK: - Persistence
    
    /// Loads notes from UserDefaults or populates sample notes on first launch.
    func loadNotes() {
        let hasLaunchedBefore = userDefaults.bool(forKey: firstLaunchKey)
        
        guard let data = userDefaults.data(forKey: storageKey) else {
            if !hasLaunchedBefore {
                loadSampleData()
                userDefaults.set(true, forKey: firstLaunchKey)
            } else {
                self.notes = []
            }
            return
        }
        
        do {
            let decodedNotes = try JSONDecoder().decode([Note].self, from: data)
            self.notes = decodedNotes.sorted { $0.updatedAt > $1.updatedAt }
        } catch {
            print("NoteStore: Error decoding notes from UserDefaults: \(error.localizedDescription)")
            if !hasLaunchedBefore {
                loadSampleData()
                userDefaults.set(true, forKey: firstLaunchKey)
            } else {
                self.notes = []
            }
        }
    }
    
    /// Persists current notes array to UserDefaults.
    func saveNotes() {
        do {
            let data = try JSONEncoder().encode(notes)
            userDefaults.set(data, forKey: storageKey)
        } catch {
            print("NoteStore: Error encoding notes to UserDefaults: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Note Operations
    
    /// Adds a new note to the top of the collection and saves immediately.
    func addNote(text: String, category: String, colorIndex: Int = 0) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let newNote = Note(
            text: trimmed,
            createdAt: Date(),
            updatedAt: Date(),
            category: category,
            colorIndex: colorIndex
        )
        
        notes.insert(newNote, at: 0)
        saveNotes()
    }
    
    /// Updates an existing note while preserving its original id and createdAt timestamp.
    func updateNote(_ note: Note, newText: String, newCategory: String, newColorIndex: Int? = nil) {
        let trimmed = newText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].text = trimmed
            notes[index].category = newCategory
            notes[index].updatedAt = Date()
            if let newColor = newColorIndex {
                notes[index].colorIndex = newColor
            }
            // Re-sort so the most recently updated note is at top
            notes.sort { $0.updatedAt > $1.updatedAt }
            saveNotes()
        }
    }
    
    /// Deletes a specific note by identity.
    func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        saveNotes()
    }
    
    /// Deletes notes at IndexSet (useful for List swipe actions).
    func deleteNotes(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
        saveNotes()
    }
    
    /// Deletes note by UUID.
    func deleteNote(id: UUID) {
        notes.removeAll { $0.id == id }
        saveNotes()
    }
    
    // MARK: - Query & Filter Helpers
    
    /// Filters notes by search query and category.
    func filteredNotes(searchQuery: String, selectedCategory: String) -> [Note] {
        notes.filter { note in
            let matchesCategory = (selectedCategory == AppConstants.allCategory) || (note.category.caseInsensitiveCompare(selectedCategory) == .orderedSame)
            
            let matchesSearch: Bool
            if searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                matchesSearch = true
            } else {
                matchesSearch = note.text.localizedCaseInsensitiveContains(searchQuery)
            }
            
            return matchesCategory && matchesSearch
        }
    }
    
    // MARK: - Sample Data
    
    /// Loads rich, distinctive sample notes for first-run experience.
    func loadSampleData() {
        let calendar = Calendar.current
        let now = Date()
        
        let sample1 = Note(
            text: "Computer Networks Review:\n1. OSI vs TCP/IP layered architecture\n2. Three-way handshake: SYN -> SYN-ACK -> ACK\n3. DNS resolution stages: Root, TLD, Authoritative servers\n4. TLS 1.3 handshake optimization and zero-RTT resumption.",
            createdAt: calendar.date(byAdding: .day, value: -3, to: now) ?? now,
            updatedAt: calendar.date(byAdding: .hour, value: -1, to: now) ?? now,
            category: "Study",
            colorIndex: 0
        )
        
        let sample2 = Note(
            text: "SwiftUI Project Architecture Checklist:\n• Use MVVM with ObservableObject as single source of truth\n• Adopt NavigationStack for fluid transitions\n• Ensure full Dynamic Type & accessibility labeling\n• Polish responsive layouts across compact and regular size classes.",
            createdAt: calendar.date(byAdding: .day, value: -2, to: now) ?? now,
            updatedAt: calendar.date(byAdding: .hour, value: -4, to: now) ?? now,
            category: "Work",
            colorIndex: 1
        )
        
        let sample3 = Note(
            text: "Semester Study Plan & Milestones:\n- Week 1-3: Data Structures & Dynamic Programming patterns\n- Week 4-6: System Design, caching strategies, rate limiters\n- Week 7: Distributed Systems & Raft Consensus deep dive.",
            createdAt: calendar.date(byAdding: .day, value: -5, to: now) ?? now,
            updatedAt: calendar.date(byAdding: .day, value: -1, to: now) ?? now,
            category: "Study",
            colorIndex: 2
        )
        
        let sample4 = Note(
            text: "App Ideas for 2026:\n• Minimalist audio journaling with on-device speech transcription\n• Ambient soundscape mixer for deep focus sessions\n• Spatial flashcard study assistant with spaced repetition.",
            createdAt: calendar.date(byAdding: .day, value: -6, to: now) ?? now,
            updatedAt: calendar.date(byAdding: .day, value: -2, to: now) ?? now,
            category: "Ideas",
            colorIndex: 3
        )
        
        let sample5 = Note(
            text: "Weekend Routine & Errands:\n• Morning 5km run at the park\n• Clean home desk and organize cables\n• Pick up groceries and fresh coffee beans\n• Read 2 chapters of Designing Data-Intensive Applications.",
            createdAt: calendar.date(byAdding: .day, value: -7, to: now) ?? now,
            updatedAt: calendar.date(byAdding: .day, value: -4, to: now) ?? now,
            category: "Personal",
            colorIndex: 4
        )
        
        self.notes = [sample1, sample2, sample3, sample4, sample5]
        saveNotes()
    }
    
    /// Resets sample data explicitly (convenient for testing or portfolio demonstration).
    func resetSampleData() {
        loadSampleData()
    }
}
