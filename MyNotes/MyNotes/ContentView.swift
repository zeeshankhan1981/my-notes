import SwiftUI

struct ContentView: View {
    @StateObject var store = NotesStore()
    @State private var showingAddNote = false
    @State private var searchText = ""
    @State private var selectedNote: Note?
    @State private var selectedFolder: String = "All"

    var filteredNotes: [Note] {
        let notesInFolder = selectedFolder == "All" ? store.notes : store.notes.filter { $0.folder == selectedFolder }

        let sortedNotes = notesInFolder.sorted {
            if $0.isPinned != $1.isPinned {
                return $0.isPinned && !$1.isPinned
            } else {
                return $0.date > $1.date
            }
        }

        if searchText.isEmpty {
            return sortedNotes
        } else {
            return sortedNotes.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var pinnedNotes: [Note] {
        filteredNotes.filter { $0.isPinned }
    }

    var unpinnedNotes: [Note] {
        filteredNotes.filter { !$0.isPinned }
    }

    var allFolders: [String] {
        let folders = Set(store.notes.map { $0.folder })
        return ["All"] + folders.sorted()
    }

    var body: some View {
        MainView()
            .environmentObject(store)
    }

    @ViewBuilder
    func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    func noteListView(for notes: [Note]) -> some View {
        ForEach(notes) { note in
            Button(action: {
                withAnimation(.easeInOut) {
                    selectedNote = note
                }
            }) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(note.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        if note.isPinned {
                            Image(systemName: "pin.fill")
                                .foregroundColor(.blue)
                        }
                    }

                    Text(note.content)
                        .lineLimit(2)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "calendar")
                        Text(note.date.formatted(date: .abbreviated, time: .omitted))
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(14)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(.plain)
            .contextMenu {
                Button(note.isPinned ? "Unpin" : "Pin") {
                    if let index = store.notes.firstIndex(where: { $0.id == note.id }) {
                        withAnimation {
                            store.notes[index].isPinned.toggle()
                            store.saveNotes()
                        }
                    }
                }
                
                Button("Delete") {
                    if let index = store.notes.firstIndex(where: { $0.id == note.id }) {
                        withAnimation {
                            store.notes.remove(at: index)
                            store.saveNotes()
                        }
                    }
                }
                .foregroundColor(.red)
            }
        }
    }
}
