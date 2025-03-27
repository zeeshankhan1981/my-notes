import SwiftUI

struct MainView: View {
    @EnvironmentObject private var notesStore: NotesStore
    @State private var selectedNoteID: UUID?
    @State private var selectedTag: String?
    @State private var searchText: String = ""
    @State private var showingAddNote = false
    
    // Computed property to get the selected note based on its ID
    private var selectedNote: Note? {
        guard let selectedNoteID = selectedNoteID else { return nil }
        return notesStore.notes.first { $0.id == selectedNoteID }
    }
    
    var body: some View {
        NavigationSplitView {
            // Sidebar - Tags Panel
            tagsList
        } content: {
            // Middle Panel - Notes List
            notesList
        } detail: {
            // Right Panel - Note Detail
            detailView
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: $showingAddNote) {
            AddNoteView(store: notesStore)
        }
    }
    
    // MARK: - View Components
    
    private var tagsList: some View {
        List(selection: $selectedTag) {
            Section(header: Text("TAGS").font(.caption).foregroundColor(.secondary)) {
                ForEach(notesStore.tags, id: \.self) { tag in
                    tagRow(tag: tag)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Tags")
    }
    
    private func tagRow(tag: String) -> some View {
        HStack {
            Circle()
                .fill(tagColor(for: tag))
                .frame(width: 12, height: 12)
            
            Text(tag)
                .font(.system(.body))
        }
        .tag(tag)
    }
    
    private var notesList: some View {
        VStack(spacing: 0) {
            // Search bar
            searchBar
            
            Divider()
            
            notesListContent
        }
        .navigationTitle("Notes")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showingAddNote = true
                }) {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    private var notesListContent: some View {
        let filteredNotes = filteredAndSortedNotes()
        
        return List(filteredNotes, selection: $selectedNoteID) { note in
            NoteRow(note: note, isSelected: selectedNoteID == note.id)
                .tag(note.id)
                .onTapGesture {
                    selectedNoteID = note.id
                }
        }
        .listStyle(.plain)
    }
    
    private var detailView: some View {
        Group {
            if let note = selectedNote,
               let index = notesStore.notes.firstIndex(where: { $0.id == note.id }) {
                NoteDetailView(note: $notesStore.notes[index], store: notesStore)
            } else {
                Text("Select a note to view")
                    .foregroundColor(.secondary)
                    .font(.headline)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func filteredAndSortedNotes() -> [Note] {
        // Step 1: Filter by tag if a tag is selected
        let tagFiltered: [Note]
        if let selectedTag = selectedTag {
            tagFiltered = notesStore.notes.filter { note in
                note.tags.contains(selectedTag)
            }
        } else {
            tagFiltered = notesStore.notes
        }
        
        // Step 2: Filter by search text if provided
        let searchFiltered: [Note]
        if searchText.isEmpty {
            searchFiltered = tagFiltered
        } else {
            searchFiltered = tagFiltered.filter { note in
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Step 3: Sort by pinned status first, then date
        return searchFiltered.sorted { note1, note2 in
            if note1.isPinned != note2.isPinned {
                return note1.isPinned && !note2.isPinned
            } else {
                return note1.date > note2.date
            }
        }
    }
    
    private func tagColor(for tag: String) -> Color {
        let colors: [Color] = [
            .red, .orange, .yellow, .green, .blue, .purple, .pink
        ]
        
        // Use the tag's hash value to select a consistent color
        let index = abs(tag.hashValue) % colors.count
        return colors[index]
    }
}

struct NoteRow: View {
    let note: Note
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            titleRow
            
            Text(note.content.prefix(80))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            metadataRow
        }
        .padding(.vertical, 6)
        .background(isSelected ? Color.gray.opacity(0.15) : Color.clear)
    }
    
    private var titleRow: some View {
        HStack {
            Text(note.title)
                .font(.headline)
                .lineLimit(1)
            
            if note.isPinned {
                Spacer()
                Image(systemName: "pin.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
    }
    
    private var metadataRow: some View {
        HStack(spacing: 4) {
            Text(formattedDate(note.date))
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            tagsList
        }
    }
    
    private var tagsList: some View {
        Group {
            ForEach(Array(note.tags.prefix(2)), id: \.self) { tag in
                Text(tag)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
            }
            
            if note.tags.count > 2 {
                Text("+\(note.tags.count - 2)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
