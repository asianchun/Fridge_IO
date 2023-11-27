//
//  SignUpScreenViewController.swift
//  Fridge_IO
//
//  Created by Hong Yi on 21/4/2023.
//

import UIKit

class SignUpScreenViewController: UIViewController, DatabaseListener {

    //Link to the database
    weak var databaseController: DatabaseProtocol?
    
    //Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var confirmEmailTextField: UITextField!
   
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    //Other variables
    var listenerType = ListenerType.auth
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        //UI changes
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.cornerRadius = 5
        emailTextField.layer.borderColor = UIColor(named: "buttons")?.cgColor
        
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.cornerRadius = 5
        passwordTextField.layer.borderColor = UIColor(named: "buttons")?.cgColor
        
        confirmEmailTextField.layer.borderWidth = 1
        confirmEmailTextField.layer.cornerRadius = 5
        confirmEmailTextField.layer.borderColor = UIColor(named: "buttons")?.cgColor
        
        confirmPasswordTextField.layer.borderWidth = 1
        confirmPasswordTextField.layer.cornerRadius = 5
        confirmPasswordTextField.layer.borderColor = UIColor(named: "buttons")?.cgColor
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //Listens to the results of signup
    func onAuthChange(success: Bool, message: String?) {
        DispatchQueue.main.async {
            if success {
                self.performSegue(withIdentifier: "signupIdentifier", sender: self)
            } else {
                self.displayMessage(title: "Error", message: message!)
            }
        }
    }
    
    // MARK: - Tap Gesture
    
    //Deselect current entry when pressing on the empty area
    @IBAction func handleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    
    // MARK: - Functions
    
    //Sign Up
    @IBAction func signup(_ sender: Any) {
        let (emailIsValid, email, password) = validateFields()
        
        if !emailIsValid {
            return
        }
        
        databaseController?.signup(email: email, password: password)
    }
    
    //Return the user to the login screen
    @IBAction func cancelBtn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    //Validation of the input fields
    func validateFields() -> (Bool, String, String) {
        guard let email = emailTextField.text, !email.isEmpty else {
            displayMessage(title: "Error", message: "Enter an email address!")
            return (false, "", "")
        }
        
        guard let confirmEmail = confirmEmailTextField.text, confirmEmail == email else {
            displayMessage(title: "Error", message: "Emails do not match!")
            return (false, "", "")
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            displayMessage(title: "Error", message: "Enter a password!")
            return (false, "", "")
        }
        
        guard let confirmPassword = confirmPasswordTextField.text, confirmPassword == password else {
            displayMessage(title: "Error", message: "Passwords do not match!")
            return (false, "", "")
        }
        
        //Make sure email is in a correct format
        //https://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift
        let emailValidationRegex = "^[\\p{L}0-9!#$%&'*+\\/=?^_`{|}~-][\\p{L}0-9.!#$%&'*+\\/=?^_`{|}~-]{0,63}@[\\p{L}0-9-]+(?:\\.[\\p{L}0-9-]{2,7})*$"
        
        let emailValidationPredicate = NSPredicate(format: "SELF MATCHES %@", emailValidationRegex)
        
        if emailValidationPredicate.evaluate(with: email) {
            return (true, email, password)
        } else {
            displayMessage(title: "Error", message: "Enter a valid email address!")
            return (false, "", "")
        }
    }
    
    //Display various messages
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message,
        preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
        handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //Do the login after pressing enter
    @IBAction func onEnter(_ sender: Any) {
        if let textField = sender as? UITextField {
            if textField == emailTextField {
                confirmEmailTextField.becomeFirstResponder()
            } else if textField == confirmEmailTextField {
                passwordTextField.becomeFirstResponder()
            } else if textField == passwordTextField {
                confirmPasswordTextField.becomeFirstResponder()
            } else if textField == confirmPasswordTextField {
                let (emailIsValid, email, password) = validateFields()
                
                if !emailIsValid {
                    return
                }
                
                databaseController?.signup(email: email, password: password)
            }
        }
    }
    
    @IBAction func onChangeResponder(_ sender: Any) {
        if let textField = sender as? UITextField {
            if textField == emailTextField {
                scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            } else if textField == confirmEmailTextField {
                scrollView.setContentOffset(CGPoint(x: 0, y: 50), animated: true)
            } else if textField == passwordTextField {
                scrollView.setContentOffset(CGPoint(x: 0, y: 100), animated: true)
            } else if textField == confirmPasswordTextField {
                scrollView.setContentOffset(CGPoint(x: 0, y: 150), animated: true)
            }
        }
    }
    
    // MARK: - Useless functions for this Controller
    
    func onGroceriesChange(change: DatabaseChange, groceries: [Grocery]) {
        //Do nothing
    }
    
    func onGroceryListsChange(change: DatabaseChange, groceryLists: [GroceryList]) {
        //Do nothing
    }
}
