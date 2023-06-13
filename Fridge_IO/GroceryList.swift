//
//  GroceryList.swift
//  Fridge_IO
//
//  Created by Hong Yi on 23/5/2023.
//

import UIKit
import FirebaseFirestoreSwift

enum GroceryListCodingKeys: String, CodingKey {
    case id
    case name
    case listItems
}

class GroceryList: NSObject, Codable {
        
    @DocumentID var id: String?
    var name: String?
    var listItems: [String]?
}
