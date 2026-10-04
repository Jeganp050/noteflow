//
//  Note.swift
//  NoteFlow
//
//  Created for NoteFlow iOS App.
//

import Foundation

/// Represents an individual note with text content, timestamps, category, and accent color index.
struct Note: Identifiable, Codable, Equatable {
    let id: UUID
    var text: String
    let createdAt: Date
    var updatedAt: Date
    var category: String
    var colorIndex: Int
    
    init(
        id: UUID = UUID(),
        text: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        category: String = AppConstants.defaultCategory,
        colorIndex: Int = 0
    ) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.category = category
        self.colorIndex = colorIndex
    }
}
