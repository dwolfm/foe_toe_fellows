//
//  GalleryCell.swift
//  foe_toe_fellows
//
//  Created by nacnud on 1/15/15.
//  Copyright (c) 2015 nacnud. All rights reserved.
//

import UIKit

class GalleryCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.imageView)
        self.imageView.frame = self.bounds
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.imageView.layer.masksToBounds = true
        self.imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        let views = ["imageView": imageView]
        let imageViewVerticleConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[imageView]|", options: nil, metrics: nil, views: views)
        let imageViewHorizontalConstraits = NSLayoutConstraint.constraintsWithVisualFormat("H:|[imageView]|", options: nil, metrics: nil, views: views)
        self.addConstraints(imageViewVerticleConstraints)
        self.addConstraints(imageViewHorizontalConstraits)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
