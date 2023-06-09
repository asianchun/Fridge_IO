//
//  RecipeData.swift
//  Fridge_IO
//
//  Created by Hong Yi on 9/5/2023.
//

import UIKit

class RecipeData: NSObject, Decodable, Encodable {
    
    //All the needed variables from the API
    var name: String?
    var imageURL: String?
    var source: String?
    var url: String?
    var ingredientLines: [String]?
    var ingredients: [String]?
    var calories: Int?
    var mealType: String?
    var diateries: String?
    
    private enum RootKeys: String, CodingKey {
        case recipe
    }
    
    private enum RecipeKeys: String, CodingKey {
        case name = "label"
        case imageURL = "image"
        case source
        case url
        case ingredientLines
        case ingredients
        case calories
        case mealType
        case diateries = "cautions"
    }
    
    private struct Ingredients: Decodable {
        var food: String
    }
    
    required init(from decoder: Decoder) throws {
        //Decode the recipes from an API
        if decoder.codingPath.count == 2 {
            //Get the root container
            let rootContainer = try decoder.container(keyedBy: RootKeys.self)

            //Get the recipe container for all the info
            let recipeContainer = try rootContainer.nestedContainer(keyedBy: RecipeKeys.self, forKey: .recipe)
            
            name = try recipeContainer.decode(String.self, forKey: .name)
            imageURL = try recipeContainer.decode(String.self, forKey: .imageURL)
            source = try recipeContainer.decode(String.self, forKey: .source)
            url = try recipeContainer.decode(String.self, forKey: .url)
            ingredientLines = try recipeContainer.decode([String].self, forKey: .ingredientLines)
            
            let value = try recipeContainer.decode(Float.self, forKey: .calories)
            calories = Int(floor(value))
            
            if let diateryArray = try? recipeContainer.decode([String].self, forKey: .diateries) {
                diateries = diateryArray.joined(separator: ", ")
            }

            if let mealArray = try? recipeContainer.decode([String].self, forKey: .mealType) {
                mealType = mealArray.joined(separator: ", ")
            }
            
            ingredients = []
            if let ingredientList = try? recipeContainer.decode([Ingredients].self, forKey: .ingredients) {
                for ingredient in ingredientList {
                    ingredients?.append(ingredient.food)
                }
            }
        } else { //Decode recipes from the Propertly lists
            let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
            
            name = try rootContainer.decode(String.self, forKey: .name)
            imageURL = try rootContainer.decode(String.self, forKey: .imageURL)
            source = try rootContainer.decode(String.self, forKey: .source)
            url = try rootContainer.decode(String.self, forKey: .url)
            ingredientLines = try rootContainer.decode([String].self, forKey: .ingredientLines)
            calories = try rootContainer.decode(Int.self, forKey: .calories)
            diateries = try rootContainer.decode(String.self, forKey: .diateries)
            mealType = try rootContainer.decode(String.self, forKey: .mealType)
            ingredients = try rootContainer.decode([String].self, forKey: .ingredients)
        }
    }
}
