// Note.swift
import Foundation

struct Note: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var content: String
    var date: Date
    var isPinned: Bool = false
    var folder: String = "General"
    var tags: [String] = []
    var checklist: [ChecklistItem] = []
    var imageData: Data? = nil
    
    // For markdown support
    var isMarkdown: Bool = false
    
    // Hashable implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Equatable implementation
    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.id == rhs.id
    }
}
