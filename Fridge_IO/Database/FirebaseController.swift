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
    
    var authController: Auth
    var database: Firestore
    
    var currentUser: FirebaseAuth.User?
    var groceries: [Grocery]?
    
    var groceriesRef: CollectionReference?
    var groceryList: [Grocery]
    
    var listener: ListenerRegistration?
    
    override init() {
        FirebaseApp.configure()
        
        authController = Auth.auth()
        database = Firestore.firestore()
        
        groceryList = [Grocery]()

        super.init()
    }
    
    //Listener functions
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .groceries {
            listener.onGroceriesChange(change: .update, groceries: groceryList)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
    }
    
    //Authentication functions
    func login(email: String, password: String) {
        Task {
            do {
                let authResult = try await authController.signIn(withEmail: email, password: password)
                currentUser = authResult.user
                
                listeners.invoke { (listener) in
                    if listener.listenerType == .auth {
                        listener.onAuthChange(success: true, message: nil)
                    }
                }
                
                self.setupGroceryListener()
            } catch {
                listeners.invoke { (listener) in
                    if listener.listenerType == .auth {
                        listener.onAuthChange(success: false, message: String(describing: error.localizedDescription))
                    }
                }
            }
        }
    }
    
    func signup(email: String, password: String) {
        Task {
            do {
                let authResult = try await authController.createUser(withEmail: email, password: password)
                currentUser = authResult.user
                
                listeners.invoke { (listener) in
                    if listener.listenerType == .auth {
                        listener.onAuthChange(success: true, message: nil)
                    }
                }
                
                self.setupGroceryListener()
            } catch {
                listeners.invoke { (listener) in
                    if listener.listenerType == .auth {
                        listener.onAuthChange(success: false, message: String(describing: error.localizedDescription))
                    }
                }
            }
        }
    }
    
    func logout() {
        do {
            try authController.signOut()
            groceryList.removeAll()
        } catch {
            print("Error: \(error)")
        }
    }
    
    func resetPassword(email: String) {
        authController.sendPasswordReset(withEmail: email)
    }
    
    //Grocery functions
    func addGrocery(name: String, type: GroceryType, expiry: Date, amount: String) -> Grocery {
        let grocery = Grocery()
        grocery.name = name
        grocery.type = type.rawValue
        grocery.expiry = expiry
        grocery.amount = amount
        grocery.user = currentUser?.uid
        grocery.order = groceryList.count
        
        do {
            if let groceryRef = try groceriesRef?.addDocument(from: grocery) {
                grocery.id = groceryRef.documentID
            }
        } catch {
            print("Failed to serialize the grocery")
        }
        
        return grocery
    }
    
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
    
    func editGroceryOrder(grocery: Grocery, newOrder: Int) {
        if let groceryID = grocery.id {
            groceriesRef?.document(groceryID).updateData([
                "order": newOrder
            ])
        }
    }
    
    func deleteGrocery(grocery: Grocery) {
        if let groceryID = grocery.id {
            groceriesRef?.document(groceryID).delete()
        }
    }
    
    func setupGroceryListener() {
        groceriesRef = database.collection("groceries")
        listener?.remove()

        listener = (groceriesRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            
            self.parseGroceriesSnapshot(snapshot: querySnapshot)
        })!
    }
    
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
            
            if grocery.user == currentUser?.uid {
                removeNotificationOn(grocery)
                
                if change.type == .added {
                    groceryList.append(grocery)
                    requestNotificationsOn(grocery)
                } else if change.type == .modified {
                    groceryList[grocery.order!] = grocery
                    requestNotificationsOn(grocery)
                } else if change.type == .removed {
                    groceryList.remove(at: Int(change.oldIndex))
                }
            }
        }
        
        groceryList.sort {
            $0.order! < $1.order!
        }
        
        groceries = groceryList
        
        listeners.invoke { (listener) in
            if listener.listenerType == .groceries {
                listener.onGroceriesChange(change: .update, groceries: groceryList)
            }
        }
    }
    
    func requestNotificationsOn(_ grocery: Grocery) {
        // Create a notification content object
        let notificationContent = UNMutableNotificationContent()

        // Create its details
        notificationContent.title = "Fridge_IO"
        notificationContent.subtitle = "Your \(grocery.name ?? "") is about to expire! Cook it now!"
        
        //Create the trigger
        let date = Calendar.current.date(byAdding: .day, value: -1, to: grocery.expiry!)
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date!)
        dateComponents.hour = 17
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        // Create our request
        let request = UNNotificationRequest(identifier: grocery.id!,
             content: notificationContent, trigger: trigger)

        //Add the notification to the centre
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func removeNotificationOn(_ grocery: Grocery) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [grocery.id!])
    }
}
