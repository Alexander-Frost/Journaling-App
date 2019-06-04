//
//  EntryTableViewCell.swift
//  New Journal
//
//  Created by Alex on 6/4/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import UIKit

class EntryTableViewCell: UITableViewCell {

    var entry: Entry? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet var timestampLbl: UILabel!
    @IBOutlet var bodyLbl: UILabel!
    @IBOutlet var titleLbl: UILabel!
    

    func updateViews(){
        guard let entry = entry else {return}
        print("HERE ENtry, ", entry)
        titleLbl.text = entry.title
        bodyLbl.text = entry.bodyText
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy h:mm a"
        
        timestampLbl.text = dateFormatter.string(from: entry.timestamp ?? Date())
    }
}
