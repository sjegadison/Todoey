//
//  ViewController.swift
//  Todoey
//
//  Created by Sivaguru Jegadison on 2/27/19.
//  Copyright © 2019 Sivaguru Jegadison. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
//    var itemArray : [String] = ["First","Second","Second","Second","Second","Second","Second","Second",
//                                "Second","Second","Second","Second","Second","Second","Second",
//                                "Second","Second","Second","Second","Second","Second","Second","Third"]
    let realm = try! Realm()
    
    var todoItems : Results<Item>?
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
        
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
//        loadItems()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectedCategory!.name
        
        if let colour = selectedCategory?.bgColor {
            setupNavBar(withColour: colour)
        }
        


    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setupNavBar(withColour: "1D9Bf6")
    }
    
    // MARK: - Navbar Setup Code
    
    func setupNavBar( withColour colourHex : String) {
    
            guard let navBar = navigationController?.navigationBar else {
                fatalError("Navigation Controller does not exist!!!")
            }
            
            if let navBarColour = UIColor(hexString: colourHex) {
                navBar.barTintColor = navBarColour
                searchBar.barTintColor = navBarColour
                navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
                navBar.largeTitleTextAttributes  = [ NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColour, returnFlat: true) ]
            }
        
        
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print("inside numberOfRowsInSection : \(todoItems?.count ?? 1)")
        return todoItems?.count == 0 ? 0 : todoItems!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print("cellForRowAt")
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if  todoItems?.count == 0 {
            cell.textLabel?.text = "No Items Added Yet"
            cell.accessoryType = .none
        } else
        {
            let item = todoItems![indexPath.row]
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark  : .none

            if let bgColor = selectedCategory?.bgColor {
                let colour = UIColor(hexString: bgColor)
                if let darkencolour = colour!.darken(byPercentage:( CGFloat(indexPath.row) / CGFloat(todoItems!.count))) {
                    cell.backgroundColor = darkencolour
                    cell.textLabel?.textColor = ContrastColorOf(darkencolour, returnFlat: true)
                } else {
                    cell.backgroundColor = colour!
                    cell.textLabel?.textColor = ContrastColorOf(colour!, returnFlat: true)
                }
            } else {
                cell.backgroundColor = UIColor.flatSkyBlue
                cell.textLabel?.textColor = ContrastColorOf(UIColor.flatSkyBlue, returnFlat: true)
            }
            

            
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                        item.done = !item.done
                }
            } catch {
                    print("Error updating Item : \(error)")
                }
            }
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.reloadData()
        
    }
    
    //MARK: - Add New Items
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            // What will happen once user clicks Add Item in UI ALert
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving New Item : \(error)")
                }
            }
            self.tableView.reloadData()
            
            
//            newItem.parentCategory = self.selectedCategory
//            self.todoItems.append(newItem)
//            self.saveItems(item: newItem)

//            self.defaults.set(self.itemArray, forKey: "TodoListArray")
            
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manipulation Methods
    
    func loadItems() {
//        print("inside loaditems")
        todoItems = selectedCategory?.items.sorted(byKeyPath : "title" , ascending: true)
        tableView.reloadData()
    }
    
    override func deleteModel(at indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("Error updating Item : \(error)")
            }
        }
    }
    
}

//MARK: - Search Bar Methods

extension TodoListViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
//        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath : "title" , ascending: true)
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath : "dateCreated" , ascending: false)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    

}

