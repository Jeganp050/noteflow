//
//  DateHelper.swift
//  NoteFlow
//
//  Created for NoteFlow iOS App.
//

import Foundation

/// Helper for standard and human-readable date formatting throughout NoteFlow.
enum DateHelper {
    // Reusable cached date formatters for optimal performance
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    private static let monthDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    private static let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    /// Formats recent dates into intuitive labels (e.g. "Today", "Yesterday", "Oct 1")
    static func formatRelativeDate(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today, " + timeFormatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return monthDayFormatter.string(from: date)
        }
    }
    
    /// Full date and time representation used in the Detail and Metadata views
    static func formatFullDateTime(_ date: Date) -> String {
        return fullDateFormatter.string(from: date)
    }
}
