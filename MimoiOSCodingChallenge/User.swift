//
//  User.swift
//  MimoiOSCodingChallenge
//
//  Created by Ehsan on 2017-09-23.
//  Copyright © 2017 Mimohello GmbH. All rights reserved.
//

import Foundation


class User {
    static let user = User()
    static let userDefaults = UserDefaults.standard

    var id: String!
    var accessToken: String!
    var emailaddress: String!

    func initialize(id: String, access: String, email: String) {
        self.id = id
        self.accessToken = access
        self.emailaddress = email
        storeUserData()
    }
    
    class func currentUser() -> User? {
        
        guard let id = userDefaults.string(forKey: "id"), let access = userDefaults.string(forKey: "accesstoken"),
            let email = userDefaults.string(forKey: "email") else {
                return nil
        }
        User.user.initialize(id: id, access: access, email: email)
        return User.user
    }
    
    
    func initialize(json object: AnyObject,email:String) throws {
        guard let _ = parseUserJSON(json: object,email: email) else {
            throw NSError.init()
        }
    }
    
    func parseUserJSON(json object: AnyObject,email:String) -> User? {
        
        guard let dict = object as? Dictionary<String, AnyObject> else {
            return nil
        }
        guard let id = dict["id_token"] as? String,
            let accessToken = dict["access_token"] as? String else {
            return nil
        }
        self.initialize(id: id, access: accessToken,email:email)
        return User.user
    }
    
    
    func storeUserData() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(emailaddress!, forKey: "email")
        userDefaults.set(id!, forKey: "id")
        userDefaults.set(accessToken!, forKey: "accesstoken")
        userDefaults.synchronize()
    }

    
    
    

    
    
}
