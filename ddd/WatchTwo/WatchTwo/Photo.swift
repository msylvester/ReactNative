//
//  Photo.swift
//  WatchTwo
//
//  Created by Michael on 5/12/16.
//  Copyright © 2016 Mike S. All rights reserved.
//

import UIKit
import CoreImage
import DataKit
import WatchKit
import WatchConnectivity
import CoreGraphics
import ImageIO

/** 
 
 This class manages the photo page it does the following:
 1.  Loads a photo from the local camera storage on the phone
 2.  Adds a filter via the touch of a button
 3.  Cretes a thumnbnail when save is pressed.  This also sends the image to the watch in addition to saving to cloudkit
 4.  Adds a moustache
 

 
 */

class Photo: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{

  //MARK: Properties
  var imagePicker: UIImagePickerController!

  @IBOutlet weak var thumbnail: UIImageView!
  @IBOutlet weak var imageView: UIImageView!


  
  override func viewDidLoad() {
        super.viewDidLoad()
  
    }

  override func viewWillAppear(_ animated: Bool) {
    
    // Do any additional setup after loading the view.
    if WCSession.isSupported() {
      WCSession.default().delegate = self
      WCSession.default().activate()
    }

  }
  
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  
  
 
  @IBAction func tapSave(_ sender: AnyObject) {
    //for time stamp
    let timeInterval = Date().timeIntervalSince1970
    
    //for scaledImage
    var scaledImage = UIImage()
    
    
    //this block creates a scaled thumbnail
    //-Attributions: http://nshipster.com/image-resizing/
    if let image = imageView.image {
      
      
      let imageData = UIImagePNGRepresentation(image)

      
      
      
        if let imageSource = CGImageSourceCreateWithData(imageData! as CFData, nil){
          let options: [NSString: NSObject] = [
            kCGImageSourceThumbnailMaxPixelSize: max(imageView.frame.width, imageView.frame.height) / 10.0,
            kCGImageSourceCreateThumbnailFromImageAlways: true
          ]
          
          scaledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary?).flatMap { UIImage(cgImage: $0) }!
          

          thumbnail.image = scaledImage
    }
    
      
    //create a NSDictionary to add to the cloud
    let sharedItem: NSDictionary = [ "favorite": 0,
                                     "timestamp": timeInterval,
                                     "imageView": ((UIImagePNGRepresentation(image)))!,
                                     "thumbnail":((UIImagePNGRepresentation(scaledImage)))!
                                      ]
 
    CloudKitManager.sharedInstance.add(object: sharedItem)
    
    
    //get the NSData of the thumbnail image and send to the watch
    let a  = ((UIImagePNGRepresentation(scaledImage)))!
    print(a)
    do {
      let applicationDict = ["image":a]
      try WCSession.default().updateApplicationContext(applicationDict)
      print("this worked")
      
    } catch {
      // Handle errors here
      print(error)
    }
    
      
     
      
    }
    
  }
  
  
  ///takePhoto: Actually loads photo from library, this was done for testing, since I don't own a wath
  @IBAction func takePhoto(_ sender: AnyObject) {
    
    imagePicker =  UIImagePickerController()
    imagePicker.delegate = self
    //imagePicker.sourceType = .Camera
    imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
    present(imagePicker, animated: true, completion: nil)
    
  
  }
  
  
  ///tapFilter:  Applys a filter aysynchrnoulsy
  ///attributions: http://www.appcoda.com/core-image-introduction/
  @IBAction func tapFilter(_ sender: AnyObject) {
   
 DispatchQueue.main.async {
      guard let filteredImage = self.imageView?.image, let cgimg = filteredImage.cgImage else {
        print("imageView doesn't have an image!")
        return
      }
      
      let openGLContext = EAGLContext(api: .openGLES2)
      let context = CIContext(eaglContext: openGLContext!)
 
        
        
      let coreImage = CIImage(cgImage: cgimg)
  
      let falseColor = CIFilter(name: "CIFalseColor",
                            withInputParameters: [
                              kCIInputImageKey: coreImage,
                              "inputColor0": CIColor(red: 0.15, green: 0.15, blue: 1),
                              "inputColor1": CIColor(red: 1, green: 1, blue: 0.5)])!.outputImage!
  
  
  
      let filter = CIFilter(name: "CIVignette")
      filter?.setValue(coreImage, forKey: kCIInputImageKey)
      filter?.setValue(0.5, forKey: kCIInputIntensityKey)
      filter?.setValue(falseColor, forKey: kCIInputImageKey)
      
      if let output = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
        let cgimgresult = context.createCGImage(output, from: output.extent)
        let filteredImage = UIImage(cgImage: cgimgresult!)
        self.imageView?.image = filteredImage
      }
        
      else {
        print("image filtering failed")
      }
      
      
      
   }
    

      
  
  }

  ///addMoustache: adds a moustache to an image if a face exists
  ///-Attributions:  Nick Pann
  
  @IBAction func addMoustache(_ sender: AnyObject) {
  
    let facePic = CIImage(image: imageView.image!)
    let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil,
                                  
                                  options: [CIDetectorAccuracy: CIDetectorAccuracyHigh,
                                    
                                    CIDetectorTracking: false, CIDetectorMinFeatureSize: NSNumber(value: 0.1 as Float)])

    let faces = faceDetector?.features(in: facePic!, options: [CIDetectorEyeBlink: true, CIDetectorSmile: true])
    
    if let face = faces?.first as? CIFaceFeature {
      
      print("Found face at \(face.bounds)")
   
      
      if face.hasMouthPosition {
        
        print("Found mouth at \(face.mouthPosition)")
        
        let mustacheImage = UIImage(named: "moustache")
        let mustacheView = UIImageView(image: mustacheImage)
        let mustacheWidth = face.bounds.width * 0.7
        let mustacheHeight = face.bounds.height * 0.3
        mustacheView.frame = CGRect(x: face.mouthPosition.x, y: abs(imageView.frame.height - face.mouthPosition.y), width: mustacheWidth, height: mustacheHeight)
        print(mustacheView.frame)
        imageView.addSubview(mustacheView)
        let mergedImage = imageView.capture()
        imageView.image = mergedImage
        
      }
      
      else {
        
        let alertController = UIAlertController(title: "No Moustachio", message: "👨🏻", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
        
      }
      
    }
    else {
      
      let alertController = UIAlertController(title: "No Moustachio", message: "👨🏻", preferredStyle: .alert)
      
      let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      alertController.addAction(defaultAction)
      
      present(alertController, animated: true, completion: nil)
    }
    
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    imagePicker.dismiss(animated: true, completion: nil)
    imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
  }

  

}


///recieve info from the phone if need be
extension Photo: WCSessionDelegate {
  
  /// Handle application context sent from the iOS app
  func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    NSLog("didReceiveApplicationContext: \(applicationContext)")
  }
  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    NSLog("didReceiveMessage: \(message)")
  }
  
}

///extension to allow merging images
extension UIView {
  func capture() -> UIImage {
    UIGraphicsBeginImageContextWithOptions(self.frame.size, self.isOpaque, UIScreen.main.scale)
    self.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
  }
}

