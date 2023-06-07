//
//  EditGroceryViewController.swift
//  Fridge_IO
//
//  Created by Hong Yi on 10/5/2023.
//

import UIKit

class EditGroceryViewController: UIViewController {
    
    var grocery: Grocery?
    var type: GroceryType?

    @IBOutlet weak var dateControl: UIDatePicker!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeControl: UIButton!
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPopup()

        navigationItem.title = "Edit \(grocery?.name ?? "")"
        nameTextField.text = grocery?.name ?? ""
        amountTextField.text = grocery?.amount ?? ""
        //typeSegmentedControl.selectedSegmentIndex = grocery?.type ?? 0
        dateControl.date = grocery?.expiry ?? Date()
        dateControl.minimumDate = Date()
        
        dateControl.semanticContentAttribute = .forceRightToLeft
        dateControl.subviews.first?.semanticContentAttribute = .forceRightToLeft
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.cornerRadius = 5
        nameTextField.layer.borderColor = UIColor(named: "buttons")?.cgColor
        
        amountTextField.layer.borderWidth = 1
        amountTextField.layer.cornerRadius = 5
        amountTextField.layer.borderColor = UIColor(named: "buttons")?.cgColor
    }
    
    @IBAction func save(_ sender: Any) {
        guard let name = nameTextField.text, let amount = amountTextField.text, let type = type else {
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
            createAction("Dairy", handler: optionClosure),
            createAction("Fruits & Veggies", handler: optionClosure),
            createAction("Meat", handler: optionClosure),
            createAction("Seafood", handler: optionClosure),
            createAction("Condiments", handler: optionClosure),
            createAction("Other", handler: optionClosure)
        ])
        
        typeControl.showsMenuAsPrimaryAction = true
        typeControl.changesSelectionAsPrimaryAction = true
    }
    
    func createAction(_ name: String, handler: @escaping UIActionHandler) -> UIAction {
        let action = UIAction(title: name, handler: handler)
        var tempType = GroceryType(rawValue: 0)
        
        switch name {
        case "Dairy":
             tempType = GroceryType(rawValue: 0)
        case "Fruits & Veggies":
            tempType = GroceryType(rawValue: 1)
        case "Meat":
            tempType = GroceryType(rawValue: 2)
        case "Seafood":
            tempType = GroceryType(rawValue: 3)
        case "Condiments":
            tempType = GroceryType(rawValue: 4)
        case "Other":
            tempType = GroceryType(rawValue: 5)
        default:
            print("Error")
        }
        
        if tempType == GroceryType(rawValue: grocery?.type ?? 0) {
            action.state = .on
        }
        
        return action
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
