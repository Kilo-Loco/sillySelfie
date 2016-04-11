//
//  SelfieCVC.swift
//  Silly Selfie
//
//  Created by Kyle Lee on 4/9/16.
//  Copyright © 2016 Kilo Loco. All rights reserved.
//

import UIKit
import CloudKit

private let reuseIdentifier = "PhotoCell"

class SelfieCVC: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var picker: UIImagePickerController?
    var capturedImage: UIImage!
    var selfies = [CKRecord]()
    var refresh: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refresh = UIRefreshControl()
        self.refresh.attributedTitle = NSAttributedString(string: "Pull to refresh.")
        self.refresh.addTarget(self, action: #selector(self.loadData), forControlEvents: .ValueChanged)
        self.collectionView?.addSubview(self.refresh)
        
        self.picker?.delegate = self
        self.picker?.sourceType = .PhotoLibrary

        // Register cell classes
        //self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "PhotoCell")
        self.collectionView?.registerClass(PhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.loadData()
    }
    
    @IBAction func addPhoto(sender: AnyObject) {
        
        // Image picker camera logic
        self.picker = UIImagePickerController()
        picker?.sourceType = .Camera
        presentViewController(picker!, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        // Captured image formatting
        self.capturedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        dismissViewControllerAnimated(true, completion: nil)
        
        // Image conversion and push to Cloud
        guard self.capturedImage != nil else {
            print("Missing Image")
            return
        }
        let imageData: NSData = UIImageJPEGRepresentation(self.capturedImage, 1)!
        let newSelfie = CKRecord(recordType: "Selfie")
        newSelfie["imageData"] = imageData
        
        let publicData = CKContainer.defaultContainer().publicCloudDatabase
        publicData.saveRecord(newSelfie) { (record: CKRecord?, error: NSError?) in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), { 
                self.collectionView?.performBatchUpdates({ 
                    self.selfies.insert(newSelfie, atIndex: 0)
                    let indexPath = NSIndexPath(forItem: 0, inSection: 0)
                    self.collectionView?.insertItemsAtIndexPaths([indexPath])
                    }, completion: nil)
            })
        }
    }
    
    func loadData() {
        self.selfies = [CKRecord]()
        
        let publicData = CKContainer.defaultContainer().publicCloudDatabase
        let query = CKQuery(recordType: "Selfie", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        publicData.performQuery(query, inZoneWithID: nil) { (results: [CKRecord]?, error: NSError?) in
            guard let loadedSelfies = results else {
                print(error)
                return
            }
            self.selfies = loadedSelfies
            dispatch_async(dispatch_get_main_queue(), { 
                self.collectionView?.reloadData()
                self.refresh.endRefreshing()
            })
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.selfies.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as? PhotoCell {
    
        // Configure the cell
            guard self.selfies.count > 0 else {
                return cell
            }
            let selfie = self.selfies[indexPath.item]
            
            guard let selfieData = selfie["imageData"] as? NSData else {
                return cell
            }
            cell.configureCell(selfieData)
            
            return cell
            
        } else {
            return UICollectionViewCell()
        }
        
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
