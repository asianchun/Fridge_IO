//
//  AllGroceryListsTableViewController.swift
//  Fridge_IO
//
//  Created by Hong Yi on 23/5/2023.
//

import UIKit

class AllGroceryListsTableViewController: UITableViewController, DatabaseListener {
    
    weak var databaseController: DatabaseProtocol?
    
    let CELL_LIST = "listCell"
    
    var allLists: [GroceryList] = []
    var listenerType = ListenerType.groceryLists

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    //Setup listeners
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func onGroceryListsChange(change: DatabaseChange, groceryLists: [GroceryList]) {
        allLists = groceryLists
        tableView.reloadData()
    }

    @IBAction func addGroceryList(_ sender: Any) {
        displayMessage(title: "New Grocery List", message: "Enter a name for the grocery list")
    }
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: { textfield in
            textfield.placeholder = "Enter a name..."
        })
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            var groceryListName = alertController.textFields![0].text ?? ""
            
            if groceryListName.isEmpty {
                groceryListName = "Default"
            }
            
            for list in self.allLists {
                if list.name == groceryListName {
                    self.displayError(title: "Error", message: "Grocery list already exists")
                    return
                }
            }
            //let _ = self.databaseController?.addTeam(teamName: teamName)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func displayError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if allLists.isEmpty {
            return 1
        } else {
            return allLists.count
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_LIST, for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        
        if allLists.isEmpty {
            cell.selectionStyle = .none
            tableView.allowsSelection = false
            
            content.text = "Tap + to add grocery lists"
        } else {
            tableView.allowsSelection = true
            
            let groceryList = allLists[indexPath.row]
            content.text = groceryList.name
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "groceryListIdentifier", sender: indexPath)
    }
    

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.backButtonTitle = "Back"
        
        if segue.identifier == "groceryListIdentifier" {
            let sender = sender as! IndexPath
            let destination = segue.destination as! GroceryListTableViewController
            
            destination.groceryList = allLists[sender.row]
        }
    }

    //Useless
    func onAuthChange(success: Bool, message: String?) {
        //Do nothing
    }
    
    func onGroceriesChange(change: DatabaseChange, groceries: [Grocery]) {
        //Do nothing
    }

}
