//
//  AllGroceryListsTableViewController.swift
//  Fridge_IO
//
//  Created by Hong Yi on 23/5/2023.
//

import UIKit

class AllGroceryListsTableViewController: UITableViewController, DatabaseListener {
    
    //Link to the database
    weak var databaseController: DatabaseProtocol?
    
    //Outlets
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    //Constants
    let CELL_LIST = "listCell"
    let ABOUT = "About Fridge.IO"
    let DELETE_ACCOUNT = "Delete Account"
    let LOGOUT = "Log Out"
    
    //Other variables
    var allLists: [GroceryList] = []
    var listenerType = ListenerType.groceryLists
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSettings() //Setup settings
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    // MARK: - Listener functions
    
    //Setup listener
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    //Remove listener
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    //Listens to the changes to the grocery lists in the database and updates this controller and the view accordingly
    func onGroceryListsChange(change: DatabaseChange, groceryLists: [GroceryList]) {
        allLists = groceryLists
        tableView.reloadData()
    }

    // MARK: - Functions
    
    //Add grocery list to the database
    @IBAction func addGroceryList(_ sender: Any) {
        displayMessage(title: "New Grocery List", message: "Enter a name for the grocery list")
    }
    
    //Display message to create a new grocery list
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
            
            //Check if the list with that name exists
            for list in self.allLists {
                if list.name == groceryListName {
                    self.displayError(title: "Error", message: "Grocery list already exists")
                    return
                }
            }
            
            let _ = self.databaseController?.addGroceryList(name: groceryListName, listItems: [String]())
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //Display error message
    func displayError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }

    //Settings
    //https://www.youtube.com/watch?v=4yZR6AC1PIU
    func setupSettings() {
        let optionClosure = {(action: UIAction) in
            switch action.title {
            case self.ABOUT:
                self.performSegue(withIdentifier: "aboutIdentifier", sender: nil)
            case self.LOGOUT:
                let alertController = UIAlertController(title: "Log Out", message: "Are you sure you want to logout?", preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                    self.databaseController?.logout()
                    self.performSegue(withIdentifier: "logoutIdentifier", sender: self)
                }))
                
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                
                self.present(alertController, animated: true, completion: nil)
            case self.DELETE_ACCOUNT:
                let alertController = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account?", preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                    self.databaseController?.deleteUser(completion: {
                        self.databaseController?.logout()
                        self.performSegue(withIdentifier: "logoutIdentifier", sender: self)
                    })
                }))
                
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                
                self.present(alertController, animated: true, completion: nil)
            default:
                print("Error")
            }
        }
        
        settingsButton.menu = UIMenu(children: [
            UIAction(title: LOGOUT, handler: optionClosure),
            UIAction(title: ABOUT, handler: optionClosure),
            UIAction(title: DELETE_ACCOUNT, handler: optionClosure),
        ])
    }
    
    // MARK: - Table view data setup

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
        
        //The cell is not selectable when there are no grocery lists
        if allLists.isEmpty {
            cell.selectionStyle = .none
            tableView.allowsSelection = false
            
            content.text = "Tap + to add grocery lists"
        } else {
            cell.selectionStyle = .default
            tableView.allowsSelection = true
            
            let groceryList = allLists[indexPath.row]
            content.text = groceryList.name
        }
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(named: "selected")
        cell.selectedBackgroundView = backgroundView
        
        cell.contentConfiguration = content
        return cell
    }
    
    //Open the specific grocery list when pressed
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "groceryListIdentifier", sender: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let groceryList = allLists[indexPath.row]
            allLists.remove(at: indexPath.row)
            databaseController?.deleteGroceryList(groceryList: groceryList)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.backButtonTitle = "Back"
        
        if segue.identifier == "groceryListIdentifier" {
            let sender = sender as! IndexPath
            let destination = segue.destination as! GroceryListTableViewController
            
            destination.groceryList = allLists[sender.row]
        }
    }

    // MARK: - Useless functions for this Controller
    
    func onAuthChange(success: Bool, message: String?) {
        //Do nothing
    }
    
    func onGroceriesChange(change: DatabaseChange, groceries: [Grocery]) {
        //Do nothing
    }
}
