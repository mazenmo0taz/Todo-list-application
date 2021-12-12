//
//  CategoryViewController.swift
//  ToDo-LIST
//
//  Created by mazen moataz on 30/10/2021.
//

import UIKit
import RealmSwift
import ChameleonFramework
class CategoryViewController: SwipeTableViewController{
    let realm = try! Realm()
    var categsRes: Results<Categs>?
    var textField:UITextField?
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor(hexString: "00A7FA")

    }
    //MARK: - Tableview cells init
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categsRes?.count ?? 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView,cellForRowAt: indexPath)
        cell.backgroundColor = UIColor(hexString: categsRes?[indexPath.row].colorHex ?? "00A7FA" )
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(hexString: "00A7FA")
        cell.selectedBackgroundView = bgColorView
        cell.textLabel?.text = categsRes?[indexPath.row].name ?? "No Categories Added yet"
       
        cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn:cell.backgroundColor!, isFlat:true)
        return cell
    }
    
    @IBAction func addBtnPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add new category", message: nil, preferredStyle: .alert)
        
        alert.addTextField { UITextField in
            UITextField.placeholder = "Write your category name"
            self.textField = UITextField
        }
        let action = UIAlertAction(title: "Add category", style: .default) { action in
            let NewCateg = Categs()
            if (self.textField?.text?.isEmpty == true) {
                NewCateg.name = "New category"
            }else{
                NewCateg.name = self.textField?.text! ?? "New category"
            }
            NewCateg.colorHex = UIColor.randomFlat().hexValue()
            self.save(category: NewCateg)
            
        }
        let canelAction = UIAlertAction(title: "Cancel", style: .destructive) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        alert.addAction(canelAction)
        present(alert, animated: true, completion: nil)
       
    }
    
    //MARK: -Tableview Delegates
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems" {
            let itemsVC = segue.destination as! ViewController
            if let indexPath = tableView.indexPathForSelectedRow{
                itemsVC.selectedCateg = categsRes?[indexPath.row]
            }
        }
        
    }
    
    //MARK: -DATA FETCHING
    func save(category: Categs){
        do{
            try realm.write{
                realm.add(category)
            }
        }catch{
            print("error while saving categories \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadData() {
        categsRes = realm.objects(Categs.self)
        self.tableView.reloadData()
    }
    override func deleteCell(indexpath: IndexPath) {
        if let categForDeletion = categsRes?[indexpath.row]{
            do{
                try realm.write{
                    realm.delete(categForDeletion)
                }
            }catch{
                print(error,"error while deleting item")
            }
        }
    }
}
