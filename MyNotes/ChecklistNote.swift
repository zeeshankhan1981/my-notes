import Foundation

struct ChecklistNote: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var folder: String
    var tags: [String]
    var items: [ChecklistItem]
    var date: Date
    var isPinned: Bool = false

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ChecklistNote, rhs: ChecklistNote) -> Bool {
        lhs.id == rhs.id
    }
}
