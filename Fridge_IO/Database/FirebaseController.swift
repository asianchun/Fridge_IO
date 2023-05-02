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
    var currentUserID: String?
    
    var groceriesRef: CollectionReference?
    var groceryList: [Grocery]
    
    var listenerExists = false
    
    override init() {
        FirebaseApp.configure()
        
        authController = Auth.auth()
        database = Firestore.firestore()
        
        groceryList = [Grocery]()
        
//        database = Firestore.firestore()
//        heroList = [Superhero]()
//        defaultTeam = Team()
//
//        usersRef = database.collection("users")
//        teamsRef = database.collection("teams")
        
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
                currentUserID = currentUser?.uid
                
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
                currentUserID = currentUser?.uid
                
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
            currentUserID = nil
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
        
        do {
            if let groceryRef = try groceriesRef?.addDocument(from: grocery) {
                grocery.id = groceryRef.documentID
            }
        } catch {
            print("Failed to serialize hero")
        }
        
        return grocery
    }
    
    func deleteGrocery(grocery: Grocery) {
        if let groceryID = grocery.id {
            groceriesRef?.document(groceryID).delete()
        }
    }
    
    func setupGroceryListener() {
        groceriesRef = database.collection("groceries")

        groceriesRef?.addSnapshotListener() { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            
            self.parseGroceriesSnapshot(snapshot: querySnapshot)
        }
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
            
            if change.type == .added {
                groceryList.append(grocery)
            } else if change.type == .modified {
                groceryList[Int(change.oldIndex)] = grocery
            } else if change.type == .removed {
                groceryList.remove(at: Int(change.oldIndex))
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == .groceries {
                listener.onGroceriesChange(change: .update, groceries: groceryList)
            }
        }
    }
}
