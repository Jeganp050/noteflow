//
//  CategoryChip.swift
//  NoteFlow
//
//  Created for NoteFlow iOS App.
//

import SwiftUI

/// A modern, tactile filter chip for categorizing notes.
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let count: Int?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                
                if let count = count {
                    Text("\(count)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isSelected ? Color.white.opacity(0.25) : Color.secondary.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.primary : Color(.secondarySystemBackground))
            )
            .foregroundColor(isSelected ? Color(.systemBackground) : Color.primary)
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) category filter")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .accessibilityHint("Double tap to filter notes by \(title)")
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
