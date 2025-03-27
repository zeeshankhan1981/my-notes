import SwiftUI

struct iOSCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            withAnimation {
                configuration.isOn.toggle()
            }
        }) {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(configuration.isOn ? .blue : .gray)
                    .font(.title3)
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
                VStack(alignment: .leading, spacing: 24) {

                    // Title
                    TextField("Title", text: $title)
                        .font(.system(.title, design: .rounded))
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)

                    // Content
                    TextEditor(text: $content)
                        .frame(height: 160)
                        .font(.system(.body, design: .rounded))
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)

                    // Checklist
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Checklist")
                            .font(.headline)

                        ForEach($checklistItems) { $item in
                            HStack(spacing: 12) {
                                Toggle(isOn: $item.isChecked) {
                                    TextField("Checklist item", text: $item.text)
                                        .font(.system(.body, design: .rounded))
                                }
                                .toggleStyle(iOSCheckboxToggleStyle())
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                            .background(Color(.tertiarySystemGroupedBackground))
                            .cornerRadius(10)
                        }

                        HStack {
                            TextField("Add checklist item", text: $newChecklistItem)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.system(.body, design: .rounded))

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

                    // Folder
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Folder")
                            .font(.headline)
                        TextField("Folder name", text: $folder)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                            .font(.system(.body, design: .rounded))
                    }

                    // Image
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
                            tags: [folder],
                            isPinned: false,
                            folder: folder,
                            checklist: checklistItems,
                            imageData: image?.pngData()
                        )
                        store.add(note: newNote)
                        dismiss()
                    }
                    .disabled(title.isEmpty && content.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker, content: {
                ImagePicker(selectedImage: $image)
            })
            .background(Color(.systemBackground))
        }
    }
}
