//
//  SearchBar.swift
//  NoteFlow
//
//  Created for NoteFlow iOS App.
//

import SwiftUI

/// Distinctive, accessible search field with clear action and keyboard dismissal.
struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search notes, ideas, keywords..."
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 16, weight: .medium))
            
            TextField(placeholder, text: $text)
                .font(.body)
                .foregroundColor(.primary)
                .focused($isFocused)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                }
                .accessibilityLabel("Clear search text")
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFocused ? Color.accentColor.opacity(0.5) : Color.clear, lineWidth: 1.5)
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
    }
}
