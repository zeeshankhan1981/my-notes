import SwiftUI

struct FolderItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
}

struct FolderManagerView: View {
    @ObservedObject var store: NotesStore
    @Environment(\.dismiss) var dismiss

    @State private var newFolderName = ""
    @State private var alertMessage: String?

    var folders: [FolderItem] {
        Array(Set(store.notes.map { $0.folder })).sorted(by: { $0 < $1 }).map { FolderItem(name: $0) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Your Folders")) {
                    ForEach(folders) { folder in
                        HStack {
                            Text(folder.name)
                            Spacer()
                            if store.notes.contains(where: { $0.folder == folder.name }) {
                                Text("(\(store.notes.filter { $0.folder == folder.name }.count))")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                        .swipeActions {
                            if store.notes.contains(where: { $0.folder == folder.name }) == false {
                                Button(role: .destructive) {
                                    deleteFolder(folder.name)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }

                Section(header: Text("Create New Folder")) {
                    HStack {
                        TextField("New folder name", text: $newFolderName)
                        Button("Add") {
                            addFolder()
                        }
                        .disabled(newFolderName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .navigationTitle("Manage Folders")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .alert(item: $alertMessage) { msg in
                Alert(title: Text("Error"), message: Text(msg), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func addFolder() {
        let trimmed = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if store.notes.contains(where: { $0.folder == trimmed }) {
            alertMessage = "Folder already exists."
        } else {
            let dummyNote = Note(title: "", content: "", date: Date(), folder: trimmed)
            store.notes.append(dummyNote)
            store.notes.removeAll { $0.id == dummyNote.id } // Remove dummy
            store.saveNotes()
            newFolderName = ""
        }
    }

    private func deleteFolder(_ folder: String) {
        store.notes.removeAll { $0.folder == folder }
        store.saveNotes()
    }
}

extension String: Identifiable {
    public var id: String { self }
}
