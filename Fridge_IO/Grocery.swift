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
    case user
}

enum GroceryType: Int {
    case dairy = 0
    case vegetables = 1
    case meat = 2
    case nuts = 3
    case liquids = 4
}

class Grocery: NSObject, Codable {
    
    @DocumentID var id: String?
    var name: String?
    var type: Int?
    var expiry: Date?
    var amount: String?
    var user: String?
}

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
