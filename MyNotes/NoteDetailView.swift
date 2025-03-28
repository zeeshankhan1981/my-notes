import SwiftUI

struct NoteDetailView: View {
    @Binding var note: Note
    @ObservedObject var store: NotesStore

    @State private var isEditing = false
    @State private var showTagOptions = false
    @State private var inputImage: UIImage? = nil
    @State private var showImagePicker = false
    @FocusState private var focusedChecklistIndex: Int?

    private let transitionAnimation = Animation.easeInOut(duration: 0.3)
    private let accentColor = Color.blue

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                titleSection
                contentSection
                checklistSection
                imageSection
                folderSection
                tagSection
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(isEditing ? "Done" : "Edit") {
                    withAnimation(transitionAnimation) {
                        isEditing.toggle()
                        if !isEditing {
                            store.saveNotes()
                        }
                    }
                }
                .foregroundColor(accentColor)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if !isEditing {
                    Menu {
                        Button(action: {
                            note.isPinned.toggle()
                            store.saveNotes()
                        }) {
                            Label(note.isPinned ? "Unpin" : "Pin", systemImage: note.isPinned ? "pin.slash" : "pin")
                        }

                        Button(action: {
                            showTagOptions.toggle()
                        }) {
                            Label("Manage Tags", systemImage: "tag")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(accentColor)
                    }
                }
            }
        }
        .sheet(isPresented: $showTagOptions) {
            Text("Tag Management")
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $inputImage)
        }
        .onChange(of: inputImage) { newImage in
            if let newImage = newImage {
                note.imageData = newImage.jpegData(compressionQuality: 0.8)
                store.saveNotes()
            }
        }
    }

    private var titleSection: some View {
        TextField("Title", text: $note.title)
            .font(.largeTitle)
            .bold()
            .disabled(!isEditing)
    }

    private var contentSection: some View {
        Group {
            if isEditing {
                TextEditor(text: $note.content)
                    .frame(minHeight: 120)
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
            } else {
                Text(note.content)
                    .font(.body)
                    .foregroundColor(.primary)
            }
        }
    }

    private var checklistSection: some View {
        Group {
            if !note.checklist.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Checklist")
                        .font(.headline)

                    ForEach($note.checklist.indices, id: \ .self) { index in
                        Toggle(isOn: $note.checklist[index].isChecked) {
                            if isEditing {
                                TextField("Item", text: $note.checklist[index].text)
                                    .focused($focusedChecklistIndex, equals: index)
                            } else {
                                Text(note.checklist[index].text)
                                    .strikethrough(note.checklist[index].isChecked)
                                    .foregroundColor(note.checklist[index].isChecked ? .gray : .primary)
                            }
                        }
                        .toggleStyle(NoteCheckboxStyle())
                    }
                }
            }
        }
    }

    private var imageSection: some View {
        Group {
            if let imageData = note.imageData, let image = UIImage(data: imageData) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Image")
                        .font(.headline)
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)

                    if isEditing {
                        Button("Change Image") {
                            showImagePicker = true
                        }
                    }
                }
            } else if isEditing {
                Button("Add Image") {
                    showImagePicker = true
                }
            }
        }
    }

    private var folderSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Folder")
                .font(.headline)
            if isEditing {
                TextField("Folder", text: $note.folder)
                    .textFieldStyle(.roundedBorder)
            } else {
                Label(note.folder, systemImage: "folder")
                    .foregroundColor(.blue)
            }
        }
    }

    private var tagSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(.headline)
            if note.tags.isEmpty {
                Text("None")
                    .foregroundColor(.secondary)
            } else {
                Text(note.tags.joined(separator: ", "))
            }
        }
    }
}

struct NoteCheckboxStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                configuration.label
            }
        }
        .buttonStyle(.plain)
    }
} 
