//
//  Networking.swift
//  WatchTwo
//
//  Created by Michael on 5/5/16.
//  Copyright © 2016 Mike S. All rights reserved.
//

import Foundation


///This class is not used however it also comes from Andrews notes

open class Networking {
  
  open static let sharedInstance = Networking()
  
  let name = "name"
  
  // MARK: - Initilization
  init() {
    print("Initializing Singleton");
  }
  
  
  
  // MARK: - Post
  
  // MARK: - Request
  /**
   Creates a request for the specified method, URL string, parameters, and parameter encoding.
   
   - parameter method: The HTTP method.
   - parameter URLString: The URL string.
   - parameter parameters: The parameters. `nil` by default.
   - parameter encoding: The parameter encoding. `.URL` by default.
   
   - returns: The created request.
   */
  open func get(_ request: URLRequest!, callback: @escaping (String, String?) -> Void) {
    
    let session = URLSession.shared
    let task = session.dataTask(with: request, completionHandler: {
      (data, response, error) -> Void in
      if error != nil {
        callback("", error!.localizedDescription)
      } else {
        let result = NSString(data: data!, encoding: String.Encoding.ascii.rawValue)!
        callback(result as String, nil)
      }
    })
    task.resume()
  }
  
  
}
