//
//  EmptyStateView.swift
//  NoteFlow
//
//  Created for NoteFlow iOS App.
//

import SwiftUI

/// Elegant empty state view covering both empty store and unmatched search queries.
struct EmptyStateView: View {
    enum StateType {
        case noNotes
        case noSearchResults
    }
    
    let type: StateType
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 88, height: 88)
                
                Image(systemName: iconName)
                    .font(.system(size: 38, weight: .light))
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 4)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 280)
            }
            
            Button(action: action) {
                HStack(spacing: 8) {
                    Image(systemName: buttonIcon)
                        .font(.subheadline.bold())
                    Text(buttonTitle)
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .padding(.horizontal, 22)
                .padding(.vertical, 12)
                .background(Color.primary)
                .foregroundColor(Color(.systemBackground))
                .clipShape(Capsule())
                .shadow(color: Color.primary.opacity(0.12), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
            .accessibilityLabel(buttonTitle)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
    
    private var iconName: String {
        switch type {
        case .noNotes:
            return "square.and.pencil"
        case .noSearchResults:
            return "text.magnifyingglass"
        }
    }
    
    private var title: String {
        switch type {
        case .noNotes:
            return "No notes yet"
        case .noSearchResults:
            return "Nothing found"
        }
    }
    
    private var subtitle: String {
        switch type {
        case .noNotes:
            return "Capture your first thought and keep it organized here."
        case .noSearchResults:
            return "No notes matched your search query. Try another keyword or reset the filter."
        }
    }
    
    private var buttonTitle: String {
        switch type {
        case .noNotes:
            return "Create Note"
        case .noSearchResults:
            return "Clear Search"
        }
    }
    
    private var buttonIcon: String {
        switch type {
        case .noNotes:
            return "plus"
        case .noSearchResults:
            return "xmark"
        }
    }
}
