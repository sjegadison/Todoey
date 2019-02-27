//
//  ViewController.swift
//  Todoey
//
//  Created by Sivaguru Jegadison on 2/27/19.
//  Copyright © 2019 Sivaguru Jegadison. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
//    var itemArray : [String] = ["First","Second","Second","Second","Second","Second","Second","Second",
//                                "Second","Second","Second","Second","Second","Second","Second",
//                                "Second","Second","Second","Second","Second","Second","Second","Third"]
    
    var itemArray = [Item]()
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
//    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        print(dataFilePath!)
//        loadItems()
//        if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
//            itemArray = items
//        }
        
//        var newItem = Item()
//        newItem.title = "First Item"
//        itemArray.append(newItem)
//
//        newItem = Item()
//        newItem.title = "Second Item"
//        itemArray.append(newItem)
//
//        newItem = Item()
//        newItem.title = "Third Item"
//        itemArray.append(newItem)
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
//        loadItems()

    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark  : .none
        return cell
    }
    
    //MARK: - TableView Delegate Method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(itemArray[indexPath.row])
        
//        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
//            tableView.cellForRow(at: indexPath)?.accessoryType = .none
//        } else {
//            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
//        }
        

//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)

        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
        
    }
    
    //MARK: - Add New Items
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // What will happen once user clicks Add Item in UI ALert
            
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            self.saveItems()

//            self.defaults.set(self.itemArray, forKey: "TodoListArray")
            
            self.tableView.reloadData()
            

        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manipulation Methods
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context : \(error)")
        }
    }
    
//    func loadItems() {
//
//            if  let data = try? Data(contentsOf: dataFilePath!) {
//                let decoder = PropertyListDecoder()
//                do {
//                    itemArray = try decoder.decode([Item].self, from: data)
//                } catch {
//                    print("Error decoding Item Array, \(error)")
//                }
//
//            }
//    }
    
    func loadItems(with request : NSFetchRequest<Item> = Item.fetchRequest(), predicate : NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalPredicate])
            request.predicate = compoundPredicate
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error reading data from  context : \(error)")
        }
        tableView.reloadData()
    }
    
}

//MARK: - Search Bar Methods

extension TodoListViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        getSearchData(searchText: searchBar.text!)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            getSearchData(searchText:  searchBar.text!)
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    func getSearchData(searchText : String) {
        
        if searchText.count == 0 {
            loadItems()
        }
        else {
            let request : NSFetchRequest<Item> =  Item.fetchRequest()
            //            let predicate = NSPredicate(format: "title CONTAINS %@", searchBar.text!)
            //            request.predicate = predicate
            let predicate = NSPredicate(format: "title CONTAINS %@", searchText)
            
            //        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
            //        request.sortDescriptors = [sortDescriptor]
            request.sortDescriptors  = [NSSortDescriptor(key: "title", ascending: true)]
            
            loadItems(with: request, predicate : predicate)
            
        }
    }

}

