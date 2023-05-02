//
//  HomePageTableViewController.swift
//  Fridge_IO
//
//  Created by Hong Yi on 26/4/2023.
//

import UIKit

class HomePageTableViewController: UITableViewController, DatabaseListener {
    
    weak var databaseController: DatabaseProtocol?
    
    let CELL_GROCERY = "groceryCell"
    
    var listenerType = ListenerType.groceries
    var allGroceries: [Grocery] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allGroceries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let groceryCell = tableView.dequeueReusableCell(withIdentifier: CELL_GROCERY, for: indexPath)
        
        var content = groceryCell.defaultContentConfiguration()
        
        if allGroceries.isEmpty {
            content.text = "No Groceries added. Tap + to add some"
            content.secondaryText = ""
        } else {
            let grocery = allGroceries[indexPath.row]

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
            let grocery = allGroceries[indexPath.row]
            databaseController?.deleteGrocery(grocery: grocery)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Open the next page (use code from articles api thing
    }
    
    //Useless
    func onAuthChange(success: Bool, message: String?) {
        //Do nothing
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
