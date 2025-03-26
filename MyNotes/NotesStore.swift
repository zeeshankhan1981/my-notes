//
//  NotesStore.swift
//  MyNotes
//
//  Created by Zeeshan Khan on 3/25/25.
//

import Foundation

class NotesStore: ObservableObject {
    @Published var notes: [Note] = []
    let savePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("notes.json")

    init() {
        loadNotes()
    }

    func loadNotes() {
        do {
            let data = try Data(contentsOf: savePath)
            notes = try JSONDecoder().decode([Note].self, from: data)
        } catch {
            notes = []
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
        saveNotes()
    }

    func delete(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
        saveNotes()
    }
}
