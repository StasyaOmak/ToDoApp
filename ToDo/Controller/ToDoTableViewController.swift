//
//  ToDoTableViewController.swift
//  ToDo
//
//  Created by Anastasiya Omak on 31/10/2023.
//

import UIKit
import CoreData

class ToDoTableViewController: UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext?
    var toDoLists = [ToDo]()
    private var cellID = "toDoCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        managedObjectContext = appDelegate.persistentContainer.viewContext
        loadCoreData()
        setupView()
    }
    
    @objc func addNewItem(){
        print("clicked")
        let alertController = UIAlertController(title: "To Do List", message: "Do you want to add new item?", preferredStyle: .alert)
        alertController.addTextField { textFieldValue in
            textFieldValue.placeholder = "Your title here..."
            print(textFieldValue)
        }
        
        
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
    
    @objc func addDeleteItem() {
        print("clicked")
        let alertController = UIAlertController(title: "Delete All Data", message: "Do you want to delete your list?", preferredStyle: .actionSheet)

        let deleteActionButton = UIAlertAction(title: "Delete", style: .default) { deleteAction in
            self.deleteAllItems()
        }

        let cancelActionButton = UIAlertAction(title: "Cancel", style: .destructive)

        alertController.addAction(deleteActionButton)
        alertController.addAction(cancelActionButton)

        present(alertController, animated: true)
    }

    func deleteAllItems() {
        for toDo in toDoLists {
            managedObjectContext?.delete(toDo)
        }
        saveCoreData()
    }

    
    
    @objc func longPress(sender: UILongPressGestureRecognizer){
        if sender.state == UIGestureRecognizer.State.began {
            let touchPath = sender.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPath){
                print(indexPath)
                basicActionSheet(title: toDoLists[indexPath.row].item, message: "Completed: \(toDoLists[indexPath.row].completed)")
            }
        }
    }
    
    private func setupView() {
        
        view.backgroundColor = .secondarySystemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewItem))
        
        self.navigationItem.rightBarButtonItem  = addBarButtonItem
        
        let deleteImage = UIImage(systemName: "trash") 
        let deleteBarButtonItem = UIBarButtonItem(image: deleteImage, style: .done, target: self, action: #selector(addDeleteItem))
        
        self.navigationItem.leftBarButtonItem  = deleteBarButtonItem
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        view.addGestureRecognizer(longPressRecognizer)
        
        setupNavigationBarView()
    }
    
    private func setupNavigationBarView() {
        title = "To Do"
        
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.label]
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .label
    }
    
}

extension UITableView {
    func setEmptyView(title: String, message: String) {
        
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.textColor = UIColor.label
        titleLabel.font = UIFont(name: "Futura-Bold", size: 18)
        
        messageLabel.textColor = UIColor.secondaryLabel
        messageLabel.font = UIFont(name: "Kefa", size: 16)
        
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 0).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: emptyView.trailingAnchor, constant: 0).isActive = true
        
        titleLabel.text = title
        messageLabel.text = message
        
        messageLabel.numberOfLines = 2
        messageLabel.textAlignment = .center
        
        self.backgroundView = emptyView
        
    }
    
    func restoreTableViewStyle(){
        self.backgroundView = nil
    }
}

// MARK: - CoreData logic
extension ToDoTableViewController {
    func loadCoreData(){
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
    
    func deleteAllCoreData(){
        
    }
    
    func basicActionSheet(title: String?, message: String?) {
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        actionSheet.overrideUserInterfaceStyle = .dark
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true)
    }
    
}

// MARK: - Table view data source
extension ToDoTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if toDoLists.count == 0 {
            tableView.setEmptyView(title: "Your To Do is Empty", message: "Please press Add to create a new to do item")
        } else {
            tableView.restoreTableViewStyle()
        }
        
        return toDoLists.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let toDoList = toDoLists[indexPath.row]
        cell.textLabel?.text = toDoList.item
        cell.accessoryType = toDoList.completed ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        toDoLists[indexPath.row].completed = !toDoLists[indexPath.row].completed
        saveCoreData()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            managedObjectContext?.delete(toDoLists[indexPath.row])
        }
        saveCoreData()
    }
}
