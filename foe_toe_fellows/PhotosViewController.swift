//
//  PhotosViewController.swift
//  foe_toe_fellows
//
//  Created by nacnud on 1/16/15.
//  Copyright (c) 2015 nacnud. All rights reserved.
//

import UIKit
import Photos


class PhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    var collectionView : UICollectionView!
    var delegate :ImageSelectedProtocol?
    
    var imageManager = PHCachingImageManager()
    var assetsFetchResults : PHFetchResult!
    var assetCollection : PHAssetCollection!
    
    override func loadView() {
        let rootView = UIView(frame: UIScreen.mainScreen().bounds)
        rootView.backgroundColor = UIColor.whiteColor()
        
        self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
        let flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: 100, height: 100)
        self.collectionView.backgroundColor = UIColor.whiteColor()
        rootView.addSubview(collectionView)
        collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        let views = ["collectionView": collectionView]
        let colectionViewVerticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[collectionView]-|", options: nil, metrics: nil, views: views)
        let collectionViewHorizontalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[collectionView]-|", options: nil, metrics: nil, views: views)
        rootView.addConstraints(colectionViewVerticalConstraint)
        rootView.addConstraints(collectionViewHorizontalConstraint)
        
        
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageManager = PHCachingImageManager()
        self.assetsFetchResults = PHAsset.fetchAssetsWithOptions(nil)
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: "PHOTO_CELL")
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assetsFetchResults.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PHOTO_CELL", forIndexPath: indexPath) as GalleryCell
        let asset = self.assetsFetchResults[indexPath.row] as PHAsset
        self.imageManager.requestImageForAsset(asset, targetSize: CGSize(width: 100, height: 100), contentMode: PHImageContentMode.AspectFill, options: nil) { (requestedImage, info) -> Void in
            cell.imageView.image = requestedImage
        }
        cell.imageView.layer.cornerRadius = 10
        cell.imageView.layer.masksToBounds = true
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("did select a photo" )
        let cellSelected = collectionView.cellForItemAtIndexPath(indexPath) as GalleryCell
        let imageToPass = cellSelected.imageView.image
        println(imageToPass)
     self.delegate?.controllerDidSelectImgae(imageToPass!)
       self.navigationController?.popToRootViewControllerAnimated(true)
    }
    

    
    
}