import SwiftUI

struct iOSCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            withAnimation(.easeOut(duration: 0.2)) {
                configuration.isOn.toggle()
            }
        }) {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(configuration.isOn ? Color(red: 0.0, green: 0.52, blue: 0.93) : Color(red: 0.65, green: 0.65, blue: 0.65))
                    .font(.system(size: 18))
                configuration.label
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TagView: View {
    let tag: String
    let color: Color
    var onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            // Color indicator
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            // Tag text
            Text(tag)
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))
            
            // Delete button when editing
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color(red: 0.96, green: 0.96, blue: 0.97))
        .cornerRadius(15)
    }
}

struct SimpleTagFlowLayout: View {
    let tags: [String]
    let tagColor: (String) -> Color
    let onDelete: (String) -> Void
    let spacing: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: spacing) {
                    ForEach(tags, id: \.self) { tag in
                        TagView(
                            tag: tag,
                            color: tagColor(tag),
                            onDelete: { onDelete(tag) }
                        )
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}

struct AddNoteView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var store: NotesStore

    @State private var title = ""
    @State private var content = ""
    @State private var folder = "Others"
    @State private var tags: [String] = []
    @State private var newTag = ""
    @State private var checklistItems: [ChecklistItem] = []
    @State private var newChecklistItem = ""
    @State private var image: UIImage? = nil
    @State private var showingImagePicker = false
    
    // Animation constants
    private let fadeDuration: Double = 0.2
    private let moveDuration: Double = 0.3
    
    // Color constants for Bear-inspired design
    private let backgroundColor = Color(red: 0.98, green: 0.98, blue: 0.98)
    private let cardBackgroundColor = Color.white
    private let fieldBackgroundColor = Color(red: 0.97, green: 0.97, blue: 0.98)
    private let accentColor = Color(red: 0.0, green: 0.52, blue: 0.93)
    private let textPrimaryColor = Color(red: 0.13, green: 0.13, blue: 0.13)
    private let textSecondaryColor = Color(red: 0.45, green: 0.45, blue: 0.45)
    private let separatorColor = Color(red: 0.9, green: 0.9, blue: 0.9)
    
    // Tag colors
    private let tagColors: [Color] = [
        Color(red: 0.0, green: 0.52, blue: 0.93),     // Power Blue
        Color(red: 0.2, green: 0.6, blue: 0.86),      // Light Blue
        Color(red: 0.4, green: 0.68, blue: 0.8),      // Sky Blue
        Color(red: 0.0, green: 0.7, blue: 0.7),       // Teal
        Color(red: 0.0, green: 0.6, blue: 0.5),       // Green-Blue
        Color(red: 0.3, green: 0.5, blue: 0.8),       // Indigo
        Color(red: 0.5, green: 0.4, blue: 0.9)        // Purple
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                // Background color
                backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        // Title Field
                        VStack(alignment: .leading, spacing: 6) {
                            TextField("Title", text: $title)
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundColor(textPrimaryColor)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(cardBackgroundColor)
                                .cornerRadius(8)
                                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                        }

                        // Content Field
                        VStack(alignment: .leading, spacing: 6) {
                            TextEditor(text: $content)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(textPrimaryColor)
                                .lineSpacing(3)
                                .frame(minHeight: 150)
                                .padding(16)
                                .background(cardBackgroundColor)
                                .cornerRadius(8)
                                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                        }

                        // Tags Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tags")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(textPrimaryColor)
                                .padding(.leading, 2)
                            
                            // Tag Flow Layout (using custom simple implementation)
                            SimpleTagFlowLayout(
                                tags: tags,
                                tagColor: tagColor,
                                onDelete: { tag in
                                    withAnimation(.easeOut(duration: fadeDuration)) {
                                        tags.removeAll { $0 == tag }
                                    }
                                },
                                spacing: 8
                            )
                            
                            // Add Tag Field
                            HStack(spacing: 10) {
                                TextField("Add tag", text: $newTag)
                                    .font(.system(size: 15))
                                    .padding(10)
                                    .background(fieldBackgroundColor)
                                    .cornerRadius(8)
                                    .onSubmit {
                                        addTag()
                                    }
                                
                                Button(action: addTag) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(width: 30, height: 30)
                                        .background(accentColor)
                                        .clipShape(Circle())
                                }
                                .disabled(newTag.isEmpty)
                                .opacity(newTag.isEmpty ? 0.5 : 1)
                            }
                        }
                        .padding(16)
                        .background(cardBackgroundColor)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)

                        // Checklist Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Checklist")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(textPrimaryColor)
                                .padding(.leading, 2)

                            VStack(alignment: .leading, spacing: 8) {
                                ForEach($checklistItems) { $item in
                                    Toggle(isOn: $item.isChecked) {
                                        Text(item.text)
                                            .font(.system(size: 15))
                                            .strikethrough(item.isChecked, color: textSecondaryColor)
                                            .foregroundColor(item.isChecked ? textSecondaryColor : textPrimaryColor)
                                    }
                                    .toggleStyle(iOSCheckboxToggleStyle())
                                    .padding(.vertical, 4)
                                }
                                .padding(.horizontal, 2)
                            }

                            HStack(spacing: 10) {
                                TextField("Add item", text: $newChecklistItem)
                                    .font(.system(size: 15))
                                    .padding(10)
                                    .background(fieldBackgroundColor)
                                    .cornerRadius(8)
                                    .onSubmit {
                                        addChecklistItem()
                                    }

                                Button(action: addChecklistItem) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(width: 30, height: 30)
                                        .background(accentColor)
                                        .clipShape(Circle())
                                }
                                .disabled(newChecklistItem.isEmpty)
                                .opacity(newChecklistItem.isEmpty ? 0.5 : 1)
                            }
                        }
                        .padding(16)
                        .background(cardBackgroundColor)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                        
                        // Folder Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Folder")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(textPrimaryColor)
                                .padding(.leading, 2)
                                
                            TextField("Folder name", text: $folder)
                                .font(.system(size: 15))
                                .padding(10)
                                .background(fieldBackgroundColor)
                                .cornerRadius(8)
                        }
                        .padding(16)
                        .background(cardBackgroundColor)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)

                        // Image Section
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Image")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(textPrimaryColor)
                                .padding(.leading, 2)
                                
                            if let image = image {
                                VStack {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(8)
                                        .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
                                }
                                .padding(.bottom, 8)
                            }
                            
                            Button(action: {
                                showingImagePicker = true
                            }) {
                                HStack {
                                    Image(systemName: "photo")
                                        .font(.system(size: 15))
                                    Text("Select Image")
                                        .font(.system(size: 15, weight: .medium))
                                }
                                .foregroundColor(accentColor)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                                .background(fieldBackgroundColor)
                                .cornerRadius(8)
                            }
                        }
                        .padding(16)
                        .background(cardBackgroundColor)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Add Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(accentColor)
                    .font(.system(size: 16, weight: .regular))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newNote = Note(
                            title: title,
                            content: content,
                            date: Date(),
                            isPinned: false,
                            folder: folder,
                            tags: tags,
                            checklist: checklistItems,
                            imageData: image?.pngData()
                        )
                        store.notes.append(newNote)
                        store.saveNotes()
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(accentColor)
                    .opacity((title.isEmpty && content.isEmpty) ? 0.5 : 1)
                    .disabled(title.isEmpty && content.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $image)
            }
        }
    }
    
    // Helper Functions
    private func addTag() {
        guard !newTag.isEmpty && !tags.contains(newTag) else { return }
        
        withAnimation(.easeInOut(duration: fadeDuration)) {
            tags.append(newTag)
            newTag = ""
        }
    }
    
    private func addChecklistItem() {
        guard !newChecklistItem.isEmpty else { return }
        
        withAnimation(.easeInOut(duration: fadeDuration)) {
            checklistItems.append(ChecklistItem(text: newChecklistItem, isChecked: false))
            newChecklistItem = ""
        }
    }
    
    private func tagColor(for tag: String) -> Color {
        let index = abs(tag.hashValue) % tagColors.count
        return tagColors[index]
    }
}
