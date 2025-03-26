// NoteDetailView.swift
import SwiftUI

struct NoteDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var store: NotesStore
    var note: Note

    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedContent: String
    @State private var editedChecklist: [ChecklistItem]

    init(note: Note, store: NotesStore) {
        self.note = note
        self.store = store
        _editedTitle = State(initialValue: note.title)
        _editedContent = State(initialValue: note.content)
        _editedChecklist = State(initialValue: note.checklist)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if isEditing {
                    TextField("Title", text: $editedTitle)
                        .font(.title2.bold())
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    TextEditor(text: $editedContent)
                        .frame(minHeight: 150)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)

                    checklistSection
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(editedTitle)
                            .font(.largeTitle.bold())

                        Text(note.date, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Divider()

                        Text(.init(editedContent))
                            .font(.body)
                            .padding(.bottom, 8)

                        checklistSection

                        if !note.tags.isEmpty {
                            HStack {
                                ForEach(note.tags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color("#B0D0FF").opacity(0.2))
                                        .foregroundColor(.black)
                                        .cornerRadius(12)
                                }
                            }
                        }

                        if let imageData = note.imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 250)
                                .cornerRadius(12)
                                .padding(.top)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .navigationTitle("Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Save" : "Edit") {
                    if isEditing {
                        if let index = store.notes.firstIndex(where: { $0.id == note.id }) {
                            store.notes[index].title = editedTitle
                            store.notes[index].content = editedContent
                            store.notes[index].checklist = editedChecklist
                            store.saveNotes()
                        }
                        isEditing = false
                    } else {
                        isEditing = true
                    }
                }
                .foregroundColor(Color("#B0D0FF"))
            }
        }
    }

    var checklistSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !editedChecklist.isEmpty {
                Text("Checklist")
                    .font(.headline)
                ForEach($editedChecklist) { $item in
                    HStack(spacing: 10) {
                        Image(systemName: item.isChecked ? "checkmark.square.fill" : "square")
                            .foregroundColor(item.isChecked ? Color("#B0D0FF") : .gray)
                            .onTapGesture {
                                item.isChecked.toggle()
                            }
                        Text(item.text)
                    }
                }
            }
        }
    }
}
