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
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 16) {

                    // 🔹 New Folder Selector Style
                    HStack {
                        Text("Filter by:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Menu {
                            ForEach(allFolders, id: \.self) { folder in
                                Button {
                                    selectedFolder = folder
                                } label: {
                                    Label(folder, systemImage: selectedFolder == folder ? "checkmark" : "")
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(selectedFolder)
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray5))
                            .clipShape(Capsule())
                        }

                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)

                    if filteredNotes.isEmpty {
                        Spacer()
                        VStack(spacing: 8) {
                            Text("No notes yet")
                                .font(.title2).foregroundColor(.gray)
                            Text("Tap + to create your first note.")
                                .font(.body).foregroundColor(.gray.opacity(0.7))
                        }
                        Spacer()
                    } else {
                        List {
                            if !pinnedNotes.isEmpty {
                                Section(header: Text("📌 Pinned")) {
                                    noteListView(for: pinnedNotes)
                                }
                            }
                            if !unpinnedNotes.isEmpty {
                                Section(header: Text("Others")) {
                                    noteListView(for: unpinnedNotes)
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
                .navigationTitle("My Notes")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $showingAddNote) {
                    AddNoteView(store: store)
                }
                .searchable(text: $searchText, prompt: "Search notes")
                .navigationDestination(isPresented: Binding(
                    get: { selectedNote != nil },
                    set: { if !$0 { selectedNote = nil } }
                )) {
                    if let note = selectedNote,
                       let index = store.notes.firstIndex(where: { $0.id == note.id }) {
                        let binding = $store.notes[index]
                        NoteDetailView(note: binding, store: store)
                    }
                }
                .background(Color(.systemGray6).ignoresSafeArea())

                Button(action: {
                    withAnimation(.spring()) {
                        showingAddNote = true
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding()
            }
        }
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
                        if note.isPinned {
                            Text("📌")
                        }
                    }
                    Text(note.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(note.content)
                        .lineLimit(1)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(8)
                .background(Color.white)
                
            }
            .buttonStyle(.plain)
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button {
                    if let index = store.notes.firstIndex(where: { $0.id == note.id }) {
                        withAnimation {
                            store.notes[index].isPinned.toggle()
                            store.saveNotes()
                        }
                    }
                } label: {
                    Label(note.isPinned ? "Unpin" : "Pin", systemImage: note.isPinned ? "pin.slash" : "pin")
                }
                .tint(note.isPinned ? .gray : .blue)

                Button(role: .destructive) {
                    if let index = store.notes.firstIndex(where: { $0.id == note.id }) {
                        withAnimation {
                            store.notes.remove(at: index)
                            store.saveNotes()
                        }
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}
