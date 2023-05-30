//
//  DatabaseProtocol.swift
//  Fridge_IO
//
//  Created by Hong Yi on 25/4/2023.
//

import Foundation
import Firebase

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case auth
    case groceries
    case groceryLists
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onAuthChange(success: Bool, message: String?)
    func onGroceriesChange(change: DatabaseChange, groceries: [Grocery])
    func onGroceryListsChange(change: DatabaseChange, groceryLists: [GroceryList])
}

protocol DatabaseProtocol: AnyObject {
    var currentUser: FirebaseAuth.User? {get set}
    var groceries: [Grocery] {get set}
    
    //Listener functions
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    //Authentication functions
    func login(email: String, password: String)
    func signup(email: String, password: String)
    func logout()
    func resetPassword(email: String)
    
    //Grocery functions
    func setupGroceryListener()
    func addGrocery(name: String, type: GroceryType, expiry: Date, amount: String) -> Grocery
    func editGrocery(grocery: Grocery, name: String, type: GroceryType, expiry: Date, amount: String)
    func editGroceryOrder(grocery: Grocery, newOrder: Int)
    func deleteGrocery(grocery: Grocery)
    
    //Grocery List functions
    func addGroceryList(name: String, listItems: [String]) -> GroceryList
    func editGroceryList(groceryList: GroceryList, listItems: [String])
    func deleteGroceryList(groceryList: GroceryList)
}
