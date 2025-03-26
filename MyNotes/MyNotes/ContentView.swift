// ContentView.swift
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
            ZStack {
                VStack(spacing: 12) {
                    HStack {
                        Text("Folder")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Picker("Folder", selection: $selectedFolder) {
                            ForEach(allFolders, id: \.self) { folder in
                                Text(folder).tag(folder)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .padding(.horizontal)

                    List {
                        if pinnedNotes.isEmpty && unpinnedNotes.isEmpty {
                            VStack(spacing: 12) {
                                Text("No notes yet")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                                Text("Tap + to create your first note.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 100)
                            .listRowBackground(Color.clear)
                        }

                        if !pinnedNotes.isEmpty {
                            Section(header: Text("📌 Pinned").font(.subheadline).foregroundColor(.gray)) {
                                noteListView(for: pinnedNotes)
                            }
                        }
                        if !unpinnedNotes.isEmpty {
                            Section(header: Text("Others").font(.subheadline).foregroundColor(.gray)) {
                                noteListView(for: unpinnedNotes)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .searchable(text: $searchText, prompt: "Search notes")
                }

                // Floating Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingAddNote = true
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
            .navigationTitle("My Notes")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddNote) {
                AddNoteView(store: store)
            }
            .navigationDestination(isPresented: Binding(
                get: { selectedNote != nil },
                set: { if !$0 { selectedNote = nil } }
            )) {
                if let note = selectedNote {
                    NoteDetailView(note: note, store: store)
                }
            }
            .accentColor(.blue)
        }
        .background(Color(.systemGray6).ignoresSafeArea())
    }

    @ViewBuilder
    func noteListView(for notes: [Note]) -> some View {
        ForEach(notes, id: \.id) { note in
            Button(action: {
                selectedNote = note
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
                        .lineLimit(2)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(.plain)
            .listRowInsets(EdgeInsets())
            .padding(.vertical, 4)
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button {
                    if let index = store.notes.firstIndex(where: { $0.id == note.id }) {
                        store.notes[index].isPinned.toggle()
                        store.saveNotes()
                    }
                } label: {
                    Label(note.isPinned ? "Unpin" : "Pin", systemImage: note.isPinned ? "pin.slash" : "pin")
                }
                .tint(note.isPinned ? .gray : Color.blue.opacity(0.7))

                Button(role: .destructive) {
                    if let index = store.notes.firstIndex(where: { $0.id == note.id }) {
                        store.notes.remove(at: index)
                        store.saveNotes()
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}
