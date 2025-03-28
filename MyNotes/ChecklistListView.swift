import SwiftUI

struct ChecklistListView: View {
    @StateObject var store = ChecklistStore()
    @State private var selectedChecklist: ChecklistNote?

    var body: some View {
        NavigationStack {
            Group {
                if store.checklists.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Text("No checklists yet")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Tap + to create a checklist")
                            .font(.body)
                            .foregroundColor(.gray.opacity(0.7))
                        Spacer()
                    }
                } else {
                    List(store.checklists) { checklist in
                        Button(action: {
                            selectedChecklist = checklist
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(checklist.title)
                                    .font(.headline)
                                Text(checklist.date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Checklists")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Optional: trigger new checklist creation view
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(isPresented: Binding(
                get: { selectedChecklist != nil },
                set: { if !$0 { selectedChecklist = nil } }
            )) {
                if let selected = selectedChecklist,
                   let index = store.checklists.firstIndex(where: { $0.id == selected.id }) {
                    ChecklistDetailView(checklist: $store.checklists[index], store: store)
                }
            }
        }
    }
}
