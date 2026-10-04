//
//  Constants.swift
//  NoteFlow
//
//  Created for NoteFlow iOS App.
//

import SwiftUI

/// App-wide constants including limits, default categories, storage keys, and styling palettes.
enum AppConstants {
    // MARK: - Limits & Validation
    static let maxCharacterLimit: Int = 2000
    
    // MARK: - Categories
    static let allCategory: String = "All"
    static let defaultCategory: String = "Personal"
    static let categories: [String] = ["Study", "Work", "Ideas", "Personal"]
    static var filterCategories: [String] {
        [allCategory] + categories
    }
    
    // MARK: - UserDefaults Storage Keys
    static let notesStorageKey: String = "com.noteflow.savedNotes"
    static let hasLaunchedBeforeKey: String = "com.noteflow.hasLaunchedBefore"
    
    // MARK: - Visual Accent Color Palette
    /// Controlled harmonious accent colors that adapt cleanly in light and dark mode.
    static let noteAccentColors: [Color] = [
        Color.blue,
        Color.indigo,
        Color.purple,
        Color.orange,
        Color.teal,
        Color.pink
    ]
    
    /// Retrieve a safe accent color by index.
    static func accentColor(for index: Int) -> Color {
        let safeIndex = abs(index) % noteAccentColors.count
        return noteAccentColors[safeIndex]
    }
}
