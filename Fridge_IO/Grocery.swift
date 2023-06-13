//
//  Grocery.swift
//  Fridge_IO
//
//  Created by Hong Yi on 2/5/2023.
//

import UIKit
import FirebaseFirestoreSwift

enum CodingKeys: String, CodingKey {
    case id
    case name
    case type
    case expiry
    case amount
}

//Types of groceries
enum GroceryType: Int {
    case dairy = 0
    case fruitsAndVegetables = 1
    case meat = 2
    case seafood = 3
    case condiments = 4
    case other = 5
}

class Grocery: NSObject, Codable {
    
    @DocumentID var id: String?
    var name: String?
    var type: Int?
    var expiry: Date?
    var amount: String?
    var order: Int?
}

//Convert the type into an int value and vice versa
extension Grocery {
    var groceryType: GroceryType {
        get {
            return GroceryType(rawValue: self.type!)!
        }
        set {
            self.type = newValue.rawValue
        }
    }
}
