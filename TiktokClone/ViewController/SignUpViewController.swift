//
//  SignUpViewController.swift
//  TiktokClone
//
//  Created by Jérémy Perez on 18/09/2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import PhotosUI

class SignUpViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var avatarImg: UIImageView!
    
    @IBOutlet weak var usernameContainerView: UIView!
    @IBOutlet weak var usernameTextfield: UITextField!
    
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailTextfield: UITextField!
    
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Helpers
    
    func setUpView() {
        setUpNavigationBar()
        setupTextfields()
        
        avatarImg.layer.cornerRadius = 60
        avatarImg.clipsToBounds = true
        avatarImg.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentPicker))
        avatarImg.addGestureRecognizer(tapGesture)
        
        signUpButton.layer.cornerRadius = 25
    }
    
    func setUpNavigationBar() {
        navigationItem.title = "Create new account"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setupTextfields() {
        setupTextfield(container: usernameContainerView, textfield: usernameTextfield)
        setupTextfield(container: emailContainerView, textfield: emailTextfield)
        setupTextfield(container: passwordContainerView, textfield: passwordTextfield)
    }
    
    // MARK: - Selector
    
    @objc func presentPicker() {
        var configuration: PHPickerConfiguration = PHPickerConfiguration()
        configuration.filter = PHPickerFilter.images
        configuration.selectionLimit = 1
        
        let picker: PHPickerViewController = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    // MARK: - IBAction
    
    @IBAction func signUpDidTapped(_ sender: Any) {
        if emailTextfield.text != "" && passwordTextfield.text != "" && usernameTextfield.text != "" {
            guard let username = usernameTextfield.text else { return }
            guard let email = emailTextfield.text else { return }
            guard let password = passwordTextfield.text else { return }
            
            Auth.auth().createUser(withEmail: email, password: password) { resultAuth, errorAuth in
                if let error = errorAuth {
                    print("DEBUG: Error \(error.localizedDescription)")
                    return
                } else if let authData = resultAuth {
                    guard let emailUser = authData.user.email else { return }
                    print("DEBUG: Result \(emailUser)")
                    
                    let dictionnary: Dictionary<String, Any> = ["uid": authData.user.uid, "email": emailUser, "username": username, "profileImageUrl": "", "status": ""]
                    
                    Database.database().reference().child("users").child(authData.user.uid).updateChildValues(dictionnary) { errorDatabase, resultDatabase in
                        if let error = errorDatabase {
                            print("DEBUG: Error \(error.localizedDescription)")
                            return
                        } else {
                            print("DEBUG: Success")
                        }
                    }
                }
            }
        }
    }
    
}

// MARK: - PHPickerViewControllerDelegate

extension SignUpViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        for item in results {
            item.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                if let imageSelected = image as? UIImage {
                    DispatchQueue.main.async {
                        self.avatarImg.image = imageSelected
                    }
                }
            }
        }
        
        self.dismiss(animated: true)
    }
    
}
