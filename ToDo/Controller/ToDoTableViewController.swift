//
//  ToDoTableViewController.swift
//  ToDo
//
//  Created by Anastasiya Omak on 31/10/2023.
//

import UIKit
import CoreData





class ToDoTableViewController: UITableViewController {
    
    var smileyArray = ["🦒", "🐒", "🌴", "🦦", "🐡", "🧜🏽", "🦔", "🦀", "🐋", "🐙", "🦙", "🦘"]
    
    var managedObjectContext: NSManagedObjectContext?
    
    var toDoLists = [ToDo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        managedObjectContext = appDelegate.persistentContainer.viewContext
        loadCoreData()
       
        
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
        
    }

    @IBAction func addNewItemTapped(_ sender: Any) {
        
        let alertController = UIAlertController(title: "To Do List", message: "Do you want to add a  new item?", preferredStyle: .alert)
        alertController.addTextField { textFieldValue in
            textFieldValue.placeholder = "Your title here..."
            print(textFieldValue)
        }
        
#warning("message/subtitle")
        
        let addActionButton = UIAlertAction(title: "Add", style: .default) { addActions in
            let textField = alertController.textFields?.first
            
            let entity = NSEntityDescription.entity(forEntityName: "ToDo", in: self.managedObjectContext!)
            let list = NSManagedObject(entity: entity!, insertInto: self.managedObjectContext)
            
            list.setValue(textField?.text, forKey: "item")
            self.saveCoreData()
        }
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .destructive)
        
        alertController.addAction(addActionButton)
        alertController.addAction(cancelActionButton)
        
        present(alertController, animated: true)
    }
    
    
#warning("delete All CoreData")
    
    @IBAction func deleteAllItemsTapped(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Delete All Data", message: "Do you want to delete your list?", preferredStyle: .actionSheet)
        
        let deleteActionButton = UIAlertAction(title: "Delete", style: .default) { deleteAction in
            self.deleteAllCoreData()
            self.saveCoreData()
        }
        
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .destructive)
        
        alertController.addAction(deleteActionButton)
        alertController.addAction(cancelActionButton)
        
        present(alertController, animated: true)
    }
    
    
}

// MARK: - CoreData logic
extension ToDoTableViewController {
    
    func loadCoreData() {
        let request: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        
        do {
            let result = try managedObjectContext?.fetch(request)
            toDoLists = result ?? []
            self.tableView.reloadData()
        } catch {
            fatalError("Error in loading item into core data")
        }
    }
    
    func saveCoreData(){
        do {
            try managedObjectContext?.save()
        } catch {
            fatalError("Error in saving item into core data")
        }
        loadCoreData()
    }
    
    func saveToDoListArrayFull() {
        for name in toDoLists {
            let entity = NSEntityDescription.entity(forEntityName: "ToDo", in: self.managedObjectContext!)
            let list = NSManagedObject(entity: entity!, insertInto: self.managedObjectContext)
            
            list.setValue(name.item, forKey: "item")
            saveCoreData()
        }
    }
    
    
    func deleteAllCoreData() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDo")
        
        let entityRequest: NSBatchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedObjectContext?.execute(entityRequest)

        } catch let error {
            print(error.localizedDescription)
            fatalError("Error in saving item inot ToDo")
        }
    }
}

// MARK: - Table view data source
extension ToDoTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return toDoLists.count
    }
    
    // MARK: - smileyArray
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "toDoCell", for: indexPath)
        let toDoList = toDoLists[indexPath.row]
        
        let currentSmileyIndex = indexPath.row % smileyArray.count
        let currentSmiley = smileyArray[currentSmileyIndex]
        
        cell.textLabel?.text = "\(currentSmiley) \(toDoList.item ?? "")"
        
        return cell
    }
    
    // MARK: - Moved cells
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let movedTask = smileyArray.remove(at: sourceIndexPath.row)
        
        smileyArray.insert(movedTask, at: destinationIndexPath.row)
        
        let movedToDoListsTask = toDoLists.remove(at: sourceIndexPath.row)
        toDoLists.insert(movedToDoListsTask, at: destinationIndexPath.row)
        
        deleteAllCoreData()
        saveToDoListArrayFull() //
        
    }
    
    // MARK: - clicking on a cell (tableView.allowsSelectionDuringEditing = true)
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        toDoLists[indexPath.row].completed = !toDoLists[indexPath.row].completed
        saveCoreData()
    }
    
    
    
    // MARK: - Deleting line by line (tableView.isEditing = true)
    
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
    
                managedObjectContext?.delete(toDoLists[indexPath.row])
            }
            saveCoreData()
        }
    
    
}

