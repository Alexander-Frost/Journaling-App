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
    
    init() {
        fetchEntriesFromServer()
    }
    
    let baseURL = URL(string: "https://coredata-283af.firebaseio.com/")!

    
//    var entries: [Entry] { // allows us to instantly get an Entry from Persistent Store
//        return loadFromPersistentStore()
//    }
    
    func saveToPersistentStore(){
        let moc = CoreDataStack.shared.mainContext
        
        do {
            try moc.save() // save to persistent store
        } catch let error {
            print("Error saving moc: \(error)")
        }
    }
    
//    func loadFromPersistentStore() -> [Entry] {
//        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
//
//        let moc = CoreDataStack.shared.mainContext
//
//        do {
//            return try moc.fetch(fetchRequest)
//        } catch let error {
//            NSLog("Error fetching tasks: \(error)")
//            return []
//        }
//    }
    
    // MARK: - CRUD
    
    func create(title: String, bodyText: String, mood: Mood) {
        let entry = Entry(title: title, bodyText: bodyText, mood: mood)
        put(entry: entry)
        saveToPersistentStore()
    }
    
    func updateOld(title: String, bodyText: String, entry: Entry, mood: Mood){
        entry.title = title
        entry.bodyText = bodyText
        entry.mood = mood.rawValue
        entry.timestamp = Date()

        put(entry: entry)
        saveToPersistentStore()
    }
    
    func update(entry: Entry, entryRepresentation: EntryRepresentation){
        entry.title = entryRepresentation.title
        entry.bodyText = entryRepresentation.bodyText
        entry.mood = entryRepresentation.mood
        entry.identifier = entryRepresentation.identifier
    }
    
    func delete(entry: Entry){
        CoreDataStack.shared.mainContext.delete(entry)
        // 1. Delete from CoreData
        deleteEntryFromServer(entry: entry)
        // 2. Save deletion
        saveToPersistentStore()
        
    }
    
    typealias CompletionHandler = (Error?) -> Void

    func put(entry: Entry, completion: @escaping CompletionHandler = { _ in}) {
        let uuid = entry.identifier ?? UUID().uuidString
        entry.identifier = uuid
        
        let requestUrl = baseURL.appendingPathComponent(uuid).appendingPathExtension("json")
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "PUT"
        
        do {
            guard let representation = entry.entryRepresentation else { throw NSError()}
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            NSLog("Error encoding task: \(error)")
            return completion(error)
        }
        
        URLSession.shared.dataTask(with: request) {(_, _, error) in
            if let error = error {
                NSLog("Error PUTting task to server: \(error)")
                completion(error)
                return
            }
            completion(nil)
            } .resume()
    }
    
    func deleteEntryFromServer(entry: Entry, completion: @escaping CompletionHandler = { _ in}) {
        let identifier = entry.identifier ?? UUID().uuidString
        
        let url = baseURL.appendingPathComponent(identifier).appendingPathExtension("json")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                NSLog("Error sending deletion request to server: \(error.localizedDescription)")
                return completion(nil)
            }
            completion(nil)
            } .resume()
    }
    
    func fetchSingleEntryFromPersistentStore(identifier: String, context: NSManagedObjectContext) -> Entry? {
        // 1. create fetch request from Entry
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
        
        var result: Entry?
        
        do {
            result = try context.fetch(fetchRequest).first
        } catch let fetchError {
            print("Error fetching single entry: \(fetchError.localizedDescription)")
        }
        return result
    }
    
    func fetchEntriesFromServer(completion: @escaping CompletionHandler = { _ in}){
        let requestURL = baseURL.appendingPathExtension("json")
        let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
        
        URLSession.shared.dataTask(with: requestURL)  { (data, _, error) in
            if let error = error {
                NSLog("Error fetching entries: \(error)")
                return
            }
            
            guard let data = data else {
                NSLog("No data returned by data task")
                return completion(NSError())
            }
            
            backgroundContext.performAndWait {
                do {
                    let entryRepresentationDict = try JSONDecoder().decode([String: EntryRepresentation].self, from: data)
                    let entryRepresentation = Array(entryRepresentationDict.values)
                    
                    for entryRep in entryRepresentation {
                        let uuid = entryRep.identifier
                        
                        if let entry = self.fetchSingleEntryFromPersistentStore(identifier: entryRep.identifier, context: backgroundContext) { // if we already have a local Entry for this then update it
                            self.update(entry: entry, entryRepresentation: entryRep)
                        } else {
                            // create a new Entry in CoreData
                            let _ = Entry(entryRepresentation: entryRep)
                        }
                    }
                    
                    // save changes to disk
                    try CoreDataStack.shared.save(context: backgroundContext)
                } catch {
                    NSLog("Error decoding tasks: \(error)")
                    return completion(error)
                }
                completion(nil)
            }
        }
    }
    
}
