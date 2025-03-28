import Foundation

class ChecklistStore: ObservableObject {
    @Published var checklists: [ChecklistNote] = []

    private let savePath: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("checklists.json")
    }()

    init() {
        load()
    }

    func load() {
        do {
            let data = try Data(contentsOf: savePath)
            checklists = try JSONDecoder().decode([ChecklistNote].self, from: data)
        } catch {
            checklists = []
            print("Failed to load checklists: \(error.localizedDescription)")
        }
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(checklists)
            try data.write(to: savePath, options: [.atomic, .completeFileProtection])
        } catch {
            print("Failed to save checklists: \(error.localizedDescription)")
        }
    }

    func add(_ note: ChecklistNote) {
        checklists.insert(note, at: 0)
        save()
    }

    func delete(at offsets: IndexSet) {
        checklists.remove(atOffsets: offsets)
        save()
    }

    var allFolders: [String] {
        let folders = Set(checklists.map { $0.folder })
        return ["All"] + folders.sorted()
    }

    var allTags: [String] {
        let tags = checklists.flatMap { $0.tags }
        return Array(Set(tags)).sorted()
    }
}
