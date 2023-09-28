//
//  StorageService.swift
//  TiktokClone
//
//  Created by Jérémy Perez on 23/09/2023.
//

import Firebase
import FirebaseAuth
import FirebaseStorage

struct StorageCredentitals {
    let username: String
    let uid: String
    let data: Data
}

class StorageService {
    
    static let shared = StorageService()
    
    func savePhoto(credential: StorageCredentitals, onSuccess: @escaping(_ url: URL) -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        let storageProfileRef = References().storageSpecificProfile(uid: credential.uid)
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageProfileRef.putData(credential.data, metadata: metaData) { resultStorage, errorStorage in
            if let error = errorStorage {
                onError(error.localizedDescription)
                return
            } else {
                
                storageProfileRef.downloadURL { url, errorUrl in
                    if let error = errorUrl {
                         onError(error.localizedDescription)
                        return
                    } else if let metaImageUrl = url {
                        
                        if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() {
                            print("DEBUG: Test changeRequest")
                            changeRequest.photoURL = url
                            changeRequest.displayName = credential.username
                            changeRequest.commitChanges { errorCommit in
                                if let error = errorCommit {
                                    onError(error.localizedDescription)
                                }
                            }
                        }
                        
                        onSuccess(metaImageUrl)
                    }
                }
                
            }
        }
    }
    
}
