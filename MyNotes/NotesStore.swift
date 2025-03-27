//
//  NotesStore.swift
//  MyNotes
//
//  Created by Zeeshan Khan on 3/25/25.
//

import Foundation

class NotesStore: ObservableObject {
    @Published var notes: [Note] = []
    @Published var tags: [String] = []
    
    let savePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("notes.json")

    init() {
        loadNotes()
    }

    func loadNotes() {
        do {
            let data = try Data(contentsOf: savePath)
            notes = try JSONDecoder().decode([Note].self, from: data)
            updateTags()
        } catch {
            notes = []
            tags = []
        }
    }

    func saveNotes() {
        do {
            let data = try JSONEncoder().encode(notes)
            try data.write(to: savePath)
        } catch {
            print("Failed to save notes.")
        }
    }

    func add(note: Note) {
        notes.insert(note, at: 0)
        updateTags()
        saveNotes()
    }

    func delete(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
        updateTags()
        saveNotes()
    }

    func updateTags() {
        let allTags = notes.flatMap { $0.tags }
        tags = Array(Set(allTags))
    }

    func notesWithTag(_ tag: String) -> [Note] {
        return notes.filter { $0.tags.contains(tag) }
    }

    func addTag(to note: Note, tag: String) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            var updatedNote = notes[index]
            updatedNote.tags.append(tag)
            notes[index] = updatedNote
            updateTags()
            saveNotes()
        }
    }

    func removeTag(from note: Note, tag: String) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            var updatedNote = notes[index]
            updatedNote.tags.removeAll { $0 == tag }
            notes[index] = updatedNote
            updateTags()
            saveNotes()
        }
    }
}
