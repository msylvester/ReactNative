//
//  HomeCollectionViewController.swift
//  WatchTwo
//
//  Created by Michael on 5/13/16.
//  Copyright © 2016 Mike S. All rights reserved.
//

import UIKit
import DataKit
import CloudKit
import WatchConnectivity

private let reuseIdentifier = "imageCell"

class HomeCollectionViewController: UICollectionViewController {
  
    //MARK: Properties
    var records = [CKRecord]()
    var imageArray = [UIImage]()
  
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }

    override func viewWillAppear(_ animated: Bool) {
      if WCSession.isSupported() {
        let session = WCSession.default()
        session.delegate = self
        session.activate()
      }
      
      refreshView()
      
    }

  
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }

  
    func refreshView() {
      CloudKitManager.sharedInstance.sync { (results) -> Void in
        // Note: This closure is happening on the main thread
        self.records = results as! [CKRecord]
        self.collectionView?.reloadData()
   
      }
      

    }
    

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return records.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HomeCollectionViewCell
     
      
 
      if let img = records[indexPath.row].value(forKey: "imageView") {
        cell.imageView.image = UIImage(contentsOfFile: (img as AnyObject).fileURL.path)
      }
      
        return cell
    }


  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    //if image is selected, tap to favorite 
    
    if let img = self.records[indexPath.row].value(forKey: "thumbnail") {

          let  image = try! Data(contentsOf: URL(fileURLWithPath: (img as AnyObject).fileURL.path))
      
   
          do {
            let applicationDict = ["favImage":image]
            try WCSession.default().updateApplicationContext(applicationDict)
            //try WatchSessionManager.sharedManager.updateApplicationContext(["favImage" : image])
          } catch {
            print("error")
          }
      
    }
    let alertController = UIAlertController(title: "Image Favorited", message: "Check your glance ⌚️", preferredStyle: .alert)
    
    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alertController.addAction(defaultAction)
    
    present(alertController, animated: true, completion: nil)
    

    
  }
  
  
}

///extension to add support for recieving messages from the watch, however, not used
extension HomeCollectionViewController: WCSessionDelegate {
  
  /// Handle application context sent from the iOS app
  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    NSLog("didReceiveApplicationContext: \(applicationContext)")
  }
  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    NSLog("didReceiveMessage: \(message)")
  }
  
}


