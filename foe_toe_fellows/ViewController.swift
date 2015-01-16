//
//  ViewController.swift
//  foe_toe_fellows
//
//  Created by nacnud on 1/15/15.
//  Copyright (c) 2015 nacnud. All rights reserved.
//

import UIKit
import Social
class ViewController: UIViewController, ImageSelectedProtocol, UICollectionViewDataSource , UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var photoButtonYConstratint : NSLayoutConstraint!
    let alertController = UIAlertController(title: "foe toe", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
    let galleryViewControler = GalleryViewController()
    let mainImageView = UIImageView(frame: CGRectZero)
    let grapefruitColor = UIColor(red: 223/255, green: 158/255, blue: 139/255, alpha: 1)
    let photoButton = UIButton()
    var collectionView :UICollectionView!
    var collectionFlowLayout: UICollectionViewFlowLayout!
    var collectionYConstraint: NSLayoutConstraint!
    var mainImageViewYConstraint: NSLayoutConstraint!
    let filterNames = ["CISepiaTone","CIPhotoEffectChrome", "CIPhotoEffectNoir"]
    var thumbnails :[Thumbnail] = []
    var originalThumbnail: UIImage!
    let imageQueue = NSOperationQueue()
    var gpuContext :CIContext!
    var filterSelercted: String?
    var shareButton : UIBarButtonItem!

    
    
    
    override func loadView() {
        //MARK: initialize a view to be the rootView
        let rootView = UIView(frame: UIScreen.mainScreen().bounds)
        
        //MARK: add subviews to root view\
        
        //Mark: add mainImageView to rootView
        rootView.addSubview(self.mainImageView)
        
        //MARK: add photoButton to rootView
        self.photoButton.setTitle("foe toe", forState: .Normal)
        self.photoButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        self.photoButton.setTitleColor(grapefruitColor, forState: UIControlState.Highlighted)
        self.photoButton.layer.cornerRadius = 10
        self.photoButton.layer.masksToBounds = true
        self.photoButton.addTarget(self, action: "photoButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        self.photoButton.addTarget(self, action: "photoButtonDown", forControlEvents: UIControlEvents.TouchDown)
        self.photoButton.backgroundColor = grapefruitColor
        rootView.addSubview(self.photoButton)
        
        //MARK: add collection view for filters
        self.collectionFlowLayout = UICollectionViewFlowLayout()
        self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionFlowLayout)
        self.collectionFlowLayout.itemSize = CGSize(width: 100, height: 100)
        self.collectionFlowLayout.scrollDirection = .Horizontal
        self.collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: "FILTER_CELL")
        self.collectionView.backgroundColor = UIColor.clearColor()
        rootView.addSubview(self.collectionView)
        
        //MARK: setup views for autoLayout
        let views = ["photoButton": self.photoButton, "mainImageView": self.mainImageView, "collectionView": self.collectionView]
        for (key, view) in views{
            view.setTranslatesAutoresizingMaskIntoConstraints(false)
        }
        
        
        //MARK: setup gpu context for thumbnails
        let options = [kCIContextWorkingColorSpace: NSNull()]
        let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        self.gpuContext = CIContext(EAGLContext: eaglContext, options: options)
        
        //MARK: setup thumbnails
        for name in self.filterNames{
            let thumbnail = Thumbnail(filterName: name, operationQueue: self.imageQueue, context: self.gpuContext)
            thumbnails.append(thumbnail)
        }
        
        self.setupAutoLayoutConstraintsOnRootView(rootView, forViews: views)
        
        //MARK: set the rootView
        self.view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.title = "foe toe"
        
        //MARK: setup main ImageView
        self.mainImageView.backgroundColor = UIColor.whiteColor()
        self.mainImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.mainImageView.layer.cornerRadius = 10
        self.mainImageView.layer.masksToBounds = true
        
        // become delage for gallery VC
        self.galleryViewControler.delagate = self
        
        //MARK: add options to alertView
        let galleryOption = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
            println("selected show gallery")
            self.navigationController?.pushViewController(self.galleryViewControler, animated: true)
        }
        self.alertController.addAction(galleryOption)
        let filterOption =  UIAlertAction(title: "Filter", style: UIAlertActionStyle.Default) { (action) -> Void in
            if self.mainImageView.image != nil {
                println("show filters")
                self.collectionYConstraint.constant = 10
                self.photoButtonYConstratint.constant = self.view.bounds.height/2 + 30
                self.mainImageViewYConstraint.constant = 130
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "filterSelected")
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
        self.alertController.addAction(filterOption)
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            let cameraOption = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) { (action) -> Void in
                let imagePickerController = UIImagePickerController()
                imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
                imagePickerController.allowsEditing = true
                imagePickerController.delegate = self
                self.presentViewController(imagePickerController, animated: true, completion: nil)
            }
            self.alertController.addAction(cameraOption)
        }
        let photoOption = UIAlertAction(title: "Photos", style: .Default) { (action) -> Void in
            println("photos selected")
        }
        let cancelOption = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            println()
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        self.alertController.addAction(cancelOption)
        
        
        // MARK: conform to collectionview DataSourse
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        

        self.shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "sharePressed")
        
    }
    
    
    //MARK: photo button pressed -> present alert alertView
    func photoButtonPressed(){
        println("photo button pressed")
        self.photoButton.backgroundColor = self.grapefruitColor
        self.photoButtonYConstratint.constant = self.view.bounds.height/2 - 30
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        self.presentViewController(self.alertController, animated: true, completion: nil)

        
    }
    
    func photoButtonDown(){
        self.photoButton.backgroundColor = UIColor.blackColor()
    }
    
    
    //MARK: conform to image selected protocol
    
    func controllerDidSelectImgae(selectedImage: UIImage) {
        self.mainImageView.image = selectedImage
        
        // genorate a thumbnail from the selected image
        // then set each thumbail array's original thumbnail to that thumnail
        self.generateThumbnail(selectedImage)
        for thumbnail in thumbnails{
            thumbnail.originalImage = self.originalThumbnail
            thumbnail.filteredImage = nil
        }
        self.collectionView.reloadData()
        
        self.navigationController?.popToRootViewControllerAnimated(true)
        println("controllerDidSelectImge fired")
    }
    
    //MARK: genorate a thumbnail ---> ran at controller did select image
    func generateThumbnail(image:UIImage){
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
        self.originalThumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func generateFilteredImage(){
        let startImage = CIImage(image: self.mainImageView.image)
        let filter = CIFilter(name: self.filterSelercted)
        filter.setDefaults()
        filter.setValue(startImage, forKey: kCIInputImageKey)
        let result = filter.valueForKey(kCIOutputImageKey) as CIImage
        let extent = result.extent()
        let imageRef = self.gpuContext.createCGImage(result, fromRect: extent)
        self.mainImageView.image =  UIImage(CGImage: imageRef)
        self.filterSelercted = nil

    }
    
    //MARK: conform to collectionview datasourse part two
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        println("thumbnails.count: \(thumbnails.count)" )
        return thumbnails.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FILTER_CELL", forIndexPath: indexPath) as GalleryCell
        cell.backgroundColor = UIColor.blackColor()
        cell.layer.cornerRadius = 50
        cell.imageView.contentMode = UIViewContentMode.ScaleAspectFill
        cell.layer.masksToBounds = true

        let thumbnail = self.thumbnails[indexPath.row]
        if thumbnail.originalImage != nil {
            if thumbnail.filteredImage == nil {
                thumbnail.generateFilteredImage()
                cell.imageView.image = thumbnail.filteredImage!
            }
        }
        return cell
    }
    
    //MARK: confrom to collection view delagate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.filterSelercted = thumbnails[indexPath.row].filterName
        let selectedCell = collectionView.cellForItemAtIndexPath(indexPath)?
        selectedCell?.layer.borderColor = self.grapefruitColor.CGColor
        selectedCell?.layer.borderWidth = 10
        println("selected path: \(indexPath)")
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = collectionView.cellForItemAtIndexPath(indexPath)?
        selectedCell?.layer.borderWidth = 0
    }
    
    
    func filterSelected(){
        println("filterSelected")
        self.navigationController?.popToRootViewControllerAnimated(true)
        self.generateFilteredImage()
        for i in 0...filterNames.count {
            self.collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: i, inSection: 0))?.layer.borderWidth = 0
            
        }
        self.collectionYConstraint.constant = -120
        self.photoButtonYConstratint.constant = self.view.bounds.height/2 - 30
        self.mainImageViewYConstraint.constant = 60
        self.navigationItem.rightBarButtonItem = shareButton
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.controllerDidSelectImgae(image!)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.mainImageView.image != nil {
            println("let ther be actions")
            self.navigationItem.rightBarButtonItem = self.shareButton
        }
    }
    
    func sharePressed(){
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            let compViewControler = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            compViewControler.addImage(self.mainImageView.image)
            self.presentViewController(compViewControler, animated: true, completion: nil)
        }
        
    }
    
    
    func setupAutoLayoutConstraintsOnRootView(rootView: UIView, forViews views: [String:AnyObject]){
        //MARK: photoButton auto layout Constraints
        let photoButton = views["photoButton"] as UIView!
//        let photoButtonVerticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[photoButton]-|", options: nil, metrics: nil, views: views)
        let photoButtonVerticalConstraint = NSLayoutConstraint(item: photoButton, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        let photoButtonWidthConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[photoButton(80)]", options: nil, metrics: nil, views: views)
        self.photoButtonYConstratint = photoButtonVerticalConstraint as NSLayoutConstraint!
        let photOButtonHorizontalConstraint = NSLayoutConstraint(item: photoButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0.0)

        rootView.addConstraint(photoButtonVerticalConstraint)
        rootView.addConstraint(photOButtonHorizontalConstraint)
        rootView.addConstraints(photoButtonWidthConstraints)
        //MARK: mainImageView auto layout Constraints
        let mainImageViewVerticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|-72-[mainImageView]-60-|", options: nil, metrics: nil, views: views)
        let mainImageViweHorizontalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[mainImageView]-|", options: nil, metrics: nil, views: views)
        rootView.addConstraints(mainImageViewVerticalConstraint)
        rootView.addConstraints(mainImageViweHorizontalConstraint)
        self.mainImageViewYConstraint = mainImageViewVerticalConstraint.last as NSLayoutConstraint!
        
        let collectionViewVerticalConstratint = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectionView]-(-120)-|", options: nil, metrics: nil, views: views)
        let collectionViewHorizontalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: nil, metrics: nil, views: views)
        let collectionViewHeightConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectionView(100)]", options: nil, metrics: nil, views: views)
        rootView.addConstraints(collectionViewVerticalConstratint)
        rootView.addConstraints(collectionViewHorizontalConstraint)
        rootView.addConstraints(collectionViewHeightConstraint)
        self.collectionYConstraint = collectionViewVerticalConstratint.first as NSLayoutConstraint!
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

