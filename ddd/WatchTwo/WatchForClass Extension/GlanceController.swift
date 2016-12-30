//
//  GlanceController.swift
//  WatchForClass Extension
//
//  Created by Michael on 5/5/16.
//  Copyright © 2016 Mike S. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class GlanceController: WKInterfaceController {
 
  @IBOutlet var glanceImage: WKInterfaceImage!
  let session = WCSession.default()
  
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
      // Configure interface objects here.
      if (WCSession.isSupported()) {
        session.delegate = self
        session.activate()
      }
      
      //no context, check user defaults
      let userDefaults = UserDefaults.standard
      if let _ =  userDefaults.object(forKey: "favImage1") {
      
        let localImage = userDefaults.object(forKey: "favImage1") as! Data
        let favImage = UIImage(data: localImage)
        
        self.glanceImage.setImage(favImage)
        
        
      }
      
      //no image favorited yet, use a stock image
      else {
        
        let favImage = UIImage(named: "afternoon") 
        
        self.glanceImage.setImage(favImage)
        
      }
      
      
   

      
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
      
      
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}

extension GlanceController: WCSessionDelegate {
  
  /// Handle application context sent from the iOS app
  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    //NSLog("didReceiveApplicationContext: \(applicationContext)")
    DispatchQueue.main.async {
      // self.nameLabel.setText(applicationContext["text"] as? String)
      
      print("DEFAULTS: \(UserDefaults.standard.dictionaryRepresentation())")
      let favData = applicationContext["favImage"] as? Data
      let userDefaults = UserDefaults.standard
      userDefaults.set(favData, forKey:"favImage1")
      userDefaults.synchronize()

     // print("DEFAULTS AFTER: \(NSUserDefaults.standardUserDefaults().dictionaryRepresentation())")
      
      let favImage = UIImage(data: favData!)
      
      self.glanceImage.setImage(favImage)
      

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
