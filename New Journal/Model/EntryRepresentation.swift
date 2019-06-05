//
//  EntryRepresentation.swift
//  New Journal
//
//  Created by Alex on 6/5/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import Foundation

struct EntryRepresentation: Codable, Equatable {
    
    // this needs to exactly match our Firebase data
    var title: String
    var bodyText: String
    var identifier: String
    var mood: String
    var timestamp: Date
}

// we need to make sure our Firebase data matches our CoreData data

func == (lhs: EntryRepresentation, rhs: Entry) -> Bool {
    return lhs.title == rhs.title && lhs.bodyText == rhs.bodyText && lhs.mood == rhs.mood && lhs.timestamp == rhs.timestamp && lhs.identifier == rhs.identifier
}

func == (lhs: Entry, rhs: EntryRepresentation) -> Bool {
    return lhs == rhs
}

func != (lhs: EntryRepresentation, rhs: Entry) -> Bool {
    return !(rhs == lhs)
}

func != (lhs: Entry, rhs: EntryRepresentation) -> Bool {
    return rhs != lhs
}


