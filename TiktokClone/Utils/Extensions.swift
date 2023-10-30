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

extension UIImage {
    
    func imageRotated(by radian: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size).applying(CGAffineTransform(rotationAngle: radian)).integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
            
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radian)
            
            draw(in: CGRect(x: -origin.y, y: -origin.x, width: size.width, height: size.height))
            
            let rotateImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return rotateImage ?? self
        }
        
        return self
    }
    
}
