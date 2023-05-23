//
//  GroceryListTableViewController.swift
//  Fridge_IO
//
//  Created by Hong Yi on 23/5/2023.
//

import UIKit

class GroceryListTableViewController: UITableViewController {
    
    let SECTION_LIST = 0
    let SECTION_INFO = 1
    let CELL_LIST = "listCell"
    let CELL_INFO = "infoCell"
    
    var groceryList: [String] = []
    var currentIndex: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
            return groceryList.count
        case SECTION_INFO:
            return 1
        default:
            return 0
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_LIST {
            let listCell = tableView.dequeueReusableCell(withIdentifier: CELL_LIST, for: indexPath) as! GroceryListTableViewCell
            let listValue = groceryList[indexPath.row]
            
            listCell.listTextField.tag = indexPath.row
            listCell.listTextField.text = listValue
            
            if indexPath.row == groceryList.count - 1 {
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
    
    @IBAction func addListEntry(_ sender: Any) {
        groceryList.append("")
        tableView.reloadData()
    }
    
    @IBAction func finishedEditing(_ sender: Any) {
        let sender = sender as! UITextField
        let index = NSIndexPath(row: sender.tag, section: SECTION_LIST)
        
        if let cell = tableView.cellForRow(at: index as IndexPath) as? GroceryListTableViewCell {
            if let textField = cell.listTextField {
                groceryList[index.row] = textField.text ?? ""
            }
        }
    }
    
    @IBAction func testing(_ sender: Any) {
        print("Is this what i want?")
    }
    
    @IBAction func onEnter(_ sender: Any) {
        groceryList.append("")
        tableView.reloadData()
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
