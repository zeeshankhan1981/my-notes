import SwiftUI

struct ContentView: View {
    @StateObject var store = NotesStore()
    @State private var showingAddNote = false
    @State private var showingFolderManager = false
    @State private var searchText = ""
    @State private var selectedNote: Note?
    @State private var selectedFolder: String = "All"
    @State private var selectedTag: String? = nil
    @State private var sortByNewest = true

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 16) {
                    filterMenuBar
                    noteListSection
                }
                .navigationTitle("My Notes")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { toolbarMenu }
                .sheet(isPresented: $showingAddNote) {
                    AddNoteView(store: store)
                }
                .sheet(isPresented: $showingFolderManager) {
                    FolderManagerView(store: store)
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

                Menu {
                    Button {
                        showingAddNote = true
                    } label: {
                        Label("New Note", systemImage: "square.and.pencil")
                    }

                    Button {
                        showingAddNote = true // placeholder for checklist creator
                    } label: {
                        Label("Checklist", systemImage: "checklist")
                    }
                } label: {
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

    var filteredNotes: [Note] {
        var result = store.notes

        if selectedFolder != "All" {
            result = result.filter { $0.folder == selectedFolder }
        }

        if let tag = selectedTag {
            result = result.filter { $0.tags.contains(tag) }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }

        result = result.sorted(by: {
            sortByNewest ? $0.date > $1.date : $0.date < $1.date
        })

        return result
    }

    var pinnedNotes: [Note] { filteredNotes.filter { $0.isPinned } }
    var unpinnedNotes: [Note] { filteredNotes.filter { !$0.isPinned } }

    private var filterMenuBar: some View {
        HStack {
            Text("Filter by:")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Menu {
                Section("Folders") {
                    ForEach(store.allFolders, id: \.self) { folder in
                        Button {
                            selectedFolder = folder
                        } label: {
                            HStack {
                                Text(folder)
                                if selectedFolder == folder {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
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
    }

    private var noteListSection: some View {
        Group {
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
    }

    private var toolbarMenu: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                Button {
                    showingAddNote = true
                } label: {
                    Label("New Note", systemImage: "plus")
                }

                Button {
                    showingFolderManager = true
                } label: {
                    Label("Manage Folders", systemImage: "folder.badge.gear")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.blue)
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
