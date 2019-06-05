//
//  EntryDetailViewController.swift
//  New Journal
//
//  Created by Alex on 6/4/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import UIKit

class EntryDetailViewController: UIViewController {

    var entry: Entry? {
        didSet {
            updateViews()
        }
    }
    var entryController: EntryController?
    
    // MARK: - Outlets
    
    @IBOutlet var entryTextView: UITextView!
    @IBOutlet var textField: UITextField!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    // MARK: - Actions
    
    @IBAction func addEntryBtnPressed(_ sender: UIBarButtonItem) {
        guard let titleText = textField.text else {return}
        guard let bodyText = entryTextView.text else {return}
        let index = segmentedControl.selectedSegmentIndex
        let mood = Mood.allMoods[index]
        
        if let entry = entry {
//            entryController?.update(entry: entry, entryRepresentation: <#T##EntryRepresentation#>)
            
            // not sure if this is the correct one or if we use new update function here, above
            entryController?.updateOld(title: titleText, bodyText: bodyText, entry: entry, mood: mood)
        } else {
            entryController?.create(title: titleText, bodyText: bodyText, mood: mood)
        }
        
        navigationController?.popViewController(animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        // Do any additional setup after loading the view.
    }
    
    func updateViews(){
        guard isViewLoaded else {return}
        guard let entry = entry else {
            title = "New Entry"
            return
        }
        
        textField.text = entry.title
        entryTextView.text = entry.bodyText
        title = entry.title
        
        let mood: Mood
        if let myMood = entry.mood {
            mood = Mood(rawValue: myMood)!
        } else {
            mood = .happy
        }
        
        segmentedControl.selectedSegmentIndex = Mood.allMoods.firstIndex(of: mood)!
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
