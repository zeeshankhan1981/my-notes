import SwiftUI

struct ChecklistDetailView: View {
    @Binding var checklist: ChecklistNote
    @ObservedObject var store: ChecklistStore

    @State private var isEditing = false
    @FocusState private var focusedIndex: Int?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                TextField("Title", text: $checklist.title)
                    .font(.largeTitle)
                    .bold()
                    .disabled(!isEditing)

                Text("Date: \(checklist.date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if isEditing {
                    ForEach($checklist.items.indices, id: \.self) { index in
                        HStack {
                            Toggle(isOn: $checklist.items[index].isChecked) {
                                TextField("Item", text: $checklist.items[index].text)
                                    .focused($focusedIndex, equals: index)
                            }
                            .toggleStyle(ChecklistCheckboxStyle())
                        }
                    }

                    Button(action: {
                        checklist.items.append(ChecklistItem(text: "", isChecked: false))
                        focusedIndex = checklist.items.count - 1
                    }) {
                        Label("Add Item", systemImage: "plus.circle")
                            .foregroundColor(.blue)
                    }
                } else {
                    ForEach($checklist.items) { $item in
                        Toggle(isOn: $item.isChecked) {
                            Text(item.text)
                                .strikethrough(item.isChecked)
                                .foregroundColor(item.isChecked ? .gray : .primary)
                        }
                        .toggleStyle(ChecklistCheckboxStyle())
                    }
                }

                Divider()

                VStack(alignment: .leading) {
                    Text("Folder")
                        .font(.headline)
                    if isEditing {
                        TextField("Folder", text: $checklist.folder)
                            .textFieldStyle(.roundedBorder)
                    } else {
                        Text(checklist.folder)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(isEditing ? "Done" : "Edit") {
                    withAnimation {
                        isEditing.toggle()
                        store.saveChecklists()
                    }
                }
            }
        }
    }
}

struct ChecklistCheckboxStyle: ToggleStyle {
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
