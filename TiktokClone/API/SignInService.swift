//
//  SignInService.swift
//  TiktokClone
//
//  Created by Jérémy Perez on 28/09/2023.
//

import Firebase
import FirebaseAuth

class SignInService {
    
    static let shared = SignInService()
    
    func signIn(email: String, password: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authData, error in
            if let error = error {
                onError(error.localizedDescription)
                return
            } else {
                onSuccess()
            }
        }
    }
    
}
