//
//  HomePageTableViewController.swift
//  Fridge_IO
//
//  Created by Hong Yi on 26/4/2023.
//

import UIKit

class HomePageTableViewController: UITableViewController, UISearchBarDelegate, UITableViewDragDelegate, DatabaseListener {
    
    weak var databaseController: DatabaseProtocol?
    
    let CELL_GROCERY = "groceryCell"
    
    var listenerType = ListenerType.groceries
    var allGroceries: [Grocery] = []
    var filteredGroceries: [Grocery] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.dragDelegate = self
        tableView.dragInteractionEnabled = true
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.scopeBarActivation = .onSearchActivation
        searchController.searchBar.scopeButtonTitles = ["All", "Dairy", "Veggies", "Meat", "Nuts", "Liquids"]
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        filteredGroceries = allGroceries
    }
    
    //Search bar functions
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
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredGroceries = allGroceries
        searchBar.selectedScopeButtonIndex = 0
        tableView.reloadData()
    }
    
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
    
    //Setup listeners
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func onGroceriesChange(change: DatabaseChange, groceries: [Grocery]) {
        allGroceries = groceries
        filteredGroceries = allGroceries
        tableView.reloadData()
    }
    
    //Log out
    @IBAction func logout(_ sender: Any) {
        let alertController = UIAlertController(title: "Log Out", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.databaseController?.logout()
            self.performSegue(withIdentifier: "logoutIdentifier", sender: self)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //Rearange the groceries
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragGrocery = UIDragItem(itemProvider: NSItemProvider())
        dragGrocery.localObject = filteredGroceries[indexPath.row]
        
        return [dragGrocery]
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if filteredGroceries.isEmpty {
            return 1
        } else {
            return filteredGroceries.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let groceryCell = tableView.dequeueReusableCell(withIdentifier: CELL_GROCERY, for: indexPath)
        
        var content = groceryCell.defaultContentConfiguration()
        
        if filteredGroceries.isEmpty {
            content.text = "Groceries not found. Tap + to add some"
            content.secondaryText = ""
        } else {
            let grocery = filteredGroceries[indexPath.row]

            if let name = grocery.name, let amount = grocery.amount, let date = grocery.expiry {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy"
                
                content.text = "\(name) x\(amount)"
                content.secondaryText = "Expiry Date: \(dateFormatter.string(from: date))"
            }
        }
        
        groceryCell.contentConfiguration = content
        return groceryCell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let grocery = filteredGroceries[indexPath.row]
            databaseController?.deleteGrocery(grocery: grocery)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "editIdentifier", sender: indexPath)
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let grocery = filteredGroceries[fromIndexPath.row]
        filteredGroceries.remove(at: fromIndexPath.row)
        filteredGroceries.insert(grocery, at: to.row)
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    
    //Useless
    func onAuthChange(success: Bool, message: String?) {
        //Do nothing
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editIdentifier" {
            let sender = sender as! IndexPath
            let destination = segue.destination as! EditGroceryViewController
            
            destination.grocery = filteredGroceries[sender.row]
            navigationItem.backButtonTitle = "Back"
        }
    }

}
