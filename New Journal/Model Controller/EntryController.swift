//
//  EntryController.swift
//  New Journal
//
//  Created by Alex on 6/4/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import Foundation
import CoreData

class EntryController {
    
    var entries: [Entry] { // allows us to instantly get an Entry from Persistent Store
        return loadFromPersistentStore()
    }
    
    func saveToPersistentStore(){
        let moc = CoreDataStack.shared.mainContext
        
        do {
            try moc.save() // save to persistent store
        } catch let error {
            print("Error saving moc: \(error)")
        }
    }
    
    func loadFromPersistentStore() -> [Entry] {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        
        let moc = CoreDataStack.shared.mainContext
        
        do {
            return try moc.fetch(fetchRequest)
        } catch let error {
            NSLog("Error fetching tasks: \(error)")
            return []
        }
    }
    
    // MARK: - CRUD
    
    func create(title: String, bodyText: String, mood: Mood) {
        let _ = Entry(title: title, bodyText: bodyText, mood: mood)
        saveToPersistentStore()
    }
    
    func update(title: String, bodyText: String, entry: Entry, mood: Mood){
        entry.title = title
        entry.bodyText = bodyText
        entry.mood = mood.rawValue
        entry.timestamp = Date()
        
//        entry.setValue(title, forKey: "title")
//        entry.setValue(bodyText, forKey: "bodyText")
//        entry.setValue(mood, forKey: "mood")
//        entry.setValue(Date(), forKey: "timestamp")
        saveToPersistentStore()
    }
    
    func delete(entry: Entry){
        let moc = CoreDataStack.shared.mainContext
        // 1. Delete from CoreData
        moc.delete(entry)
        // 2. Save deletion
        saveToPersistentStore()
        
    }
}
