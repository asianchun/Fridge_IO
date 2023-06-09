//
//  HomePageTableViewController.swift
//  Fridge_IO
//
//  Created by Hong Yi on 26/4/2023.
//

import UIKit

class GroceryPageTableViewController: UITableViewController, UISearchBarDelegate, DatabaseListener {
    
    //Link to database
    weak var databaseController: DatabaseProtocol?
    
    //Outlets
    @IBOutlet weak var editBtn: UIBarButtonItem!
    @IBOutlet weak var settingsBtn: UIBarButtonItem!
    
    //Constants
    let CELL_GROCERY = "groceryCell"
    let ABOUT = "About Fridge.IO"
    let LOGOUT = "Log Out"
    
    //Other variables
    var listenerType = ListenerType.groceries
    var allGroceries: [Grocery] = []
    var filteredGroceries: [Grocery] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSettings() //Setup settings

        //Setup the search bar
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.scopeBarActivation = .onSearchActivation
        searchController.searchBar.scopeButtonTitles = ["All", "Dairy", "F&V", "Meat", "Sea", "Cond", "Other"]
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        filteredGroceries = allGroceries
    }
    
    //MARK: - Search bar functions
    
    //Finish Editing (on enter press)
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
        }
        
        let search = searchText.lowercased()
        
        filteredGroceries = allGroceries.filter({ (grocery: Grocery) -> Bool in
            let name = grocery.name?.lowercased()
            return (name?.contains(search) ?? false)
        })
        
        searchBar.selectedScopeButtonIndex = 0
        tableView.reloadData()
    }
    
    //Cancel search -> reset to show all groceries again
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredGroceries = allGroceries
        searchBar.selectedScopeButtonIndex = 0
        tableView.reloadData()
    }
    
    //Filter groceries based on the selected segment control option
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if selectedScope != 0 {
            filteredGroceries = allGroceries.filter({ (grocery: Grocery) -> Bool in
                let scope = selectedScope - 1
                return grocery.type == scope
            })
        } else {
            filteredGroceries = allGroceries
        }
        
        searchBar.text = ""
        tableView.reloadData()
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
    
    //Listens to the changes of groceries in database and update the UI accordingly
    func onGroceriesChange(change: DatabaseChange, groceries: [Grocery]) {
        allGroceries = groceries
        filteredGroceries = allGroceries
        tableView.reloadData()
    }
    
    // MARK: - Functions
    
    //Settings
    //https://www.youtube.com/watch?v=4yZR6AC1PIU
    func setupSettings() {
        let optionClosure = {(action: UIAction) in
            switch action.title {
            case self.ABOUT: //Open the about page
                self.performSegue(withIdentifier: "aboutIdentifier", sender: nil)
            case self.LOGOUT: //Logout the user and send back to the login screen
                let alertController = UIAlertController(title: "Log Out", message: "Are you sure you want to logout?", preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                    self.databaseController?.logout()
                    self.performSegue(withIdentifier: "logoutIdentifier", sender: self)
                }))
                
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                
                self.present(alertController, animated: true, completion: nil)
            default:
                print("Error")
            }
        }
        
        settingsBtn.menu = UIMenu(children: [
            UIAction(title: ABOUT, handler: optionClosure),
            UIAction(title: LOGOUT, handler: optionClosure),
        ])
    }
    
    //Rearange the groceries
    @IBAction func editGroceries(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
        
        if tableView.isEditing {
            editBtn.title = "Save"
        } else {
            editBtn.title = "Edit"
        }
    }
    
    // MARK: - Table view setup

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredGroceries.isEmpty {
            return 1
        } else {
            return filteredGroceries.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let groceryCell = tableView.dequeueReusableCell(withIdentifier: CELL_GROCERY, for: indexPath)
        
        var content = groceryCell.defaultContentConfiguration()
        
        //The cell is not selectable when there are no groceries
        if filteredGroceries.isEmpty {
            groceryCell.selectionStyle = .none
            tableView.allowsSelection = false
            
            content.text = "Groceries not found. Tap + to add some"
        } else {
            groceryCell.selectionStyle = .default
            tableView.allowsSelection = true
            
            let grocery = filteredGroceries[indexPath.row]

            if let name = grocery.name, let amount = grocery.amount, let date = grocery.expiry {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy"
                
                content.text = "\(name) x\(amount)"
                
                let datesEqual = Calendar.current.isDate(date, equalTo: Date(), toGranularity: .day)
                
                //Different UI based on whether the grocery is expired or not
                if datesEqual {
                    content.secondaryText = "Expiry Date: \(dateFormatter.string(from: date)) -> EXPIRES TODAY"
                } else if date < Date() {
                    content.secondaryText = "Expiry Date: \(dateFormatter.string(from: date)) -> EXPIRED"
                } else {
                    content.secondaryText = "Expiry Date: \(dateFormatter.string(from: date))"
                }
            }
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor(named: "selected")
            groceryCell.selectedBackgroundView = backgroundView
        }
        
        groceryCell.contentConfiguration = content
        return groceryCell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if filteredGroceries.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let grocery = filteredGroceries[indexPath.row]
            filteredGroceries.remove(at: indexPath.row)
            databaseController?.deleteGrocery(grocery: grocery)
            
            //Reapply the new order of the groceries
            for (index, filteredGrocery) in filteredGroceries.enumerated() {
                databaseController?.editGroceryOrder(grocery: filteredGrocery, newOrder: index)
            }
        }
    }
    
    //Edit the grocery by pressing on it
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "editIdentifier", sender: indexPath)
        searchController.searchBar.selectedScopeButtonIndex = 0
    }
    
    //Rearranging the table view cells
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let grocery = filteredGroceries[fromIndexPath.row]
        filteredGroceries.remove(at: fromIndexPath.row)
        filteredGroceries.insert(grocery, at: to.row)
        
        //Save the new order of the groceries
        for (index, filteredGrocery) in filteredGroceries.enumerated() {
            databaseController?.editGroceryOrder(grocery: filteredGrocery, newOrder: index)
        }
        
        tableView.reloadData()
    }

    //Allow the rearranging of the table view
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    
    // MARK: - Useless functions for this Controller
    
    func onAuthChange(success: Bool, message: String?) {
        //Do nothing
    }
    
    func onGroceryListsChange(change: DatabaseChange, groceryLists: [GroceryList]) {
        //Do nothing
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        navigationItem.backButtonTitle = "Back"
        
        if segue.identifier == "editIdentifier" {
            let sender = sender as! IndexPath
            let destination = segue.destination as! EditGroceryViewController
            
            //Pass the selected grocery
            destination.grocery = filteredGroceries[sender.row]
        }
    }

}
