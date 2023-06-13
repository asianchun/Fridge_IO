//
//  User.swift
//  Fridge_IO
//
//  Created by Hong Yi on 13/6/2023.
//

import UIKit
import FirebaseFirestoreSwift

enum UserCodingKeys: String, CodingKey {
    case id
    case groceries
    case groceryLists
    case userID
}

class User: NSObject, Codable {
    
    @DocumentID var id: String?
    var groceries: [Grocery]?
    var groceryLists: [GroceryList]?
    var userID: String?
}
