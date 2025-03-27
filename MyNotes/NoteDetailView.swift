import SwiftUI

struct NoteDetailView: View {
    @Binding var note: Note
    @ObservedObject var store: NotesStore

    @State private var isEditing = false
    @FocusState private var focusedChecklistIndex: Int?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {

                // Title Field
                TextField("Title", text: $note.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .padding(.horizontal)
                    .padding(.top)

                // Body Content
                TextEditor(text: $note.content)
                    .font(.system(.body, design: .rounded))
                    .frame(minHeight: 160)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal)

                // Checklist
                if !note.checklist.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(note.checklist.indices), id: \ .self) { index in
                            HStack(spacing: 12) {
                                Button {
                                    note.checklist[index].isChecked.toggle()
                                    store.saveNotes()
                                } label: {
                                    Image(systemName: note.checklist[index].isChecked ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(note.checklist[index].isChecked ? .blue : .gray)
                                        .font(.title3)
                                }

                                TextField("", text: $note.checklist[index].text)
                                    .focused($focusedChecklistIndex, equals: index)
                                    .font(.system(.body, design: .rounded))
                                    .strikethrough(note.checklist[index].isChecked, color: .gray)
                                    .foregroundColor(note.checklist[index].isChecked ? .gray : .primary)
                                    .onSubmit {
                                        let trimmed = note.checklist[index].text.trimmingCharacters(in: .whitespaces)
                                        if !trimmed.isEmpty {
                                            note.checklist.insert(ChecklistItem(text: "", isChecked: false), at: index + 1)
                                            focusedChecklistIndex = index + 1
                                        }
                                    }
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal)
                            .background(Color(.tertiarySystemGroupedBackground))
                            .cornerRadius(10)
                        }

                        Button {
                            note.checklist.append(ChecklistItem(text: "", isChecked: false))
                            focusedChecklistIndex = note.checklist.count - 1
                        } label: {
                            Label("New Checklist Item", systemImage: "plus.circle")
                                .foregroundColor(.blue)
                        }
                        .font(.subheadline)
                        .padding(.horizontal)
                        .padding(.top, 4)
                    }
                }

                // Image
                if let imageData = note.imageData, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .shadow(radius: 4)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                }

                // Folder
                VStack(alignment: .leading, spacing: 6) {
                    if isEditing {
                        Text("Folder")
                            .font(.headline)
                        TextField("Enter folder", text: $note.folder)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .rounded))
                    } else {
                        HStack(spacing: 6) {
                            Image(systemName: "folder")
                            Text(note.folder)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.horizontal)

                // Tags
                if !note.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(note.tags, id: \ .self) { tag in
                                Text("#\(tag)")
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.bottom, 32)
        }
        .navigationTitle("")
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
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}
