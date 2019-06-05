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
    
    func update(title: String, bodyText: String, entry: Entry, mood: Mood){
        entry.title = title
        entry.bodyText = bodyText
        entry.mood = mood.rawValue
        entry.timestamp = Date()
        
        put(entry: entry)
        saveToPersistentStore()
    }
    
    func delete(entry: Entry){
        let moc = CoreDataStack.shared.mainContext
        // 1. Delete from CoreData
        deleteEntryFromServer(entry: entry) { (_) in
            moc.delete(entry)
        }
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
    
}
