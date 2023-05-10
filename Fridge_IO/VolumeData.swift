//
//  VolumeData.swift
//  Fridge_IO
//
//  Created by Hong Yi on 9/5/2023.
//

import UIKit

class VolumeData: NSObject, Decodable {
    
    var recipes: [RecipeData]?
    
    private enum CodingKeys: String, CodingKey {
        case recipes = "hits"
    }
}
