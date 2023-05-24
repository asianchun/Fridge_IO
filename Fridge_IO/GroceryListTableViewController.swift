//
//  GroceryListTableViewController.swift
//  Fridge_IO
//
//  Created by Hong Yi on 23/5/2023.
//

import UIKit

class GroceryListTableViewController: UITableViewController {
    
    weak var databaseController: DatabaseProtocol?
    
    let SECTION_LIST = 0
    let SECTION_INFO = 1
    let CELL_LIST = "listCell"
    let CELL_INFO = "infoCell"
    
    var groceryList: GroceryList?
    var currentIndex: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = groceryList?.name
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    @IBAction func addListEntry(_ sender: Any) {
        groceryList?.listItems!.append("")
        tableView.reloadData()
    }
    
    @IBAction func beginEditing(_ sender: Any) {
        let sender = sender as! UITextField
        currentIndex = NSIndexPath(row: sender.tag, section: SECTION_LIST)
    }
    
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
    
    @IBAction func onEnter(_ sender: Any) {
        groceryList?.listItems!.append("")
        tableView.reloadData()
    }
    
    @IBAction func handleTap(recognizer: UITapGestureRecognizer) {
        if let cell = tableView.cellForRow(at: currentIndex! as IndexPath) as? GroceryListTableViewCell {
            if let textField = cell.listTextField {
                textField.resignFirstResponder()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case SECTION_LIST:
            return (groceryList?.listItems!.count)!
        case SECTION_INFO:
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
            
            listCell.listTextField.tag = indexPath.row
            listCell.listTextField.text = listValue
            
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
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.section == SECTION_LIST {
            return true
        } else {
            return false
        }
    }
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
