//
//  AddGroceriesViewController.swift
//  Fridge_IO
//
//  Created by Hong Yi on 2/5/2023.
//

import UIKit

class AddGroceryViewController: UIViewController {

    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var dateControl: UIDatePicker!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var typeControl: UIButton!
    
    var type: GroceryType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPopup()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        dateControl.minimumDate = Date()
        dateControl.date = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        dateControl.semanticContentAttribute = .forceRightToLeft
        dateControl.subviews.first?.semanticContentAttribute = .forceRightToLeft
        
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.cornerRadius = 5
        nameTextField.layer.borderColor = UIColor(named: "buttons")?.cgColor
        
        amountField.layer.borderWidth = 1
        amountField.layer.cornerRadius = 5
        amountField.layer.borderColor = UIColor(named: "buttons")?.cgColor
        
        type = GroceryType(rawValue: 0)
    }
    
    @IBAction func add(_ sender: Any) {
        guard let name = nameTextField.text, let amount = amountField.text, let type = type else {
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
        
        let _ = databaseController?.addGrocery(name: name, type: type, expiry: date, amount: amount)
        navigationController?.popViewController(animated: true)
    }
    
    func setupPopup() {
        let optionClosure = {(action: UIAction) in
            switch action.title {
            case "Dairy":
                self.type = GroceryType(rawValue: 0)
            case "Fruits & Veggies":
                self.type = GroceryType(rawValue: 1)
            case "Meat":
                self.type = GroceryType(rawValue: 2)
            case "Seafood":
                self.type = GroceryType(rawValue: 3)
            case "Condiments":
                self.type = GroceryType(rawValue: 4)
            case "Other":
                self.type = GroceryType(rawValue: 5)
            default:
                print("Error")
            }
        }
        
        typeControl.menu = UIMenu(children: [
            UIAction(title: "Dairy", state: .on, handler: optionClosure),
            UIAction(title: "Fruits & Veggies", handler: optionClosure),
            UIAction(title: "Meat", handler: optionClosure),
            UIAction(title: "Seafood", handler: optionClosure),
            UIAction(title: "Condiments", handler: optionClosure),
            UIAction(title: "Other", handler: optionClosure),
        ])
        
        typeControl.showsMenuAsPrimaryAction = true
        typeControl.changesSelectionAsPrimaryAction = true
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
