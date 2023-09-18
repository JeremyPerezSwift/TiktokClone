//
//  ViewController.swift
//  TiktokClone
//
//  Created by Jérémy Perez on 18/09/2023.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func setupView() {
        signupButton.layer.cornerRadius = 18
        facebookButton.layer.cornerRadius = 18
        googleButton.layer.cornerRadius = 18
        loginButton.layer.cornerRadius = 18
    }

}

