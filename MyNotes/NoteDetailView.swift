import SwiftUI

struct NoteDetailView: View {
    @Binding var note: Note
    @ObservedObject var store: NotesStore

    @State private var isEditing = false
    @FocusState private var isFocused: Bool
    @State private var newChecklistItem = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if isEditing {
                    TextField("Title", text: $note.title)
                        .font(.title)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .focused($isFocused)
                } else {
                    Text(note.title)
                        .font(.title.bold())
                }

                if isEditing {
                    TextEditor(text: $note.content)
                        .frame(height: 150)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .focused($isFocused)
                } else {
                    Text(note.content)
                        .font(.body)
                }

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Checklist")
                            .font(.headline)
                        Spacer()
                    }

                    ForEach($note.checklist) { $item in
                        HStack {
                            if isEditing {
                                Toggle(isOn: $item.isChecked) {
                                    TextField("Checklist item", text: $item.text)
                                }
                                .toggleStyle(SwitchToggleStyle())
                            } else {
                                Image(systemName: item.isChecked ? "checkmark.square" : "square")
                                    .foregroundColor(item.isChecked ? .blue : .gray)
                                Text(item.text)
                                    .strikethrough(item.isChecked)
                                    .foregroundColor(.primary)
                            }
                        }
                    }

                    if isEditing {
                        HStack {
                            TextField("Add checklist item", text: $newChecklistItem)
                            Button(action: {
                                guard !newChecklistItem.isEmpty else { return }
                                withAnimation {
                                    note.checklist.append(ChecklistItem(text: newChecklistItem, isChecked: false))
                                    newChecklistItem = ""
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(8)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                    }
                }

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

                Spacer()
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
                        } else {
                            isFocused = true
                        }
                    }
                }
            }
        }
    }
}
