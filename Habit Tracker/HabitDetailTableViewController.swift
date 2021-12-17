//
//  HabitDetailTableViewController.swift
//  Habit Tracker
//
//  Created by jimenez on 12/18/21.
//

import UIKit

class HabitDetailTableViewController: UITableViewController {
    
    var habit: Habit!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = habit.name
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return habit.allEntries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath)
        
        // Configure the cell...
        let entry = habit.allEntries[indexPath.row]
        let timestamp = entry.timestamp ?? Date()
        let formattedEntryTimestamp = DateFormatter.localizedString(
            from: timestamp,
            dateStyle: .long,
            timeStyle: .short
        )
        
        cell.textLabel?.text = formattedEntryTimestamp
        
        return cell
    }
    
}
