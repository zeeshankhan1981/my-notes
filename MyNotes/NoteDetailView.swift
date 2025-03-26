import SwiftUI

struct NoteDetailView: View {
    @Binding var note: Note
    @ObservedObject var store: NotesStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(note.title)
                    .font(.largeTitle).bold()

                Text(note.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Divider()

                Text(note.content)
                    .font(.body)

                if !note.checklist.isEmpty {
                    Text("Checklist")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 8) {
                        ForEach($note.checklist) { $item in
                            HStack {
                                Button(action: {
                                    item.isChecked.toggle()
                                    store.saveNotes()
                                }) {
                                    Image(systemName: item.isChecked ? "checkmark.square.fill" : "square")
                                        .foregroundColor(item.isChecked ? .blue : .gray)
                                }

                                Text(item.text)
                                    .strikethrough(item.isChecked)
                                    .foregroundColor(item.isChecked ? .gray : .primary)

                                Spacer()
                            }
                            .padding(8)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                        }
                    }
                }

                if let data = note.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .padding(.top, 16)
                }

                Spacer()
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Note")
        .navigationBarTitleDisplayMode(.inline)
    }
}
