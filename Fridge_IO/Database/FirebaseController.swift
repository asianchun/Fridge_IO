//
//  FirebaseController.swift
//  Fridge_IO
//
//  Created by Hong Yi on 25/4/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class FirebaseController: NSObject, DatabaseProtocol {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    
    //Variables
    var authController: Auth
    var database: Firestore
    var currentUser: FirebaseAuth.User?
    var groceriesRef: CollectionReference?
    var groceryListsRef: CollectionReference?
    var usersRef: CollectionReference?
    var groceries: [Grocery]
    var groceryLists: [GroceryList]
    
    //Listeners that store the Firebase snapshotListeners
    var groceryListener: ListenerRegistration?
    var groceryListListener: ListenerRegistration?
    var userListener: ListenerRegistration?
    
    override init() {
        FirebaseApp.configure()
        
        //Initialising firebase auth & firestore
        authController = Auth.auth()
        database = Firestore.firestore()
        
        groceries = [Grocery]()
        groceryLists = [GroceryList]()
        
        usersRef = database.collection("users")

        super.init()
    }
    
    // MARK: - Listener functions
    
    //Adding a listener
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .groceries {
            listener.onGroceriesChange(change: .update, groceries: groceries)
        }
        
        if listener.listenerType == .groceryLists {
            listener.onGroceryListsChange(change: .update, groceryLists: groceryLists)
        }
    }
    
    //Remove a listener
    func removeListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
    }
    
    // MARK: - Authentication functions
    
    //Login
    func login(email: String, password: String) {
        Task {
            do {
                let authResult = try await authController.signIn(withEmail: email, password: password)
                currentUser = authResult.user
                
                setupUsersListener()
                
                //Tell the login screen that the login was successful
                listeners.invoke { (listener) in
                    if listener.listenerType == .auth {
                        listener.onAuthChange(success: true, message: nil)
                    }
                }
            } catch {
                //Tell the login screen that the login was unsuccessful with the error message
                listeners.invoke { (listener) in
                    if listener.listenerType == .auth {
                        listener.onAuthChange(success: false, message: String(describing: error.localizedDescription))
                    }
                }
            }
        }
    }
    
    //Signup
    func signup(email: String, password: String) {
        Task {
            do {
                let authResult = try await authController.createUser(withEmail: email, password: password)
                currentUser = authResult.user
                
                let user = User()
                user.userID = currentUser?.uid
                
                do {
                    if let userRef = try usersRef?.addDocument(from: user) {
                        user.id = userRef.documentID
                        setupUsersListener()
                    }
                } catch {
                    print("Failed to serialize the grocery")
                }
                
                
                //Tell the signup screen that the signup was successful
                listeners.invoke { (listener) in
                    if listener.listenerType == .auth {
                        listener.onAuthChange(success: true, message: nil)
                    }
                }
            } catch {
                //Tell the login screen that the login was unsuccessful with the error message
                listeners.invoke { (listener) in
                    if listener.listenerType == .auth {
                        listener.onAuthChange(success: false, message: String(describing: error.localizedDescription))
                    }
                }
            }
        }
    }
    
    //Logout
    func logout() {
        do {
            try authController.signOut()
            groceries.removeAll()
            groceryLists.removeAll()
        } catch {
            print("Error: \(error)")
        }
    }
    
    //Reset password
    func resetPassword(email: String) {
        authController.sendPasswordReset(withEmail: email)
    }
    
    //Delete user
    func deleteUser(completion: @escaping () -> Void) {
        let userID = currentUser?.uid ?? ""
        
        //Clear all user data from the database
        usersRef?.whereField("userID", isEqualTo: userID).getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    // Document found, delete it
                    let documentID = document.documentID
                    self.usersRef?.document(documentID).delete() { error in
                        if let error = error {
                            print("Error deleting document: \(error)")
                        } else {
                            print("Document successfully deleted")
                        }
                    }
                }
            }
        }
        
        //Delete the user from the database
        currentUser?.delete { error in
            if let error = error {
              print(error)
            } else {
                completion()
            }
        }
    }
    
    // MARK: - Users functions
    
    func setupUsersListener() {
        userListener?.remove() //Reset the listener after every login / signup / app reset

        userListener = (usersRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            
            self.parseUsersSnaphot(snapshot: querySnapshot)
        })!
        
    }
    
    func parseUsersSnaphot(snapshot: QuerySnapshot) {
        print("operation 1")
        snapshot.documentChanges.forEach { (change) in
            var parsedUser: User?
            
            do {
                parsedUser = try change.document.data(as: User.self)
            } catch {
                print("Unable to decode grocery. Is the hero malformed?")
                return
            }
            
            guard let user = parsedUser else {
                print("Document doesn't exist")
                return
            }
            
            //Setup the user's grocery and grocery list collections
            if user.userID == currentUser?.uid {
                print("Made it here")
                groceriesRef = database.collection("users/\(user.id!)/groceries")
                groceryListsRef = database.collection("users/\(user.id!)/groceryLists")
                
                setupGroceryListener()
            }
        }
    }
    
    // MARK: - Grocery functions
    
    //Add grocery
    func addGrocery(name: String, type: GroceryType, expiry: Date, amount: String) -> Grocery {
        let grocery = Grocery()
        grocery.name = name
        grocery.type = type.rawValue
        grocery.expiry = expiry
        grocery.amount = amount
        grocery.order = groceries.count
        
        do {
            if let groceryRef = try groceriesRef?.addDocument(from: grocery) {
                grocery.id = groceryRef.documentID
            }
        } catch {
            print("Failed to serialize the grocery")
        }
        
        return grocery
    }
    
    //Edit grocery
    func editGrocery(grocery: Grocery, name: String, type: GroceryType, expiry: Date, amount: String) {
        if let groceryID = grocery.id {
            groceriesRef?.document(groceryID).updateData([
                "name": name,
                "type": type.rawValue,
                "expiry": expiry,
                "amount": amount
            ])
        }
    }
    
    //Edit the order of the groceries (important for saving the state afrer rearranging groceries)
    func editGroceryOrder(grocery: Grocery, newOrder: Int) {
        if let groceryID = grocery.id {
            groceriesRef?.document(groceryID).updateData([
                "order": newOrder
            ])
        }
    }
    
    //Delete grocery
    func deleteGrocery(grocery: Grocery) {
        if let groceryID = grocery.id {
            groceriesRef?.document(groceryID).delete()
        }
    }
    
    //Setup the grocery snapshot listener
    func setupGroceryListener() {
        print("operation 2")
        groceryListener?.remove() //Reset the listener after every login / signup / app reset

        groceryListener = (groceriesRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseGroceriesSnapshot(snapshot: querySnapshot)
        })!
        
        setupGroceryListListener()
    }
    
    //Convert the snapshot into grocery class used accross the whole application
    func parseGroceriesSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (change) in
            var parsedGrocery: Grocery?
            
            do {
                parsedGrocery = try change.document.data(as: Grocery.self)
            } catch {
                print("Unable to decode grocery. Is the hero malformed?")
                return
            }
            
            guard let grocery = parsedGrocery else {
                print("Document doesn't exist")
                return
            }
            
            removeNotificationOn(grocery) //Reset the notification creation to remove duplication
            
            if change.type == .added {
                groceries.append(grocery)
                requestNotificationsOn(grocery) //Create the notification for the grocery
            } else if change.type == .modified {
                groceries[grocery.order!] = grocery
                requestNotificationsOn(grocery)
            } else if change.type == .removed {
                groceries.remove(at: Int(change.oldIndex))
            }
        }
        
        //Sort the groceries by order
        groceries.sort {
            $0.order! < $1.order!
        }
        
        //Send the updates to the relevant viewController
        listeners.invoke { (listener) in
            if listener.listenerType == .groceries {
                listener.onGroceriesChange(change: .update, groceries: groceries)
            }
        }
    }
    
    // MARK: - Grocery List functions
    
    //Add grocery list
    func addGroceryList(name: String, listItems: [String]) -> GroceryList {
        let groceryList = GroceryList()
        groceryList.name = name
        groceryList.listItems = listItems
        
        do {
            if let groceryListRef = try groceryListsRef?.addDocument(from: groceryList) {
                groceryList.id = groceryListRef.documentID
            }
        } catch {
            print("Failed to serialize hero")
        }
        
        return groceryList
    }
    
    //Edit grocery list
    func editGroceryList(groceryList: GroceryList, listItems: [String]) {
        if let listID = groceryList.id {
            groceryListsRef?.document(listID).updateData([
                "listItems": listItems
            ])
        }
    }
    
    //Delete grocery list
    func deleteGroceryList(groceryList: GroceryList) {
        if let listID = groceryList.id {
            groceryListsRef?.document(listID).delete()
        }
    }
    
    //Setup the grocery list snapshot listener
    func setupGroceryListListener() {
        groceryListListener?.remove() //Reset the listener after every login / signup / app reset

        groceryListListener = (groceryListsRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            
            self.parseGroceryListsSnapshot(snapshot: querySnapshot)
        })!
    }
    
    //Convert the snapshot into grocery list class used accross the whole application
    func parseGroceryListsSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (change) in
            var parsedGroceryList: GroceryList?
            
            do {
                parsedGroceryList = try change.document.data(as: GroceryList.self)
            } catch {
                print("Unable to decode grocery. Is the hero malformed?")
                return
            }
            
            guard let groceryList = parsedGroceryList else {
                print("Document doesn't exist")
                return
            }
            
            if change.type == .added {
                groceryLists.append(groceryList)
            } else if change.type == .modified {
                for (index, list) in groceryLists.enumerated() {
                    if list.name == groceryList.name {
                        groceryLists[index] = groceryList
                    }
                }
            } else if change.type == .removed {
                groceryLists.remove(at: Int(change.oldIndex))
            }
        }
        
        //Send the updates to the relevant viewController
        listeners.invoke { (listener) in
            if listener.listenerType == .groceryLists {
                listener.onGroceryListsChange(change: .update, groceryLists: groceryLists)
            }
        }
    }
    
    // MARK: - Notifcation setup
    
    //Create notification
    func requestNotificationsOn(_ grocery: Grocery) {
        // Create a notification content object
        let notificationContent = UNMutableNotificationContent()

        // Create its details
        notificationContent.title = "Fridge_IO"
        notificationContent.subtitle = "Your \(grocery.name ?? "") is about to expire! Cook it now!"
        
        //Create the trigger
        let date = Calendar.current.date(byAdding: .day, value: -1, to: grocery.expiry!)
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date!)
        dateComponents.hour = 10
        dateComponents.minute = 20
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        // Create our request
        let request = UNNotificationRequest(identifier: grocery.id!,
             content: notificationContent, trigger: trigger)

        //Add the notification to the centre
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    //Remove notification
    func removeNotificationOn(_ grocery: Grocery) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [grocery.id!])
    }
}
