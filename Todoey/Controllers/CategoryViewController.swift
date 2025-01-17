//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Ayanesh Sarkar on 04/02/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
        // tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
        
        let uiTintColour = UIColor(hexString: "1D9BF6")
        
        navBar.backgroundColor = uiTintColour
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(uiTintColour!, returnFlat: true)]
    }
    
    // MARK: - Table View Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = categories?[indexPath.row]
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = category?.name ?? "No Categories added yet."
        cell.backgroundColor = UIColor(hexString: category?.colour ?? "1D9BF6")
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
                
        return cell
    }
    
    // MARK: - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    // MARK: - Data Manupulation Methods
    func save(category: Category) {
        try! realm.write { realm.add(category) }
        tableView.reloadData()
    }
    
    func delete(category: Category) {
        try! realm.write() {
            realm.delete(category)
        }
        tableView.reloadData()
    }
    
    func loadCategories() {
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    // MARK: - Delete data from Swipe
    override func updateModel(at indexPath: IndexPath) {
        if let category = categories?[indexPath.row] {
            delete(category: category)
        }
    }
    

    // MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { action in
            // What will happen once the user presses the Add Item button on out UIAlert
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.colour = UIColor.randomFlat().hexValue()
            
            self.save(category: newCategory)
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new Category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Search Bar Delegate Methods
extension CategoryViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        categories = categories?.where {
            $0.name.contains(searchBar.text!, options: [.caseInsensitive, .diacriticInsensitive])
        }
        
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadCategories()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
