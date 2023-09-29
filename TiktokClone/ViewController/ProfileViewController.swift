//
//  ProfileViewController.swift
//  TiktokClone
//
//  Created by Jérémy Perez on 28/09/2023.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func logoutAction(_ sender: Any) {
        SignInService.shared.logOut()
    }
    

}
