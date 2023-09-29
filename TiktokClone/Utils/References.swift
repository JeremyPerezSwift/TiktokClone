//
//  References.swift
//  TiktokClone
//
//  Created by Jérémy Perez on 27/09/2023.
//

import Firebase
import FirebaseStorage

let REF_USER = "users"
let STORAGE_PROFILE = "profile"
let URL_STORAGE_ROOT = "gs://tiktokuikitwithstoryboard.appspot.com"

let EMAIL = "email"
let UID = "uid"
let USERNAME = "username"
let PROFILE_IMAGE_URL = "profileImageUrl"
let STATUS = "status"

let IDENTIFIER_TABBAR = "TabbarVC"
let IDENTIFIER_MAIN = "MainVC"

class References {
    
    // MARK: - Database
    
    let databaseRoot = Database.database().reference()
    
    var databaseUsers: DatabaseReference {
        return databaseRoot.child(REF_USER)
    }
    
    func databseSpecificUser(uid: String) -> DatabaseReference {
        return databaseUsers.child(uid)
    }
    
    // MARK: - Storage
    
    let storageRoot = Storage.storage().reference(forURL: URL_STORAGE_ROOT)
    
    var storageProfile: StorageReference {
        return storageRoot.child(STORAGE_PROFILE)
    }
    
    func storageSpecificProfile(uid: String) -> StorageReference {
        return storageProfile.child(uid)
    }
    
}
