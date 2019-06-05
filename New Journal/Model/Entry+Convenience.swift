//
//  Entry+Convenience.swift
//  New Journal
//
//  Created by Alex on 6/4/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import Foundation
import CoreData

enum Mood: String {
    case sad = "😞"
    case neutral = "😐"
    case happy = "😊"
    
    static var allMoods: [Mood] {
        return [.sad, .neutral, .happy]
    }
}

extension Entry {
    
    convenience init(title: String, bodyText: String, timestamp: Date = Date(), mood: Mood, identifier: String = UUID().uuidString, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        
        self.title = title
        self.bodyText = bodyText
        self.timestamp = timestamp
        self.identifier = identifier
        self.mood = mood.rawValue
    }
    
    // creates Entry from EntryRepresentation
    convenience init?(entryRepresentation: EntryRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) { // optional bc it may not pull data from Firebase
        guard let mood = Mood(rawValue: entryRepresentation.mood) else {return nil}
        self.init(title: entryRepresentation.title,
            bodyText: entryRepresentation.bodyText,
            timestamp: entryRepresentation.timestamp,
            mood: mood, identifier: entryRepresentation.identifier, context: context)
    }
    
    // converts Entry to EntryRepresentation before going to JSON
    var entryRepresentation: EntryRepresentation? {
        guard let title = title,
            let bodyText = bodyText,
            let identifier = identifier,
            let mood = mood else {return nil}
        
        return EntryRepresentation(title: title, bodyText: bodyText, identifier: identifier, mood: mood, timestamp: timestamp ?? Date())
    }
    
    
}














