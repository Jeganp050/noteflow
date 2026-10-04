//
//  FloatingAddButton.swift
//  NoteFlow
//
//  Created for NoteFlow iOS App.
//

import SwiftUI

/// Distinctive circular floating action button with accessible touch target and spring animation.
struct FloatingAddButton: View {
    let action: () -> Void
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.primary)
                    .frame(width: 58, height: 58)
                    .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 5)
                
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color(.systemBackground))
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.92 : 1.0)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isPressed)
        .accessibilityLabel("Add new note")
        .accessibilityHint("Double tap to open the new note editor")
    }
}
