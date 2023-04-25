//
//  DatabaseProtocol.swift
//  Fridge_IO
//
//  Created by Hong Yi on 25/4/2023.
//

import Foundation

enum ListenerType {
    case auth
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onAuthChange(success: Bool, message: String?)
}

protocol DatabaseProtocol: AnyObject {
    //Listener functions
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    //Authentication functions
    func login(email: String, password: String)
    func signup(email: String, password: String)
}
