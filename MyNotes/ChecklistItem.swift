//
//  ChecklistItem.swift
import Foundation

struct ChecklistItem: Identifiable, Codable, Hashable {
    var id = UUID()
    var text: String
    var isChecked: Bool
}
