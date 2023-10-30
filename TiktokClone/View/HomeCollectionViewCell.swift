//
//  HomeCollectionViewCell.swift
//  TiktokClone
//
//  Created by Jérémy Perez on 23/10/2023.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.layer.cornerRadius = 55 / 2
    }
    
}
