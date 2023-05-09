//
//  RecipeData.swift
//  Fridge_IO
//
//  Created by Hong Yi on 9/5/2023.
//

import UIKit

class RecipeData: NSObject, Decodable {
    //All the needed variables
    
    private enum RootKeys: String, CodingKey {
        case recipe
    }
    
    private enum InfoKeys: String, CodingKey {
        //Replace with more layers
        case recipe
    }
    
    required init(from decoder: Decoder) throws {
//        //Get the root container
//        let rootContainer = try decoder.container(keyedBy: RootKeys.self)
//
//        //Get the book container for most info
//        let bookContainer = try rootContainer.nestedContainer(keyedBy: BookKeys.self, forKey: .volumeInfo)
//
//        //Get the image links container for the thumbnail
//        let imageContainer = try? bookContainer.nestedContainer(keyedBy: ImageKeys.self, forKey: .imageLinks)
//
//        title = try bookContainer.decode(String.self, forKey: .title)
//        publisher = try? bookContainer.decode(String.self, forKey: .publisher)
//        publicationDate = try? bookContainer.decode(String.self, forKey: .publicationDate)
//        bookDescription = try? bookContainer.decode(String.self, forKey: .bookDescription)
//
//        if let authorArray = try? bookContainer.decode([String].self, forKey: .authors) {
//            authors = authorArray.joined(separator: ", ")
//        }
//
//        if let isbnCodes = try? bookContainer.decode([ISBNCode].self, forKey: .industryIdentifiers) {
//            for code in isbnCodes {
//                if code.type == "ISBN_13" {
//                    isbn13 = code.identifier
//                }
//            }
//        }
//
//        imageURL = try? imageContainer?.decode(String.self, forKey: .smallThumbnail)
    }
}
