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
    
    init(title: String, content: String, date: Date = Date(), tags: [String] = [], isPinned: Bool = false, folder: String = "General", checklist: [ChecklistItem] = [], imageData: Data? = nil) {
        self.title = title
        self.content = content
        self.date = date
        self.tags = tags
        self.isPinned = isPinned
        self.folder = folder
        self.checklist = checklist
        self.imageData = imageData
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        lhs.id == rhs.id
    }
}
