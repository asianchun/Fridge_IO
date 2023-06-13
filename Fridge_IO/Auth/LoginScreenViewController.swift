//
//  ViewController.swift
//  Fridge_IO
//
//  Created by Hong Yi on 21/4/2023.
//

import UIKit
import FirebaseAuth

class LoginScreenViewController: UIViewController, DatabaseListener {
    
    //Link to the database
    weak var databaseController: DatabaseProtocol?
    
    //Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //Other variables
    var listenerType = ListenerType.auth
    var handle: AuthStateDidChangeListenerHandle? //Listens to changes to Auth state
    
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
    }
    
    // MARK: - Listener functions
    
    //Setup listner
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
        //If user already logged in before, go straight to the next page with the current user details
        handle = Auth.auth().addStateDidChangeListener( { (auth, user) in
            if (user != nil) {
                self.performSegue(withIdentifier: "loginIdentifier", sender: nil)
                self.databaseController?.currentUser = user
                self.databaseController?.setupUsersListener()
            }
        })
    }
    
    //Remove listener
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    //Listens to the results of login
    func onAuthChange(success: Bool, message: String?) {
        DispatchQueue.main.async {
            if success {
                self.performSegue(withIdentifier: "loginIdentifier", sender: self)
            } else {
                self.displayMessage(title: "Error", message: message!)
            }
        }
    }
    
    // MARK: - Functions
    
    //Login
    @IBAction func loginBtn(_ sender: Any) {
        let (emailIsValid, email, password) = validateFields()
        
        if !emailIsValid {
            return
        }
        
        databaseController?.login(email: email, password: password)
    }
    
    //Reset password
    @IBAction func resetPassword(_ sender: Any) {
        let alertController = UIAlertController(title: "Reset password", message: "Enter your email", preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: { textfield in
            textfield.placeholder = "Enter an email..."
        })
        
        //Ask for user email and send reset email
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            guard let email = alertController.textFields![0].text, !email.isEmpty else {
                self.displayMessage(title: "Error", message: "Enter an email")
                return
            }
            
            self.databaseController?.resetPassword(email: email)
            self.displayMessage(title: "Success", message: "A reset link has been sent to your email")
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //Validation of the input fields
    func validateFields() -> (Bool, String, String) {
        guard let email = emailTextField.text, !email.isEmpty else {
            displayMessage(title: "Error", message: "Enter an email address!")
            return (false, "", "")
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            displayMessage(title: "Error", message: "Enter a password!")
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
    
    // MARK: - Useless functions for this Controller
    
    func onGroceriesChange(change: DatabaseChange, groceries: [Grocery]) {
        //Do nothing
    }
    
    func onGroceryListsChange(change: DatabaseChange, groceryLists: [GroceryList]) {
        //Do nothing
    }
}

