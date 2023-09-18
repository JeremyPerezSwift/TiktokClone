//
//  SignInViewController.swift
//  TiktokClone
//
//  Created by Jérémy Perez on 18/09/2023.
//

import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailTextfield: UITextField!
    
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
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
        
        signInButton.layer.cornerRadius = 25
    }
    
    func setUpNavigationBar() {
        navigationItem.title = "Sign In"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setupTextfields() {
        setupTextfield(container: emailContainerView, textfield: emailTextfield)
        setupTextfield(container: passwordContainerView, textfield: passwordTextfield)
    }
    
}
