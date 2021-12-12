//
//  ViewController.swift
//  ToDo-LIST
//
//  Created by mazen moataz on 14/10/2021.
//

import UIKit
import RealmSwift
class ViewController: SwipeTableViewController{
    let realm = try! Realm()
    var selectedCateg: Categs? {
        didSet{
            loadData()
            tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if selectedCateg?.name != "New category"{
            title = selectedCateg?.name
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor(hexString: selectedCateg?.colorHex ?? "00A7FA")
        navigationController?.navigationBar.tintColor = UIColor(contrastingBlackOrWhiteColorOn:UIColor(hexString: selectedCateg?.colorHex ?? "00A7FA")!, isFlat:true)
//        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor(contrastingBlackOrWhiteColorOn:UIColor(hexString: selectedCateg?.colorHex ?? "00A7FA")!, isFlat:true)]
    }
    var textField:UITextField?
    var items:Results<Items>?    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView,cellForRowAt: indexPath)
        if let item = items?[indexPath.row]{
            cell.textLabel?.text = item.title ?? "new item"
            cell.accessoryType = item.done ? .checkmark : .none
            if let safeColor = UIColor(hexString: selectedCateg?.colorHex ?? "FFFFFF")?.darken(byPercentage: (CGFloat(indexPath.row)/CGFloat(items!.count))*0.5){
                cell.backgroundColor = safeColor
                cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn:cell.backgroundColor!, isFlat:true)
            }
        }else{
            cell.textLabel?.text = "No items added yet "
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = items?[indexPath.row]{
            do{
                try realm.write{
                    item.done = !item.done
                }
            }catch{
                print("error while updating done prop \(error)")
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
    }
    
    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: " Add new todo item", message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            if let currentCateg = self.selectedCateg{
                do{
                    try! self.realm.write{
                    let item = Items()
                    if self.textField?.text == "" {
                        item.title = "New item"
                    }else{
                        item.title = self.textField?.text  ?? "New item"
                    }
                        item.dateCreated = Date()
                    currentCateg.items.append(item)
                    }
                    self.tableView.reloadData()
                }
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "write your item name"
            self.textField = alertTextField
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    func loadData(){
        items = selectedCateg?.items.sorted(byKeyPath: "dateCreated", ascending: true)
    }
    override func deleteCell(indexpath: IndexPath) {
        if let itemForDeletion = items?[indexpath.row]{
            do{
                try realm.write{
                    realm.delete(itemForDeletion)
                }
            }catch{
                print(error,"error while deleting item")
            }
        }
    }
}

//MARK: - searchbar
extension ViewController : UISearchBarDelegate{
    func searchBarSearchButtonClicked (_ searchBar: UISearchBar){
        items = items?.filter("title CONTAINS[CD] %@" , searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        loadData()
        if searchBar.text?.count == 0 {
            loadData()
            tableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    } 
}

