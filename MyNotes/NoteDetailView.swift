import SwiftUI

struct NoteDetailView: View {
    @Binding var note: Note
    @ObservedObject var store: NotesStore

    @State private var isEditing = false
    @FocusState private var focusedChecklistIndex: Int?
    @State private var showTagOptions = false
    
    // Animation constants
    private let transitionAnimation = Animation.easeInOut(duration: 0.3)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Title area
                titleSection
                
                // Content area with proper spacing
                contentSection
                
                // Checklist section
                if !note.checklist.isEmpty {
                    checklistSection
                }

                // Image section (if available)
                if let imageData = note.imageData, let image = UIImage(data: imageData) {
                    imageSection(image: image)
                }
                
                // Metadata section - tags and folder
                metadataSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(red: 0.98, green: 0.98, blue: 0.98).ignoresSafeArea())
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
                .foregroundColor(Color(red: 0.0, green: 0.52, blue: 0.93))
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
                            .foregroundColor(Color(red: 0.0, green: 0.52, blue: 0.93))
                    }
                }
            }
        }
        .sheet(isPresented: $showTagOptions) {
            // Tag management sheet would go here
            Text("Tag Management")
                .presentationDetents([.medium])
        }
    }
    
    // MARK: - View Components
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if isEditing {
                TextField("Title", text: $note.title)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))
                    .padding(.top, 24)
                    .padding(.bottom, 16)
            } else {
                Text(note.title)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))
                    .padding(.top, 24)
                    .padding(.bottom, 16)
            }
            
            // Date and metadata line
            HStack {
                Text(formattedDate(note.date))
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
                
                if note.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption2)
                        .foregroundColor(Color(red: 0.0, green: 0.52, blue: 0.93))
                        .padding(.leading, 4)
                }
            }
            .padding(.bottom, 16)
            
            Divider()
                .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                .padding(.bottom, 24)
        }
    }
    
    private var contentSection: some View {
        Group {
            if isEditing {
                TextEditor(text: $note.content)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))
                    .frame(minHeight: 200)
                    .padding(8)
                    .background(Color(red: 0.96, green: 0.96, blue: 0.97))
                    .cornerRadius(8)
                    .shadow(
                        color: Color.black.opacity(0.1),
                        radius: 2,
                        x: 0,
                        y: 1
                    )
                    .padding(.bottom, 24)
            } else {
                Text(note.content)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 24)
            }
        }
    }
    
    private var checklistSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Checklist")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))
                .padding(.bottom, 4)

            ForEach(Array(note.checklist.indices), id: \.self) { index in
                HStack(spacing: 16) {
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) {
                            note.checklist[index].isChecked.toggle()
                            store.saveNotes()
                        }
                    } label: {
                        Image(systemName: note.checklist[index].isChecked ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(note.checklist[index].isChecked ? Color(red: 0.0, green: 0.52, blue: 0.93) : Color(red: 0.45, green: 0.45, blue: 0.45))
                            .font(.system(size: 18))
                    }

                    if isEditing {
                        TextField("", text: $note.checklist[index].text)
                            .focused($focusedChecklistIndex, equals: index)
                            .font(.system(size: 16, weight: .regular))
                            .strikethrough(note.checklist[index].isChecked, color: Color(red: 0.45, green: 0.45, blue: 0.45))
                            .foregroundColor(note.checklist[index].isChecked ? Color(red: 0.45, green: 0.45, blue: 0.45) : Color(red: 0.13, green: 0.13, blue: 0.13))
                            .onSubmit {
                                if !note.checklist[index].text.trimmingCharacters(in: .whitespaces).isEmpty {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        note.checklist.insert(ChecklistItem(text: "", isChecked: false), at: index + 1)
                                        focusedChecklistIndex = index + 1
                                    }
                                }
                            }
                    } else {
                        Text(note.checklist[index].text)
                            .font(.system(size: 16, weight: .regular))
                            .strikethrough(note.checklist[index].isChecked, color: Color(red: 0.45, green: 0.45, blue: 0.45))
                            .foregroundColor(note.checklist[index].isChecked ? Color(red: 0.45, green: 0.45, blue: 0.45) : Color(red: 0.13, green: 0.13, blue: 0.13))
                    }
                }
                .padding(.vertical, 4)
                .animation(.easeOut(duration: 0.2), value: note.checklist[index].isChecked)
            }

            if isEditing {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        note.checklist.append(ChecklistItem(text: "", isChecked: false))
                        focusedChecklistIndex = note.checklist.count - 1
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color(red: 0.0, green: 0.52, blue: 0.93))
                        Text("Add Item")
                            .foregroundColor(Color(red: 0.0, green: 0.52, blue: 0.93))
                    }
                    .font(.system(size: 13, weight: .regular))
                    .padding(.vertical, 4)
                }
            }
            
            Divider()
                .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                .padding(.vertical, 16)
        }
    }
    
    private func imageSection(image: UIImage) -> some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .cornerRadius(12)
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: 4,
                    x: 0,
                    y: 2
                )
                .padding(.vertical, 16)
            
            Divider()
                .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                .padding(.bottom, 16)
        }
    }
    
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Folder section
            folderView
            
            // Tags section (if there are tags)
            if !note.tags.isEmpty {
                tagListView
            }
        }
        .padding(.top, 32)
    }
    
    private var folderView: some View {
        VStack(alignment: .leading, spacing: 4) {
            if isEditing {
                Text("Folder")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
                
                TextField("Enter folder", text: $note.folder)
                    .font(.system(size: 16, weight: .regular))
                    .padding(4)
                    .background(Color(red: 0.96, green: 0.96, blue: 0.97))
                    .cornerRadius(4)
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "folder")
                        .foregroundColor(Color(red: 0.0, green: 0.52, blue: 0.93))
                    
                    Text(note.folder)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(Color(red: 0.0, green: 0.52, blue: 0.93))
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color(red: 0.0, green: 0.52, blue: 0.93).opacity(0.1))
                .cornerRadius(4)
            }
        }
        .padding(.bottom, 8)
    }
    
    private var tagListView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
            
            FlowLayout(spacing: 6) {
                ForEach(note.tags, id: \.self) { tag in
                    tagView(tag: tag)
                }
            }
        }
    }
    
    private func tagView(tag: String) -> some View {
        HStack(spacing: 2) {
            Circle()
                .fill(tagColor(for: tag))
                .frame(width: 8, height: 8)
            
            Text(tag)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(red: 0.96, green: 0.96, blue: 0.97))
        .cornerRadius(8)
    }
    
    // MARK: - Helper Methods
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func tagColor(for tag: String) -> Color {
        let colors: [Color] = [
            Color(red: 0.0, green: 0.52, blue: 0.93),     // Power Blue
            Color(red: 0.2, green: 0.6, blue: 0.86),      // Light Blue
            Color(red: 0.4, green: 0.68, blue: 0.8),      // Sky Blue
            Color(red: 0.0, green: 0.7, blue: 0.7),       // Teal
            Color(red: 0.0, green: 0.6, blue: 0.5),       // Green-Blue
            Color(red: 0.3, green: 0.5, blue: 0.8),       // Indigo
            Color(red: 0.5, green: 0.4, blue: 0.9)        // Purple
        ]
        let index = abs(tag.hashValue) % colors.count
        return colors[index]
    }
}

// MARK: - Flow Layout for Tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let containerWidth = proposal.width ?? .infinity
        
        var totalHeight: CGFloat = 0
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for view in subviews {
            let viewSize = view.sizeThatFits(.unspecified)
            
            if lineWidth + viewSize.width > containerWidth {
                // Start a new line
                totalHeight += lineHeight + spacing
                lineWidth = viewSize.width
                lineHeight = viewSize.height
            } else {
                // Continue on current line
                lineWidth += viewSize.width + spacing
                lineHeight = max(lineHeight, viewSize.height)
            }
        }
        
        // Add the final line height
        totalHeight += lineHeight
        
        return CGSize(width: containerWidth, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let containerWidth = bounds.width
        
        var lineX = bounds.minX
        var lineY = bounds.minY
        var lineHeight: CGFloat = 0
        
        for view in subviews {
            let viewSize = view.sizeThatFits(.unspecified)
            
            if lineX + viewSize.width > containerWidth + bounds.minX {
                // Start a new line
                lineX = bounds.minX
                lineY += lineHeight + spacing
                lineHeight = 0
            }
            
            // Place the view
            view.place(at: CGPoint(x: lineX, y: lineY), proposal: .unspecified)
            
            // Update position and line height
            lineX += viewSize.width + spacing
            lineHeight = max(lineHeight, viewSize.height)
        }
    }
}
