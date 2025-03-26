import SwiftUI

struct iOSCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            withAnimation {
                configuration.isOn.toggle()
            }
        }) {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundColor(configuration.isOn ? .blue : .gray)
                    .font(.system(size: 20))
                configuration.label
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AddNoteView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var store: NotesStore

    @State private var title = ""
    @State private var content = ""
    @State private var folder = "Others"
    @State private var checklistItems: [ChecklistItem] = []
    @State private var newChecklistItem = ""
    @State private var image: UIImage? = nil
    @State private var showingImagePicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    TextField("Title", text: $title)
                        .font(.title)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)

                    TextEditor(text: $content)
                        .frame(height: 120)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Checklist")
                            .font(.headline)

                        ForEach($checklistItems) { $item in
                            Toggle(isOn: $item.isChecked) {
                                Text(item.text)
                                    .strikethrough(item.isChecked, color: .gray)
                                    .foregroundColor(item.isChecked ? .gray : .primary)
                            }
                            .toggleStyle(iOSCheckboxToggleStyle())
                        }

                        HStack {
                            TextField("Add checklist item", text: $newChecklistItem)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            Button(action: {
                                if !newChecklistItem.isEmpty {
                                    checklistItems.append(ChecklistItem(text: newChecklistItem, isChecked: false))
                                    newChecklistItem = ""
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                            }
                            .disabled(newChecklistItem.isEmpty)
                        }
                        .padding(.top, 4)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Folder")
                            .font(.headline)
                        TextField("Folder name", text: $folder)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Image")
                            .font(.headline)
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(12)
                                .shadow(radius: 4)
                        }
                        Button("Select Image") {
                            showingImagePicker = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
            }
            .navigationTitle("Add Note")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newNote = Note(
                            title: title,
                            content: content,
                            date: Date(),
                            isPinned: false,
                            folder: folder,
                            checklist: checklistItems,
                            imageData: image?.pngData()
                        )
                        store.notes.append(newNote)
                        store.saveNotes()
                        dismiss()
                    }
                    .disabled(title.isEmpty && content.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $image)
            }
        }
    }
}
