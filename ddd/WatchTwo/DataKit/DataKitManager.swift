//
//  DataKitManager.swift
//  WatchTwo
//
//  Created by Michael on 5/5/16.
//  Copyright © 2016 Mike S. All rights reserved.
//

import Foundation
import CloudKit

///Most of this code comes from Professors Cloud Kit Data Sync code
///There are some additions regarding pushing images 


/** To enable extension data sharing, we need to use an app group */
let sharedAppGroup: String = "group.watchHW"

/** The key for our defaults storage */
let favoritesKey: String = "Favorites"

// -----------------------------------------------------------------------------
// MARK: - DataKitManagerProtocol
/**
 DataKitManager
 
 A protocol that all our data storage methods will conform to so that we can
 use a consistent API when accessing our data
 */
protocol DataKitManager {
  func add(object anObject: NSObject)
  func reset()
  func currentList() -> NSMutableArray
}


// -----------------------------------------------------------------------------
// MARK: - Local DefaultsManager
/**
 LocalDefaultsManager
 
 Store NSUserDefaults in local defaults in app group suite
 */
open class LocalDefaultsManager: DataKitManager {
  open static let sharedInstance = LocalDefaultsManager()
  
  let sharedDefaults: UserDefaults?
  var favorites: NSMutableArray?
  
  init() {
    sharedDefaults = UserDefaults(suiteName: sharedAppGroup)
    //print(sharedDefaults?.dictionaryRepresentation())
  }
  
  open func add(object anObject: NSObject) {
    let current: NSMutableArray = currentList()
    current.add(anObject)
    sharedDefaults?.set(current, forKey: favoritesKey)
    sharedDefaults?.synchronize()
  }
  
  open func currentList() -> NSMutableArray {
    var current: NSMutableArray = []
    if let tempNames: NSArray = sharedDefaults?.array(forKey: favoritesKey) as NSArray? {
      current = tempNames.mutableCopy() as! NSMutableArray
    }
    return current
  }
  
  open func reset() {
    sharedDefaults?.set(NSMutableArray(), forKey: favoritesKey)
    sharedDefaults?.synchronize()
  }
}

// -----------------------------------------------------------------------------
// MARK: - UbiquityDefaultsManager
/**
 iCloudDefaultsManager
 Store in iCloud Key-Value Storage
 */
open class UbiquityDefaultsManager: DataKitManager {
  
  open func add(object anObject: NSObject) {}
  open func currentList() -> NSMutableArray { return NSMutableArray()}
  open func reset() {}
}

// -----------------------------------------------------------------------------
// MARK: - ClouldKitManager
/**
 CloudKitManager
 Store in CloudKit and sync with NSUserDefauls in app group
 */
open class CloudKitManager: DataKitManager {
  open static let sharedInstance = CloudKitManager()
  
  
  let sharedDefaults: UserDefaults?
  var favorites: NSMutableArray?
  
  var container : CKContainer
  var publicDB : CKDatabase
  let privateDB : CKDatabase
  
  init() {
    sharedDefaults = UserDefaults(suiteName: sharedAppGroup)
    //print(sharedDefaults?.dictionaryRepresentation())
    // Cloud Kit
    container = CKContainer.default()
    publicDB = container.publicCloudDatabase
    privateDB = container.privateCloudDatabase
  }
  
  open func add(object anObject: NSObject) {

    
    let objDictionary = anObject as! NSDictionary
    
    // Save to ClouldKit
    let record = CKRecord(recordType: "Instagram")
    record.setValue(objDictionary["favorite"] as! Int, forKey:"favorite")
    record.setValue(objDictionary["timestamp"] as! Int, forKey:"timestamp")
 
    //do the image
    let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] 
    let imageFilePath = documentDirectory.stringByAppendingPathComponent("lastimage")
    let nsDataImage = objDictionary["imageView"] as! Data
    let a  = UIImage(data: nsDataImage)
    // NSTemporaryDirectory().stringByAppendingPathComponent("instagram.igo"
    try? UIImagePNGRepresentation(a!)!.write(to: URL(fileURLWithPath: imageFilePath), options: [.atomic])
    let asset = CKAsset(fileURL: URL(fileURLWithPath: imageFilePath))
  
    record.setObject(asset, forKey: "imageView")

    let documentDirectory1 = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let imageFilePath1 = documentDirectory1.stringByAppendingPathComponent("newThumbnail")
    let nsDataImage1 = objDictionary["thumbnail"] as! Data
 //print(nsDataImage1)
    let a1  = UIImage(data: nsDataImage1)
    // NSTemporaryDirectory().stringByAppendingPathComponent("instagram.igo"
    try? UIImagePNGRepresentation(a1!)!.write(to: URL(fileURLWithPath: imageFilePath1), options: [.atomic])
    let asset1 = CKAsset(fileURL: URL(fileURLWithPath: imageFilePath1))
    
    record.setObject(asset1, forKey: "thumbnail")
    //mySaveRecord.setObject(asset, forKey: "ProfilePicture")
    CKContainer.default().publicCloudDatabase.save(record, completionHandler: {
      record, error in
      if error != nil {
        print("\(error)")
      } else {
        print("Saved")
      }
    })
    
    
//    publicDB.saveRecord(record, completionHandler: { (record, error) -> Void in
//      NSLog("Saved to cloud kit")
//    })
    
    
  }
  

  
  
  open func currentList() -> NSMutableArray {
    var current: NSMutableArray = []
    if let tempNames: NSArray = sharedDefaults?.array(forKey: favoritesKey) as NSArray? {
      current = tempNames.mutableCopy() as! NSMutableArray
    }
    return current
  }
  
  open func reset() {
    sharedDefaults?.set(NSMutableArray(), forKey: favoritesKey)
    sharedDefaults?.synchronize()
  }
  

   open func syncList(_ completion: @escaping (_ results: NSArray) -> Void) {
    let predicate = NSPredicate(value: true)
    let query = CKQuery(recordType: "Instagram", predicate: predicate)
    query.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
    

    publicDB.perform(query, inZoneWith: nil) {
      results, error in
   
      if error != nil {
          print("There is an error:\(error)")
        } else {
            DispatchQueue.main.async {
            let resultsArray = results! as NSArray
     // Copy these results to NSUserDefaults and then send back the completion handler
     // We will always read the NSUserDefaults as the "true" data
              completion(resultsArray)
        }
      }
    }
   }
   
   
   

  open func sync(_ completion: @escaping (_ results: NSArray) -> Void) {
    let predicate = NSPredicate(value: true)
    let query = CKQuery(recordType: "Instagram", predicate: predicate)
    
    publicDB.perform(query, inZoneWith: nil) {
      results, error in
      
      if error != nil {
        print("There is an error:\(error)")
      } else {
        DispatchQueue.main.async {
          let resultsArray = results! as NSArray
          // Copy these results to NSUserDefaults and then send back the completion handler
          // We will always read the NSUserDefaults as the "true" data
          completion(resultsArray)
        }
      }
    }
  }
}


extension String {
  
  func stringByAppendingPathComponent(_ path: String) -> String {
    
    let nsSt = self as NSString
    
    return nsSt.appendingPathComponent(path)
  }
}

