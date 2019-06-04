//
//  EntriesTableViewController.swift
//  New Journal
//
//  Created by Alex on 6/4/19.
//  Copyright © 2019 Alex. All rights reserved.
//

import UIKit

class EntriesTableViewController: UITableViewController {
    
    
    let entryController = EntryController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return entryController.entries.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntryCell", for: indexPath) as! EntryTableViewCell
        
        cell.entry = entryController.entries[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            entryController.delete(entry: entryController.entries[indexPath.row])
            tableView.reloadData()
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "View Entry Segue" {
            guard let myVC = segue.destination as? EntryDetailViewController else {return}
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            
            myVC.entryController = entryController
            myVC.entry = entryController.entries[indexPath.row]
        } else if segue.identifier == "Create Entry Segue" {
            guard let myVC = segue.destination as? EntryDetailViewController else {return}
            myVC.entryController = entryController
            
        }
    }
  

}
