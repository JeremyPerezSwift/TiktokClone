//
//  PostService.swift
//  TiktokClone
//
//  Created by Jérémy Perez on 23/10/2023.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage

class PostService {
    
    static let shared = PostService()
    
    func sharePost(encodedVideoURL: URL?, selectedPhoto: UIImage?, textView: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        let creadationDate = Date().timeIntervalSince1970
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if let encodedVideoURLUnrapped = encodedVideoURL {
            let videoIdString = "\(NSUUID().uuidString).mp4"
            let storageRef = References().storageRoot.child("posts").child(videoIdString)
            let metaData = StorageMetadata()
            
            storageRef.putFile(from: encodedVideoURLUnrapped, metadata: metaData) { data, errorPutFile in
                if let error = errorPutFile {
                    onError("Error 1 = \(error.localizedDescription)")
                    return
                } else {
                    storageRef.downloadURL { videoUrl, errorDownloadURL in
                        if let error = errorDownloadURL {
                            onError("Error 2 = \(error.localizedDescription)")
                            return
                        } else {
                            self.uploadThumbnailImageToStorage(selectedPhoto: selectedPhoto) { postImageUrl in
                                
                                guard let videoUrlString = videoUrl?.absoluteString else { return }
                                let values = ["creadationDate": creadationDate,
                                              "imageUrl": postImageUrl,
                                              "videoUrl": videoUrlString,
                                              "description": textView,
                                              "likes": 0,
                                              "views": 0,
                                              "commentCount": 0,
                                              "uid": uid] as [String: Any]
                                
                                let postId = References().databaseRoot.child("Posts").childByAutoId()
                                
                                postId.updateChildValues(values) { err, ref in
                                    if let error = err {
                                        onError("Error 3 = \(error.localizedDescription)")
                                        return
                                    } else {
                                        guard let postKey = postId.key else { return }
                                        
                                        References().databaseRoot.child("User-Posts").child(uid).updateChildValues([postKey: 1])
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
            }
        }
    }
    
    func uploadThumbnailImageToStorage(selectedPhoto: UIImage?, onSuccess: @escaping(String) -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        if let thumbnailImage = selectedPhoto, let imageData = thumbnailImage.jpegData(compressionQuality: 0.3) {
            let photoIdString = NSUUID().uuidString
            let storageRef = References().storageRoot.child("post_images").child(photoIdString)
            
            storageRef.putData(imageData) { metaData, errorPutData in
                if let error = errorPutData {
                    onError("Error 4 = \(error.localizedDescription)")
                    return
                } else {
                    storageRef.downloadURL { imageUrl, errorDownloadURL in
                        if let error = errorDownloadURL {
                            onError("Error 5 = \(error.localizedDescription)")
                            return
                        } else {
                            guard let postImageUrl = imageUrl?.absoluteString else { return }
                            onSuccess(postImageUrl)
                        }
                    }
                }
            }
        }
    }
    
}
