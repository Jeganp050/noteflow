//
//  NoteCard.swift
//  NoteFlow
//
//  Created for NoteFlow iOS App.
//

import SwiftUI

/// Editorial-inspired note preview card showcasing category, formatted excerpt, date, and character count.
struct NoteCard: View {
    let note: Note
    var onDelete: (() -> Void)?
    var onShare: (() -> Void)?
    
    @State private var isPressed: Bool = false
    
    private var accentColor: Color {
        AppConstants.accentColor(for: note.colorIndex)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Category Pill & Relative Date
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(accentColor)
                        .frame(width: 8, height: 8)
                    
                    Text(note.category.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .tracking(1.0)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.tertiarySystemBackground))
                .clipShape(Capsule())
                
                Spacer()
                
                Text(DateHelper.formatRelativeDate(note.updatedAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Note Excerpt Preview
            Text(note.text)
                .font(.body)
                .fontWeight(.regular)
                .foregroundColor(.primary)
                .lineSpacing(3)
                .lineLimit(4)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Footer: Character Count & Decorative Accent Line
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "character")
                        .font(.caption2)
                    Text("\(note.text.count) chars")
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
                
                Spacer()
                
                // Subtle colored indicator
                RoundedRectangle(cornerRadius: 2)
                    .fill(accentColor.opacity(0.85))
                    .frame(width: 24, height: 3)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(accentColor.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .contextMenu {
            if let onShare = onShare {
                Button(action: onShare) {
                    Label("Share Note", systemImage: "square.and.arrow.up")
                }
            }
            
            Button(action: {
                UIPasteboard.general.string = note.text
            }) {
                Label("Copy Text", systemImage: "doc.on.doc")
            }
            
            if let onDelete = onDelete {
                Divider()
                Button(role: .destructive, action: onDelete) {
                    Label("Delete Note", systemImage: "trash")
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(note.category) note: \(note.text)")
        .accessibilityHint("Double tap to open note details. Long press for actions.")
    }
}
