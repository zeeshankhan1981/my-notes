// Note.swift
import Foundation

struct ChecklistItem: Identifiable, Codable {
    var id = UUID()
    var text: String
    var isChecked: Bool = false
}

struct Note: Identifiable, Codable {
    var id = UUID()
    var title: String
    var content: String
    var date: Date
    var isPinned: Bool = false
    var folder: String = "General"
    var tags: [String] = []
    var checklist: [ChecklistItem] = []
    var imageData: Data? = nil
}
