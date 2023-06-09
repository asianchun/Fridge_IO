//
//  GroceryListTableViewController.swift
//  Fridge_IO
//
//  Created by Hong Yi on 23/5/2023.
//

import UIKit

class GroceryListTableViewController: UITableViewController {
    
    //Link to the database
    weak var databaseController: DatabaseProtocol?
    
    //Constants
    let SECTION_LIST = 0
    let SECTION_INFO = 1
    let CELL_LIST = "listCell"
    let CELL_INFO = "infoCell"
    
    //Other variables
    var groceryList: GroceryList?
    var currentIndex: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = groceryList?.name
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    // MARK: - Functions
    
    //Add new grocery list entry on + press
    @IBAction func addListEntry(_ sender: Any) {
        groceryList?.listItems!.append("")
        tableView.reloadData()
    }
    
    //Function to store the current entry that is being edited
    @IBAction func beginEditing(_ sender: Any) {
        let sender = sender as! UITextField
        currentIndex = NSIndexPath(row: sender.tag, section: SECTION_LIST)
    }
    
    //Save the entry inside the grocery list, when the editing is completed
    @IBAction func finishedEditing(_ sender: Any) {
        let sender = sender as! UITextField
        let index = NSIndexPath(row: sender.tag, section: SECTION_LIST)
        
        if let cell = tableView.cellForRow(at: index as IndexPath) as? GroceryListTableViewCell {
            if let textField = cell.listTextField {
                groceryList?.listItems![index.row] = textField.text ?? ""
            }
        }
        
        databaseController?.editGroceryList(groceryList: groceryList!, listItems: (groceryList?.listItems!)!)
    }
    
    //Add new grocery list entry on enter
    @IBAction func onEnter(_ sender: Any) {
        groceryList?.listItems!.append("")
        tableView.reloadData()
    }
    
    // MARK: - Tap Gesture
    
    //Deselect current entry when pressing on the empty area
    //Here is where we need the current entry retrieved from beginEditing()
    @IBAction func handleTap(recognizer: UITapGestureRecognizer) {
        if let cell = tableView.cellForRow(at: currentIndex! as IndexPath) as? GroceryListTableViewCell {
            if let textField = cell.listTextField {
                textField.resignFirstResponder()
            }
        }
    }

    // MARK: - Table view setup

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_LIST:
            return (groceryList?.listItems!.count)!
        case SECTION_INFO: //Don't show the second section if there are entries
            if groceryList?.listItems!.isEmpty ?? true {
                return 1
            } else {
                return 0
            }
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_LIST {
            let listCell = tableView.dequeueReusableCell(withIdentifier: CELL_LIST, for: indexPath) as! GroceryListTableViewCell
            let listValue = groceryList?.listItems![indexPath.row]
            
            //This is a custom cell -> GroceryListTableViewCell
            listCell.listTextField.tag = indexPath.row
            listCell.listTextField.text = listValue
            
            //Automatically select and start editing the last / the newly created entry
            if indexPath.row == (groceryList?.listItems!.count)! - 1 {
                listCell.listTextField.becomeFirstResponder()
            }

            return listCell
        } else {
            let infoCell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath)
            
            var content = infoCell.defaultContentConfiguration()
            content.text = "Tap + to add items to the grocery list"
            
            infoCell.contentConfiguration = content
            
            return infoCell
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == SECTION_LIST {
            return true
        } else {
            return false
        }
    }
    
    //Change the colour and icon of the swipe to delete action
    //https://stackoverflow.com/questions/26337310/change-colour-of-swipe-to-delete-background-in-swift
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let acceptAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            tableView.reloadData()
            self.groceryList?.listItems!.remove(at: indexPath.row)
            
            tableView.reloadData()
            completionHandler(true)
        }
        
        acceptAction.image = UIImage(systemName: "checkmark")
        acceptAction.backgroundColor = .systemGreen
        
        let configuration = UISwipeActionsConfiguration(actions: [acceptAction])
        return configuration
    }
}
