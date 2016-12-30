//
//  AppDelegate.swift
//  WatchTwo
//
//  Created by Michael on 5/5/16.
//  Copyright © 2016 Mike S. All rights reserved.
//

import UIKit
import CoreData
import CloudKit
import DataKit
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    //LocalDefaultsManager.sharedInstance.reset()

    let themeColor = UIColor(red: 0.01, green: 0.41, blue: 0.22, alpha: 1.0)
    
    let settings = UIUserNotificationSettings(types: [.alert,.badge,.sound], categories: nil)
    application.registerUserNotificationSettings(settings)
    application.registerForRemoteNotifications() // only need this for background modes
    cloudKitSubscriptions()
    
    
    
    window?.tintColor = themeColor
    return true
 
 
  
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    self.saveContext()
  }

  // MARK: - Core Data stack

  lazy var applicationDocumentsDirectory: URL = {
      // The directory the application uses to store the Core Data store file. This code uses a directory named "devdesign.WatchTwo" in the application's documents Application Support directory.
      let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
      return urls[urls.count-1]
  }()

  lazy var managedObjectModel: NSManagedObjectModel = {
      // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
      let modelURL = Bundle.main.url(forResource: "WatchTwo", withExtension: "momd")!
      return NSManagedObjectModel(contentsOf: modelURL)!
  }()

  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
      // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
      // Create the coordinator and store
      let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
      let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
      var failureReason = "There was an error creating or loading the application's saved data."
      do {
          try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
      } catch {
          // Report any error we got.
          var dict = [String: AnyObject]()
          dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
          dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

          dict[NSUnderlyingErrorKey] = error as NSError
          let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
          // Replace this with code to handle the error appropriately.
          // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
          NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
          abort()
      }
      
      return coordinator
  }()

  lazy var managedObjectContext: NSManagedObjectContext = {
      // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
      let coordinator = self.persistentStoreCoordinator
      var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
      managedObjectContext.persistentStoreCoordinator = coordinator
      return managedObjectContext
  }()

  // MARK: - Core Data Saving support

  func saveContext () {
      if managedObjectContext.hasChanges {
          do {
              try managedObjectContext.save()
          } catch {
              // Replace this implementation with code to handle the error appropriately.
              // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
              let nserror = error as NSError
              NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
              abort()
          }
      }
  }


///This notifications code comes from Andres
  
  
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
  
  let cloudKitNotification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])
  print("CloudKit Notification: \(cloudKitNotification)")
  if cloudKitNotification.notificationType == .query {
    let queryNotification = cloudKitNotification as! CKQueryNotification
    if queryNotification.queryNotificationReason == .recordDeleted {
      // If the record has been deleted in CloudKit then delete the local copy here
    } else {
   
    }
  }
}


func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                 fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
  // Do stuff
  print("Received Push notification: \(userInfo)")
  showAlertForNotification(userInfo)
  completionHandler(UIBackgroundFetchResult.noData)
}

///
/// Subscribe to CloudKit notifications
func cloudKitSubscriptions() {
  
  let predicate = NSPredicate(format: "TRUEPREDICATE")
  let subscription = CKSubscription(recordType: "Instagram", predicate: predicate,
                                    options: [.firesOnRecordCreation])
  let publicDatabase = CKContainer.default().publicCloudDatabase
  
  let notification = CKNotificationInfo()
  notification.alertBody = "There's a great new timestamp for you to read."
  notification.soundName = UILocalNotificationDefaultSoundName
  subscription.notificationInfo = notification
  
  publicDatabase.save(subscription, completionHandler: { (subscription: CKSubscription?, error: NSError?) -> Void in
    guard error == nil else {
      print(error)
      return
    }
    // TODO: Save that we have subscribed successfully to keep track and avoid trying to subscribe again
  } as! (CKSubscription?, Error?) -> Void) 
  
}


//
// MARK: - Notifications Support
//

/// Create an alert to show if the application is active and receives a local
/// notification
/// - parameter notification: The `UILocalNotification` received
func showAlertForNotification(_ userInfo: [AnyHashable: Any]) {
  
  // Do not show unless the application is active
  guard UIApplication.shared.applicationState == .active else { return }
  
  // Create the alert
  let alertController = UIAlertController(title: "Recieved Notification",
                                          message: userInfo.description,
                                          preferredStyle: .alert)
  
  // Create cancel action that does nothing
  let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
  alertController.addAction(cancelAction)
  
  // Show the alert and exit early
  self.window?.rootViewController?.present(alertController,
                                                         animated: true,
                                                         completion: nil)
  //let vc = window?.rootViewController as? ViewController
  //vc?.refreshTable()
}


}


extension UIColor {
  class func randomColor(_ hue:CGFloat? = ( CGFloat( CGFloat(arc4random()).truncatingRemainder(dividingBy: 256) / 256.0 ) ),
                         saturation:CGFloat? = ( CGFloat( CGFloat(arc4random()).truncatingRemainder(dividingBy: 128) / 256.0 ) + 0.5 ),
                         brightness:CGFloat? = ( CGFloat( CGFloat(arc4random()).truncatingRemainder(dividingBy: 128) / 256.0 ) + 0.5 ),
                         alpha:CGFloat? = CGFloat(1.0)) -> UIColor {
    return UIColor(hue: hue!, saturation: saturation!, brightness: brightness!, alpha: alpha!);
  }
}



