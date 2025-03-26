import SwiftUI

struct NoteDetailView: View {
    @Binding var note: Note
    @ObservedObject var store: NotesStore

    @State private var isEditing = false
    @FocusState private var focusedChecklistIndex: Int?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                NoteHeaderView(note: $note, isEditing: $isEditing)

                Divider()

                ChecklistView(note: $note, store: store, isEditing: $isEditing, focusedChecklistIndex: $focusedChecklistIndex)

                if let imageData = note.imageData,
                   let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .shadow(radius: 4)
                }

                if isEditing {
                    HStack {
                        Text("Folder:")
                        TextField("Enter folder", text: $note.folder)
                            .textFieldStyle(.roundedBorder)
                    }
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "folder")
                        Text(note.folder)
                            .foregroundColor(.blue)
                            .font(.subheadline)
                    }
                    .padding(.top, 8)
                }
            }
            .padding()
        }
        .navigationTitle("Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(isEditing ? "Save" : "Edit") {
                    withAnimation {
                        isEditing.toggle()
                        if !isEditing {
                            store.saveNotes()
                        }
                    }
                }
            }
        }
    }
}

struct NoteHeaderView: View {
    @Binding var note: Note
    @Binding var isEditing: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextField("Title", text: $note.title)
                .font(.title)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

            TextEditor(text: $note.content)
                .frame(height: 150)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
        }
    }
}

struct ChecklistView: View {
    @Binding var note: Note
    var store: NotesStore
    @Binding var isEditing: Bool
    @FocusState.Binding var focusedChecklistIndex: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Checklist")
                .font(.headline)

            ForEach(Array(note.checklist.indices), id: \ .self) { index in
                HStack {
                    Button(action: {
                        note.checklist[index].isChecked.toggle()
                        store.saveNotes()
                    }) {
                        Image(systemName: note.checklist[index].isChecked ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(note.checklist[index].isChecked ? .blue : .gray)
                    }

                    TextField("", text: $note.checklist[index].text)
                        .focused($focusedChecklistIndex, equals: index)
                        .textFieldStyle(.plain)
                        .onSubmit {
                            if !note.checklist[index].text.trimmingCharacters(in: .whitespaces).isEmpty {
                                let newItem = ChecklistItem(text: "", isChecked: false)
                                note.checklist.insert(newItem, at: index + 1)
                                focusedChecklistIndex = index + 1
                            }
                        }
                }
                .padding(.vertical, 4)
            }

            Button(action: {
                note.checklist.append(ChecklistItem(text: "", isChecked: false))
                focusedChecklistIndex = note.checklist.count - 1
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("New Checklist Item")
                }
            }
            .padding(.top, 4)
        }
    }
}
