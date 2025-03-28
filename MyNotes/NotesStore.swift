import Foundation

class NotesStore: ObservableObject {
    @Published var notes: [Note] = []
    let savePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("notes.json")

    init() {
        loadNotes()
    }

    func loadNotes() {
        do {
            let data = try Data(contentsOf: savePath)
            notes = try JSONDecoder().decode([Note].self, from: data)
        } catch {
            notes = []
        }
    }

    func saveNotes() {
        do {
            let data = try JSONEncoder().encode(notes)
            try data.write(to: savePath)
        } catch {
            print("Failed to save notes.")
        }
    }

    func add(note: Note) {
        notes.insert(note, at: 0)
        saveNotes()
    }

    func delete(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
        saveNotes()
    }

    var allFolders: [String] {
        let folders = Set(notes.map { $0.folder })
        return ["All"] + folders.sorted()
    }

    var allTags: [String] {
        let tags = notes.flatMap { $0.tags }
        return Array(Set(tags)).sorted()
    }
}
