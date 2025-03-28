import SwiftUI

struct ChecklistDetailView: View {
    @Binding var checklist: ChecklistNote
    @ObservedObject var store: ChecklistStore

    @State private var isEditing = false
    @FocusState private var focusedIndex: Int?

    private let transition = Animation.easeInOut(duration: 0.3)
    private let accentColor = Color.blue

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Title
                TextField("Title", text: $checklist.title)
                    .font(.largeTitle)
                    .bold()
                    .disabled(!isEditing)

                // Checklist
                VStack(alignment: .leading, spacing: 12) {
                    Text("Checklist")
                        .font(.headline)

                    ForEach($checklist.items.indices, id: \ .self) { index in
                        HStack {
                            Toggle(isOn: $checklist.items[index].isChecked) {
                                TextField("Item", text: $checklist.items[index].text)
                                    .focused($focusedIndex, equals: index)
                            }
                            .toggleStyle(ChecklistCheckboxStyle())
                        }
                        .disabled(!isEditing)
                    }
                }

                // Folder
                VStack(alignment: .leading) {
                    Text("Folder")
                        .font(.headline)
                    TextField("Folder", text: $checklist.folder)
                        .textFieldStyle(.roundedBorder)
                        .disabled(!isEditing)
                }

                // Tags
                VStack(alignment: .leading) {
                    Text("Tags")
                        .font(.headline)
                    Text(checklist.tags.joined(separator: ", "))
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("Checklist")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(isEditing ? "Done" : "Edit") {
                    withAnimation(transition) {
                        isEditing.toggle()
                        if !isEditing {
                            store.save()
                        }
                    }
                }
                .foregroundColor(accentColor)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
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
