//
//  Extensions.swift
//  TiktokClone
//
//  Created by Jérémy Perez on 18/09/2023.
//

import UIKit

extension UIViewController {
    
    func setupTextfield(container: UIView, textfield: UITextField) {
        container.layer.borderWidth = 1
        container.layer.borderColor = CGColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 0.8)
        container.layer.cornerRadius = 20
        container.clipsToBounds = true
        textfield.borderStyle = .none
    }
    
}
