//
//  PhotoCell.swift
//  Silly Selfie
//
//  Created by Kyle Lee on 4/9/16.
//  Copyright © 2016 Kilo Loco. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var selfieImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.lightGrayColor()
        layer.cornerRadius = 5.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configureCell(imageData: NSData) {
        
        let image = UIImage(data: imageData)
        self.selfieImageView.image = image
        
    }
    
    
}
