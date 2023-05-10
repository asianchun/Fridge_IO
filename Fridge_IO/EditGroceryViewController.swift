//
//  EditGroceryViewController.swift
//  Fridge_IO
//
//  Created by Hong Yi on 10/5/2023.
//

import UIKit

class EditGroceryViewController: UIViewController {
    
    var grocery: Grocery?

    @IBOutlet weak var dateControl: UIDatePicker!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var nameTextField: UITextField!
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Edit \(grocery?.name ?? "")"
        nameTextField.text = grocery?.name ?? ""
        amountTextField.text = grocery?.amount ?? ""
        typeSegmentedControl.selectedSegmentIndex = grocery?.type ?? 0
        dateControl.date = grocery?.expiry ?? Date()
        dateControl.minimumDate = Date()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    @IBAction func save(_ sender: Any) {
        guard let name = nameTextField.text, let amount = amountTextField.text, let type = GroceryType(rawValue: Int(typeSegmentedControl.selectedSegmentIndex)) else {
            return
        }
        
        let date = dateControl.date
        
        if name.isEmpty || amount.isEmpty {
            var errorMsg = "Please ensure all fields are filled : \n"
            
            if name.isEmpty {
                errorMsg += "- Must provide a name \n"
            }
            if amount.isEmpty {
                errorMsg += "- Must provide an amount \n"
            }
            
            displayMessage(title: "Not all fields filled", message: errorMsg)
            return
        }
        
        databaseController?.editGrocery(grocery: grocery!, name: name, type: type, expiry: date, amount: amount)
        navigationController?.popViewController(animated: true)
    }
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message,
        preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
        handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
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
