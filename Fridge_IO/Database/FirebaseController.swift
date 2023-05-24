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
    var groceryListsRef: CollectionReference?
    var groceryList: [Grocery]
    var groceryLists: [GroceryList]
    
    var groceryListener: ListenerRegistration?
    var groceryListListener: ListenerRegistration?
    
    override init() {
        FirebaseApp.configure()
        
        authController = Auth.auth()
        database = Firestore.firestore()
        
        groceryList = [Grocery]()
        groceryLists = [GroceryList]()

        super.init()
    }
    
    //Listener functions
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .groceries {
            listener.onGroceriesChange(change: .update, groceries: groceryList)
        }
        
        if listener.listenerType == .groceryLists {
            listener.onGroceryListsChange(change: .update, groceryLists: groceryLists)
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
        groceryListener?.remove()

        groceryListener = (groceriesRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            
            self.parseGroceriesSnapshot(snapshot: querySnapshot)
        })!
        
        setupGroceryListListener()
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
    
    //Grocery List functions
    func setupGroceryListListener() {
        groceryListsRef = database.collection("groceryLists")
        groceryListListener?.remove()

        groceryListListener = (groceryListsRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            
            self.parseGroceryListsSnapshot(snapshot: querySnapshot)
        })!
    }
    
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
            
            if groceryList.user == currentUser?.uid {
                if change.type == .added {
                    groceryLists.append(groceryList)
                } else if change.type == .modified {
                    groceryLists[Int(change.oldIndex)] = groceryList
                } else if change.type == .removed {
                    groceryLists.remove(at: Int(change.oldIndex))
                }
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == .groceryLists {
                listener.onGroceryListsChange(change: .update, groceryLists: groceryLists)
            }
        }
    }
    
    func addGroceryList(name: String, listItems: [String]) -> GroceryList {
        let groceryList = GroceryList()
        groceryList.name = name
        groceryList.user = currentUser?.uid
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
    
    func editGroceryList(groceryList: GroceryList, listItems: [String]) {
        if let listID = groceryList.id {
            groceryListsRef?.document(listID).updateData([
                "listItems": listItems
            ])
        }
    }
    
    func deleteGroceryList(groceryList: GroceryList) {
        if let listID = groceryList.id {
            groceryListsRef?.document(listID).delete()
        }
    }
    
    //Notifcation setup
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
        dateComponents.minute = 25 //For testing purposes
        
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
