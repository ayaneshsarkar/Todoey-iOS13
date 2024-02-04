//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    
    var todoItems: Results<Item>?
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colourHex = selectedCategory?.colour {
            title = selectedCategory!.name
            
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
            
            if let uiBackgroundTintColour = UIColor(hexString: colourHex) {
                navBar.barTintColor = uiBackgroundTintColour
                navBar.backgroundColor = uiBackgroundTintColour
                navBar.tintColor = ContrastColorOf(uiBackgroundTintColour, returnFlat: true)
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(uiBackgroundTintColour, returnFlat: true)]
                
                searchBar.barTintColor = uiBackgroundTintColour
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item: Item? = todoItems?[indexPath.row]
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = item?.title ?? "No Items added yet"
        if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: (CGFloat(indexPath.row) / CGFloat(todoItems!.count))) {
            cell.backgroundColor = colour
            cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
        }
        
        if let safeItem = item {
            cell.accessoryType = safeItem.done ? .checkmark : .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedItem = todoItems?[indexPath.row] {
            updateItemStatus(with: selectedItem)
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK: - Add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            // What will happen once the user presses the Add Item button on out UIAlert
            if let currentCategory = self.selectedCategory {
                let newItem = Item()
                newItem.title = textField.text!
                newItem.done = false
                newItem.dateCreated = Date()
                
                self.save(with: newItem, on: currentCategory)
            }
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Model Manupulation Methods
    func save(with item: Item, on category: Category) {
        try! realm.write { category.items.append(item) }
        tableView.reloadData()
    }
    
    func updateItemStatus(with item: Item) {
        try! realm.write { item.done = !item.done }
        tableView.reloadData()
    }
    
    func delete(with item: Item) {
        try! realm.write { realm.delete(item) }
        tableView.reloadData()
    }
    
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    // MARK: - Delete data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            delete(with: item)
        }
    }
}

// MARK: - Search bar methods
extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.where {
            $0.title.contains(searchBar.text!, options: [.caseInsensitive, .diacriticInsensitive])
        }.sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
