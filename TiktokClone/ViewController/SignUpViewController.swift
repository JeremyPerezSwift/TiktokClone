//
//  SignUpViewController.swift
//  TiktokClone
//
//  Created by Jérémy Perez on 18/09/2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import PhotosUI
import ProgressHUD

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
    
    var image: UIImage? = nil
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        
//        do {
//            try Auth.auth().signOut()
//        } catch {
//            print("DEBUG: Error signing out")
//        }
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
        if emailTextfield.text != "" && passwordTextfield.text != "" && usernameTextfield.text != "" && image != nil {
            guard let username = usernameTextfield.text else { return }
            guard let email = emailTextfield.text else { return }
            guard let password = passwordTextfield.text else { return }
            guard let imageSelected = image else { return }
            guard let imageData = imageSelected.jpegData(compressionQuality: 0.2) else { return }
            
            let credentials: SignUpCredentitals = SignUpCredentitals(email: email, password: password, username: username, profileImage: imageData)
            
            ProgressHUD.show()
            
            SignUpService.shared.signup(credentials: credentials) {
                ProgressHUD.remove()
                ProgressHUD.showSucceed()
                print("DEBUG: Success")
            } onError: { errorMessage in
                ProgressHUD.remove()
                ProgressHUD.showError("\(errorMessage)")
            }

        } else {
            ProgressHUD.showError("Please enter informations")
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
                        self.image = imageSelected
                    }
                }
            }
        }
        
        self.dismiss(animated: true)
    }
    
}
