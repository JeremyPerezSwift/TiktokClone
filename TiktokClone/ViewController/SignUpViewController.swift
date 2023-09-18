//
//  SignUpViewController.swift
//  TiktokClone
//
//  Created by Jérémy Perez on 18/09/2023.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var avatarImg: UIImageView!
    
    @IBOutlet weak var usernameContainerView: UIView!
    @IBOutlet weak var usernameTextfield: UITextField!
    
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailTextfield: UITextField!
    
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    func setUpView() {
        setUpNavigationBar()
        setupTextfields()
        
        avatarImg.layer.cornerRadius = 60
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
    
}
