//
//  ImageCollectionViewCell.swift
//  mygallery-app
//
//  Created by Partha Pratim on 18/10/23.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellImageView: UIImageView!
    
    override func awakeFromNib() {
        self.cellImageView.layer.cornerRadius = 10
    }
}
