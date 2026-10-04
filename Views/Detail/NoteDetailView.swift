//
//  NoteDetailView.swift
//  NoteFlow
//
//  Created for NoteFlow iOS App.
//

import SwiftUI

/// Clean, editorial reader screen for inspecting full note content and managing edits or deletion.
struct NoteDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: NoteStore
    let noteId: UUID
    
    @State private var isShowingEditSheet: Bool = false
    @State private var isShowingDeleteAlert: Bool = false
    @State private var isShowingShareSheet: Bool = false
    
    /// Dynamically retrieve live note from store by id so edits reflect immediately.
    private var currentNote: Note? {
        store.notes.first { $0.id == noteId }
    }
    
    var body: some View {
        Group {
            if let note = currentNote {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Category & Metadata Header
                        HStack(alignment: .center) {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(AppConstants.accentColor(for: note.colorIndex))
                                    .frame(width: 10, height: 10)
                                
                                Text(note.category.uppercased())
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                    .tracking(1.2)
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(Capsule())
                            
                            Spacer()
                            
                            // Character & Word counter
                            Text("\(note.text.count) characters")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                            .padding(.vertical, 4)
                        
                        // Full Note Body
                        Text(note.text)
                            .font(.system(.body, design: .default))
                            .lineSpacing(6)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                        
                        Divider()
                            .padding(.top, 16)
                            .padding(.bottom, 4)
                        
                        // Timestamps Footer
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 6) {
                                Image(systemName: "calendar")
                                    .font(.caption)
                                Text("Created: \(DateHelper.formatFullDateTime(note.createdAt))")
                                    .font(.caption)
                            }
                            .foregroundColor(.secondary)
                            
                            HStack(spacing: 6) {
                                Image(systemName: "clock")
                                    .font(.caption)
                                Text("Last edited: \(DateHelper.formatFullDateTime(note.updatedAt))")
                                    .font(.caption)
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(20)
                }
                .navigationTitle("Note Details")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Button(action: { isShowingEditSheet = true }) {
                                Label("Edit Note", systemImage: "pencil")
                            }
                            
                            Button(action: {
                                UIPasteboard.general.string = note.text
                            }) {
                                Label("Copy Note", systemImage: "doc.on.doc")
                            }
                            
                            Button(action: { isShowingShareSheet = true }) {
                                Label("Share Note", systemImage: "square.and.arrow.up")
                            }
                            
                            Divider()
                            
                            Button(role: .destructive, action: { isShowingDeleteAlert = true }) {
                                Label("Delete Note", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        .accessibilityLabel("Note options menu")
                    }
                }
                .sheet(isPresented: $isShowingEditSheet) {
                    AddNoteView(store: store, noteToEdit: note)
                }
                .sheet(isPresented: $isShowingShareSheet) {
                    ShareSheet(activityItems: [note.text])
                }
                .alert("Delete Note?", isPresented: $isShowingDeleteAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        store.deleteNote(id: noteId)
                        dismiss()
                    }
                } message: {
                    Text("This note will be permanently removed.")
                }
            } else {
                // If the note was deleted
                VStack(spacing: 12) {
                    Image(systemName: "trash.slash")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("Note is no longer available.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

/// Simple UIKit UIActivityViewController wrapper for native sharing.
private struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
