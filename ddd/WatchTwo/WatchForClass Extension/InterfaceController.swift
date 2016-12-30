//
//  InterfaceController.swift
//  WatchForClass Extension
//
//  Created by Michael on 5/5/16.
//  Copyright © 2016 Mike S. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


///This is where the magic happens
///Attributions for the table/watch code comes from https://www.raywenderlich.com/117249/watchos-2-tutorial-part-2-tables

class InterfaceController: WKInterfaceController{
  
  //MARK: Properties
  
  @IBOutlet var recentTable: WKInterfaceTable!
  let session = WCSession.default()
  var lists = [Int]()
  
  
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    

    if (WCSession.isSupported()) {
      session.delegate = self
      session.activate()
    }
    
    print("awakeWithContext: \(context)")
    
    //account for if nothing has been saved
    let userDefaults = UserDefaults.standard
    
    if let _: NSArray = userDefaults.array(forKey: "watch") as NSArray? {
      let tempNames = userDefaults.array(forKey: "watch") as! [Data]
      print(tempNames.count)
      self.recentTable.setNumberOfRows(tempNames.count, withRowType: "FlightRow")
      
      if tempNames.count > 0 {
      for i in 0...tempNames.count-1  {
        
          if let row = self.recentTable.rowController(at: i) as? FlightRow {
         
              let image = UIImage(data: tempNames[i])
              row.imageView.setImage(image)

              }
          
          
            }
      }
      
    }
    
    

    
  }
  

  
  override func willActivate() {

     super.willActivate()
 
    
  }
  
  override func didDeactivate() {

    super.didDeactivate()
  }


}

extension InterfaceController: WCSessionDelegate {
  
  /// Handle application context sent from the iOS app
  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    NSLog("didReceiveApplicationContext: \(applicationContext)")
    DispatchQueue.main.async {
  
    //get image from application context
    let images = applicationContext["image"] as? Data
     
    //trying mutable
    let userDefaults = UserDefaults.standard
      
    var current: NSMutableArray = []
    if let tempNames1: NSArray = userDefaults.array(forKey: "watch") as NSArray? {
      
        current = tempNames1.mutableCopy() as! NSMutableArray
        current.add(images!)
        userDefaults.set(current, forKey: "watch")
        userDefaults.synchronize()
      
        //now account for if the watch has greater than 10 images
        var tempNames = userDefaults.array(forKey: "watch") as! [Data]
      
        if (tempNames.count > 10) {
          //remove the first
          tempNames.remove(at: 0)
          userDefaults.set(tempNames, forKey: "watch")
  
        }
      
    }
    else {
        var a = [Data]()
        a.append(images!)
        userDefaults.set(a, forKey:"watch")
      
      }
    let tempNames = userDefaults.array(forKey: "watch") as! [Data]

    self.recentTable.setNumberOfRows(tempNames.count, withRowType: "FlightRow")


    for i in 0...tempNames.count-1  {

      if let row = self.recentTable.rowController(at: i) as? FlightRow {
        
      
        let image = UIImage(data: tempNames[i])
        row.imageView.setImage(image)
        
      
      }


    }
  
  }
  }
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    NSLog("didReceiveMessage: \(message)")
    DispatchQueue.main.async {
     // self.nameLabel.setText(message["text"] as? String)
    }
    //WKInterfaceDevice.currentDevice().playHaptic(.Notification)
  }
  
}
