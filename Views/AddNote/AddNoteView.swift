//
//  AddNoteView.swift
//  NoteFlow
//
//  Created for NoteFlow iOS App.
//

import SwiftUI

/// Dedicated screen for composing new notes or editing existing notes.
struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: NoteStore
    
    /// If non-nil, the view acts in edit mode for this note.
    var noteToEdit: Note?
    
    @State private var text: String = ""
    @State private var selectedCategory: String = AppConstants.defaultCategory
    @State private var selectedColorIndex: Int = 0
    @State private var showValidationError: Bool = false
    @State private var isSaving: Bool = false
    
    @FocusState private var isEditorFocused: Bool
    
    private var isEditing: Bool {
        noteToEdit != nil
    }
    
    private var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private var isValid: Bool {
        !trimmedText.isEmpty && text.count <= AppConstants.maxCharacterLimit
    }
    
    private var remainingCharacters: Int {
        AppConstants.maxCharacterLimit - text.count
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Category Selection Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Category")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(AppConstants.categories, id: \.self) { category in
                                    CategoryChip(
                                        title: category,
                                        isSelected: selectedCategory == category,
                                        count: nil,
                                        action: {
                                            selectedCategory = category
                                        }
                                    )
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    
                    // Accent Color Palette Selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Accent Color")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 14) {
                            ForEach(0..<AppConstants.noteAccentColors.count, id: \.self) { index in
                                Button(action: {
                                    selectedColorIndex = index
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(AppConstants.noteAccentColors[index])
                                            .frame(width: 28, height: 28)
                                        
                                        if selectedColorIndex == index {
                                            Circle()
                                                .stroke(Color.primary, lineWidth: 2)
                                                .frame(width: 36, height: 36)
                                            
                                            Image(systemName: "checkmark")
                                                .font(.caption2.bold())
                                                .foregroundColor(.white)
                                        }
                                    }
                                    .frame(width: 38, height: 38)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Accent color \(index + 1)")
                            }
                        }
                    }
                    
                    // Main Note Text Editor
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Note Content")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            // Character Counter
                            Text("\(text.count) / \(AppConstants.maxCharacterLimit)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(text.count > AppConstants.maxCharacterLimit ? .red : .secondary)
                        }
                        
                        ZStack(alignment: .topLeading) {
                            // Text Editor Card Background
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color(.secondarySystemBackground))
                            
                            // Custom Placeholder
                            if text.isEmpty {
                                Text("What's on your mind? Capture your thoughts, notes, tasks, or study outlines...")
                                    .font(.body)
                                    .foregroundColor(.secondary.opacity(0.7))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .allowsHitTesting(false)
                            }
                            
                            // Native TextEditor
                            TextEditor(text: $text)
                                .font(.body)
                                .padding(10)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .focused($isEditorFocused)
                                .frame(minHeight: 220)
                                .onChange(of: text) { _, newValue in
                                    if newValue.count > AppConstants.maxCharacterLimit {
                                        text = String(newValue.prefix(AppConstants.maxCharacterLimit))
                                    }
                                    if !trimmedText.isEmpty {
                                        showValidationError = false
                                    }
                                }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(
                                    showValidationError ? Color.red : (isEditorFocused ? AppConstants.accentColor(for: selectedColorIndex).opacity(0.6) : Color.clear),
                                    lineWidth: 1.5
                                )
                        )
                    }
                    
                    // Validation Message
                    if showValidationError {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.footnote)
                            Text("Please enter some text before saving.")
                                .font(.footnote)
                        }
                        .foregroundColor(.red)
                        .transition(.opacity)
                    }
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationTitle(isEditing ? "Edit Note" : "New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: handleSave) {
                        if isSaving {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Save")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(!isValid || isSaving)
                }
            }
            .onAppear {
                if let note = noteToEdit {
                    self.text = note.text
                    self.selectedCategory = note.category
                    self.selectedColorIndex = note.colorIndex
                } else {
                    // Set default autofocus for new note
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isEditorFocused = true
                    }
                }
            }
        }
    }
    
    private func handleSave() {
        guard isValid else {
            showValidationError = true
            return
        }
        
        isSaving = true
        
        withAnimation(.easeInOut(duration: 0.2)) {
            if let existingNote = noteToEdit {
                store.updateNote(
                    existingNote,
                    newText: trimmedText,
                    newCategory: selectedCategory,
                    newColorIndex: selectedColorIndex
                )
            } else {
                store.addNote(
                    text: trimmedText,
                    category: selectedCategory,
                    colorIndex: selectedColorIndex
                )
            }
        }
        
        dismiss()
    }
}
