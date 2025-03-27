//
//  ChecklistItem.swift
import Foundation

struct ChecklistItem: Identifiable, Codable, Hashable, Equatable {
    var id = UUID()
    var text: String
    var isChecked: Bool
    
    init(text: String, isChecked: Bool = false) {
        self.text = text
        self.isChecked = isChecked
    }
    
    // Explicit Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Explicit Equatable conformance
    static func == (lhs: ChecklistItem, rhs: ChecklistItem) -> Bool {
        return lhs.id == rhs.id
    }
}
