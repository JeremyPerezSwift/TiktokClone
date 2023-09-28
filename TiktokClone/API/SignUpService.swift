//
//  SignUpService.swift
//  TiktokClone
//
//  Created by Jérémy Perez on 23/09/2023.
//

import Firebase
import FirebaseAuth
import FirebaseStorage

struct SignUpCredentitals {
    let email: String
    let password: String
    let username: String
    let profileImage: Data
}

class SignUpService {
    
    static let shared = SignUpService()
    
    func signup(credentials: SignUpCredentitals, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { resultAuth, errorAuth in
            if let error = errorAuth {
                onError(error.localizedDescription)
                return
            } else if let authData = resultAuth {
                guard let emailUser = authData.user.email else { return }
                
                let credential: StorageCredentitals = StorageCredentitals(username: credentials.username, uid: authData.user.uid, data: credentials.profileImage)
                
                StorageService.shared.savePhoto(credential: credential) { url in
                    let dictionnary: Dictionary<String, Any> = [UID: authData.user.uid, EMAIL: emailUser, USERNAME: credentials.username, PROFILE_IMAGE_URL: "\(url)", STATUS: ""]
                    
                    References().databseSpecificUser(uid: authData.user.uid).updateChildValues(dictionnary) { errorDatabase, resultDatabase in
                        if let error = errorDatabase {
                            onError(error.localizedDescription)
                            return
                        } else {
                            onSuccess()
                        }
                    }
                } onError: { errorMessage in
                    onError(errorMessage)
                    return
                }
                
            }
        }
    }
    
//    func signupBase(credentials: SignUpCredentitals, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
//        Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { resultAuth, errorAuth in
//            if let error = errorAuth {
//                onError(error.localizedDescription)
//                return
//            } else if let authData = resultAuth {
//                guard let emailUser = authData.user.email else { return }
//                
//                let storageRef = Storage.storage().reference(forURL: "gs://tiktokuikitwithstoryboard.appspot.com")
//                let storageProfileRef = storageRef.child("profile").child(authData.user.uid)
//                let metaData = StorageMetadata()
//                metaData.contentType = "image/jpg"
//                
//                storageProfileRef.putData(credentials.profileImage, metadata: metaData) { resultStorage, errorStorage in
//                    if let error = errorStorage {
//                        onError(error.localizedDescription)
//                        return
//                    } else {
//                        storageProfileRef.downloadURL { url, errorUrl in
//                            if let error = errorUrl {
//                                 onError(error.localizedDescription)
//                                return
//                            } else if let metaImageUrl = url {
//                                let dictionnary: Dictionary<String, Any> = ["uid": authData.user.uid, "email": emailUser, "username": credentials.username, "profileImageUrl": "\(metaImageUrl)", "status": ""]
//                                
//                                Database.database().reference().child("users").child(authData.user.uid).updateChildValues(dictionnary) { errorDatabase, resultDatabase in
//                                    if let error = errorDatabase {
//                                        onError(error.localizedDescription)
//                                        return
//                                    } else {
//                                        onSuccess()
//                                    }
//                                }
//                            }
//                        }
//                        
//                    }
//                }
//                
//            }
//        }
//    }
    
}
