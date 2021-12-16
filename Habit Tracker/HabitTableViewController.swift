//
//  HabitTableViewController.swift
//  Habit Tracker
//
//  Created by jimenez on 12/16/21.
//

import UIKit

extension Habit {
    var allEntries: [Entry] {
        return entries?.allObjects as! [Entry]
    }
}

class HabitTableViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var models = [Habit]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Habit Tracker"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
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
    
    //The amount of cells that are being shown
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return models.count
    }
    
    //What the Cell is being displayed
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
        cell.textLabel?.text = model.name
//        cell.commpletsionSwitch.isOn =
//        cell.delegate = self
        
        // Configure the cell...
        
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
            //        search for the entry that is from today
            if false {
                return true
            }
            
            return false
        }
        
        guard let entryToDelete = habitToUndo.allEntries.first(where: entryIsTodaysDate) else {
            return
        }
        
//        delete the entry from core data using context.delete(<#T##object: NSManagedObject##NSManagedObject#>)
        
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
    
}
