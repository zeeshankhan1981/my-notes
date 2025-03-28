import SwiftUI

struct AddChecklistView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var folder = "General"
    @State private var tags: [String] = []
    @State private var newTag = ""
    @State private var items: [ChecklistItem] = []
    @State private var newItem = ""

    var onSave: (ChecklistNote) -> Void

    private let accentColor = Color.blue
    private let tagColors: [Color] = [
        .blue, .teal, .mint, .cyan, .indigo, .purple, .orange
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Title
                    TextField("Checklist title", text: $title)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)

                    // Checklist Items
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Checklist")
                            .font(.headline)
                        ForEach($items) { $item in
                            Toggle(isOn: $item.isChecked) {
                                TextField("Item", text: $item.text)
                            }
                            .toggleStyle(CheckboxStyle())
                        }

                        HStack {
                            TextField("New item", text: $newItem)
                                .textFieldStyle(.roundedBorder)
                            Button {
                                addItem()
                            } label: {
                                Image(systemName: "plus")
                                    .padding(6)
                                    .background(accentColor)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                            }
                            .disabled(newItem.isEmpty)
                        }
                    }

                    // Folder
                    VStack(alignment: .leading) {
                        Text("Folder")
                            .font(.headline)
                        TextField("Folder name", text: $folder)
                            .padding(10)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(8)
                    }

                    // Tags
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tags")
                            .font(.headline)

                        SimpleTagFlowLayout(
                            tags: tags,
                            tagColor: tagColor,
                            onDelete: { tag in tags.removeAll { $0 == tag } },
                            spacing: 8
                        )

                        HStack {
                            TextField("New tag", text: $newTag)
                                .textFieldStyle(.roundedBorder)
                            Button("Add") {
                                addTag()
                            }
                            .disabled(newTag.isEmpty)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("New Checklist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let checklist = ChecklistNote(
                            id: UUID(),
                            title: title,
                            folder: folder,
                            tags: tags,
                            items: items,
                            date: Date(),
                            isPinned: false
                        )
                        onSave(checklist)
                        dismiss()
                    }
                    .disabled(title.isEmpty || items.isEmpty)
                }
            }
        }
    }

    private func addItem() {
        items.append(ChecklistItem(text: newItem))
        newItem = ""
    }

    private func addTag() {
        guard !tags.contains(newTag) else { return }
        tags.append(newTag)
        newTag = ""
    }

    private func tagColor(for tag: String) -> Color {
        let index = abs(tag.hashValue) % tagColors.count
        return tagColors[index]
    }
}

struct CheckboxStyle: ToggleStyle {
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
