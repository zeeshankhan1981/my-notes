// AddNoteView.swift
import SwiftUI
import PhotosUI

struct AddNoteView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var store: NotesStore

    @State private var title = ""
    @State private var content = ""
    @State private var folder = "General"
    @State private var tagsText = ""
    @State private var checklist: [ChecklistItem] = []
    @State private var newChecklistItem = ""
    @State private var selectedImageData: Data? = nil
    @State private var selectedPhoto: PhotosPickerItem? = nil

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Note")) {
                    TextField("Title", text: $title)
                    TextEditor(text: $content)
                        .frame(height: 100)
                }

                Section(header: Text("Folder")) {
                    TextField("Folder Name", text: $folder)
                }

                Section(header: Text("Tags (comma-separated)")) {
                    TextField("tag1, tag2", text: $tagsText)
                }

                Section(header: Text("Checklist")) {
                    ForEach(checklist) { item in
                        HStack {
                            Image(systemName: item.isChecked ? "checkmark.square" : "square")
                                .onTapGesture {
                                    if let index = checklist.firstIndex(where: { $0.id == item.id }) {
                                        checklist[index].isChecked.toggle()
                                    }
                                }
                            Text(item.text)
                        }
                    }
                    HStack {
                        TextField("New item", text: $newChecklistItem)
                        Button("Add") {
                            if !newChecklistItem.isEmpty {
                                checklist.append(ChecklistItem(text: newChecklistItem))
                                newChecklistItem = ""
                            }
                        }
                    }
                }

                Section(header: Text("Image")) {
                    if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                    PhotosPicker("Select Image", selection: $selectedPhoto, matching: .images)
                        .onChange(of: selectedPhoto) {
                            Task {
                                if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                                    selectedImageData = data
                                }
                            }
                        }

                }
            }
            .navigationTitle("New Note")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                let tags = tagsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                let newNote = Note(title: title, content: content, date: Date(), folder: folder, tags: tags, checklist: checklist, imageData: selectedImageData)
                store.add(note: newNote)
                presentationMode.wrappedValue.dismiss()
            }.disabled(title.isEmpty || content.isEmpty))
        }
    }
}
