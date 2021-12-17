//
//  HabitTableViewController.swift
//  Habit Tracker
//
//  Created by jimenez on 12/16/21.
//

import UIKit

// display the detail screen from the actionsheet //MARK: COMPLETED
// - create a new viewcontroller in the storyboard, change the type tot HabitDetailTableViewController //MARK: COMPLETED
// - setup a manual segue from the home VC to the detail VC //MARK: COMPLETED
// set the `habit` property of this viewcontroller to the selected habit from the table view //MARK: COMPLETED
// regitser the cell with the name "entryCell" //MARK: COMPLETED

// Finish the trends tab

extension Habit {
    var allEntries: [Entry] {
        return entries?.allObjects as! [Entry]
    }
}

extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
}

protocol HabitTableViewCellDelegate {
    func habitTableViewCell(_ cell: HabitTableViewCell, didToggle switch: UISwitch)
}

class HabitTableViewCell: UITableViewCell {
    var delegate: HabitTableViewCellDelegate?
    @IBOutlet weak var completionSwitch: UISwitch!
    
    @IBAction func didToggleSwitch() {
        delegate?.habitTableViewCell(self, didToggle: completionSwitch)
    }
}

class HabitTableViewController: UITableViewController, HabitTableViewCellDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var models = [Habit]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Habit Tracker"
        getAllItems()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
    }
    
    @objc private func didTapAdd() {
        let alert = UIAlertController(title: "New Item", message: "Enter new item", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel, handler: { [weak self] _ in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {
                return
            }
            self?.createItem(name: text)
        }))
        
        present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "show habit detail screen":
            // get the selected habit from the index path ( which is the `sender` param)
            let indexPath = sender as! IndexPath
            
            // set the destination's habit proeprty to the selectred habit
            let destinationVC = segue.destination as! HabitDetailTableViewController
                        
            let selectedHabit = models[indexPath.row]
            destinationVC.habit = selectedHabit
        default: break
        }
    }
    
    //The amount of cells that are being shown
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return models.count
    }
    
    //What the Cell is being displayed
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! HabitTableViewCell
        cell.textLabel?.text = model.name
        let doesModelContainAnEntryThatWasCompletedToday = model.allEntries.contains(where: { entry in
            return entry.timestamp?.isToday ?? false
        })
        cell.completionSwitch.isOn = doesModelContainAnEntryThatWasCompletedToday
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = models[indexPath.row]
        
        
        let sheet = UIAlertController(title: "Edit", message: nil, preferredStyle: .actionSheet)
        
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            
            let alert = UIAlertController(title: "Edit Item", message: "Edit your item", preferredStyle: .alert)
            
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item.name
            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: { [weak self] _ in
                guard let field = alert.textFields?.first, let newName = field.text, !newName.isEmpty else {
                    return
                }
                self?.updateItem(item: item, newName: newName)
            }))
            
            self.present(alert, animated: true)
            
        }))
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self]  _ in
            self?.deleteItem(item: item)
        }))
        sheet.addAction(UIAlertAction(title: "View History", style: .destructive, handler: { [weak self]  _ in
            self?.performSegue(withIdentifier: "show habit detail screen", sender: indexPath)
        }))
        
        present(sheet, animated: true)
        
    }
    
    func userDidFinishAHabit(at indexPath: IndexPath) {
        let completedHabit = models[indexPath.row]
        
        let newItem = Entry(context: context)
        newItem.timestamp = Date()
        
        completedHabit.addToEntries(newItem)
        
        do{
            try context.save()
            //            getAllItems()
        }
        catch {
            
        }
    }
    
    func userDidUnfinishAHabit(at indexPath: IndexPath) {
        let habitToUndo = models[indexPath.row]
        
        let entryIsTodaysDate: (Entry) -> Bool = { entry in
            if entry.timestamp?.isToday ?? false {
                return true
            } else {
                return false
            }
        }
        
        guard let entryToDelete = habitToUndo.allEntries.first(where: entryIsTodaysDate) else {
            return
        }
        
        //        delete the entry from core data using
        context.delete(entryToDelete)
        
        do {
            try context.save()
        }
        catch {
            
        }
    }
    
    //MARK: CORE DATA
    
    func getAllItems() {
        do {
            models = try context.fetch(Habit.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch {
            //error
        }
    }
    
    func createItem(name: String) {
        let newItem = Habit(context: context)
        newItem.name = name
        newItem.createdAt = Date()
        
        do{
            try context.save()
            getAllItems()
        }
        catch {
            
        }
        
    }
    
    func deleteItem(item: Habit) {
        context.delete(item)
        
        do{
            try context.save()
            getAllItems()
        }
        catch {
            
        }
        
    }
    
    func updateItem(item: Habit, newName: String) {
        item.name = newName
        
        do{
            try context.save()
            getAllItems()
        }
        catch {
            
        }
        
    }
    
    func habitTableViewCell(_ cell: HabitTableViewCell, didToggle switch: UISwitch) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let switchDidFlipToOn = `switch`.isOn
        if switchDidFlipToOn {
            userDidFinishAHabit(at: indexPath)
        } else {
            userDidUnfinishAHabit(at: indexPath)
        }
    }
}
