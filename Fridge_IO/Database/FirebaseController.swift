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
    var currentUser: FirebaseAuth.User?
    
    override init() {
        FirebaseApp.configure()
        
        authController = Auth.auth()
        
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
                
                listeners.invoke { (listener) in
                    if listener.listenerType == .auth {
                        listener.onAuthChange(success: true, message: nil)
                    }
                }
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
                
                listeners.invoke { (listener) in
                    if listener.listenerType == .auth {
                        listener.onAuthChange(success: true, message: nil)
                    }
                }
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
        } catch {
            print("Error: \(error)")
        }
    }
    
    func resetPassword(email: String) {
        authController.sendPasswordReset(withEmail: email)
    }
}
