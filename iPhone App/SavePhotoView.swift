//
//  SavePhotoView.swift
//  FE_iOS2
//
//  Created by TsuchiyaYosuke on 2016/02/15.
//  Copyright © 2016 Yosuke Tsuchiya
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//

import Foundation

import Foundation
import UIKit
import Photos
import CoreImage
import CoreData

class SavePhotoView:UIViewController, CLLocationManagerDelegate {
    
    var image:UIImage = UIImage()
    var imageData:NSData = NSData()
    var myImageView: UIImageView = UIImageView()
    
    var retakeButton: UIButton!
    var saveButton: UIButton!
    
    var LandScape: Bool = false
    var outputImage: UIImage!
    var outputCIImage: CIImage!
    
    var outputThumbImage: UIImage!
    var outputThumbCIImage: CIImage!
    
    var imageContext = CIContext(options: nil)
    var thumbImageContext = CIContext(options: nil)
    
    var assetAlbum:PHAssetCollection!
    
    var request: PHCollectionListChangeRequest!
    
    var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let fileManager = NSFileManager.defaultManager()
    //
    //let dir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0].stringByAppendingPathComponent("photo")
    let originalDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0].stringByAppendingPathComponent("photo/original")
    let thumbnailDir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0].stringByAppendingPathComponent("photo/thumb")
    
    
    
    var myLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Core Location
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        
        let status = CLLocationManager.authorizationStatus()
        if(status == CLAuthorizationStatus.NotDetermined){
            self.myLocationManager.requestAlwaysAuthorization()
        }
        
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        myLocationManager.distanceFilter = 100
        
        
        print(LandScape)
        
        var imageWidth:CGFloat = 0.0
        var imageHeight:CGFloat = 0.0
        let screenWidth: CGFloat = self.view.bounds.width
        let screenHeight: CGFloat = self.view.bounds.height
        
        
        PHPhotoLibrary.requestAuthorization{(status)->Void in
            
            switch(status){
            case .Authorized:
                print("Authorized")
                
            case .Denied:
                print("Denied")
                
            case .NotDetermined:
                print("NotDetermined")
                
            case .Restricted:
                print("Ristricted")
                
            }
        }
        
        let Filters: CIFilter = CIFilter(name: "CILanczosScaleTransform")!
        let ThumbResizeFilter: CIFilter = CIFilter(name: "CILanczosScaleTransform")!
        let ThumbCropFilter: CIFilter = CIFilter(name: "CICrop")!
        let thumbWidth = self.view.bounds.width
        let thumbHeight = (thumbWidth / 4) * 3
        
        if(LandScape){
            //myImageView.image = UIImage(CGImage: image.CGImage!,scale:1.0,orientation:UIImageOrientation.Right)
            
            //outputImage = UIImage(CGImage: image.CGImage!,scale:1.0,orientation:UIImageOrientation.Right)
            //imageWidth = outputImage.size.width
            //imageHeight = outputImage.size.height
            
            let tmpUIImage:UIImage = UIImage(CGImage: image.CGImage!, scale: 1.0, orientation: UIImageOrientation.Right)
            let tmpImage:CIImage = CIImage(CGImage: tmpUIImage.CGImage!)
            
            Filters.setValue(tmpImage, forKey: kCIInputImageKey)
            Filters.setValue(tmpImage, forKey: kCIInputImageKey)
            //Filters.setValue(NSNumber(double: val), forKey: kCIInputScaleKey)
            
            //Filters.setValue(NSNumber(double:1.0), forKey: kCIInputAspectRatioKey)
            
            outputCIImage = Filters.outputImage!
            
            outputImage = UIImage(CIImage: outputCIImage)
            
            imageWidth = outputImage.size.width
            imageHeight = outputImage.size.height
            
            // サムネイル生成：リサイズ
            ThumbResizeFilter.setValue(outputCIImage, forKey: kCIInputImageKey)
            ThumbResizeFilter.setValue(outputCIImage, forKey: kCIInputImageKey)
            
            let scales:Float = Float(thumbWidth / imageWidth)
            ThumbResizeFilter.setValue(NSNumber(float: scales), forKey: kCIInputScaleKey)
            ThumbResizeFilter.setValue(NSNumber(float: 1.0), forKey: kCIInputAspectRatioKey)
            let tmpThumbImage:CIImage = ThumbResizeFilter.outputImage!
            let tmpThumbUIImage: UIImage = UIImage(CIImage: tmpThumbImage)
            
            // サムネイル生成：クロップ
            ThumbCropFilter.setValue(tmpThumbImage, forKey: kCIInputImageKey)
            let cropX = (CGImageGetWidth(tmpThumbUIImage.CGImage) / 2) - Int(thumbWidth / 4)
            let cropY = (CGImageGetHeight(tmpThumbUIImage.CGImage) / 2) - Int(thumbHeight / 4)
            print(cropX,cropY,thumbWidth,thumbHeight)
            ThumbCropFilter.setValue(CIVector(x: CGFloat(cropX), y: CGFloat(cropY), z: thumbWidth, w: thumbHeight), forKey: "inputRectangle")
            
            outputThumbCIImage = ThumbCropFilter.outputImage
            outputThumbImage = UIImage(CIImage: outputThumbCIImage)
            
            
            
            
        }else{
            
            
            outputImage = image
            imageWidth = outputImage.size.width
            imageHeight = outputImage.size.height
            
            let tmpImage:CIImage = CIImage(CGImage: outputImage.CGImage!)
            
            // サムネイル生成：リサイズ
            ThumbResizeFilter.setValue(tmpImage, forKey: kCIInputImageKey)
            ThumbResizeFilter.setValue(tmpImage, forKey: kCIInputImageKey)
            
            let scales:Float = Float(thumbWidth / imageWidth)
            ThumbResizeFilter.setValue(NSNumber(float: scales), forKey: kCIInputScaleKey)
            ThumbResizeFilter.setValue(NSNumber(float: 1.0), forKey: kCIInputAspectRatioKey)
            let tmpThumbImage:CIImage = ThumbResizeFilter.outputImage!
            let tmpThumbUIImage: UIImage = UIImage(CIImage: tmpThumbImage)
            
            // サムネイル生成：クロップ
            ThumbCropFilter.setValue(tmpThumbImage, forKey: kCIInputImageKey)
            let cropX = (CGImageGetWidth(tmpThumbUIImage.CGImage) / 2) - Int(thumbWidth / 4)
            let cropY = (CGImageGetHeight(tmpThumbUIImage.CGImage) / 2) - Int(thumbHeight / 4)
            ThumbCropFilter.setValue(CIVector(x: CGFloat(cropX), y: CGFloat(cropY), z: thumbWidth, w: thumbHeight), forKey: "inputRectangle")
            
            outputThumbCIImage = ThumbCropFilter.outputImage
            outputThumbImage = UIImage(CIImage: outputThumbCIImage)
            
        }
        
        print(imageWidth,imageHeight)
        myImageView = UIImageView(image: outputImage)
        //myImageView.contentMode = .ScaleAspectFit
        let scale = screenWidth / imageWidth
        let rect:CGRect = CGRectMake(0, 0, imageWidth*scale, imageHeight*scale)
        myImageView.frame = rect
        myImageView.center = CGPointMake(screenWidth/2, screenHeight/2)
        
        self.view.addSubview(myImageView)
        
        
        // ボタンの生成
        saveButton = UIButton()
        saveButton = UIButton(frame: CGRectMake(0,0,120,50))
        saveButton.backgroundColor = UIColor(hue: 0.5, saturation: 1.0, brightness: 1.0, alpha: 0.5)
        saveButton.layer.masksToBounds = true
        saveButton.setTitle("SAVE", forState: UIControlState.Normal)
        saveButton.layer.cornerRadius = 2.0
        saveButton.tag = 1
        saveButton.layer.position = CGPoint(x: self.view.bounds.width/2 - 70, y: self.view.bounds.height - 100)
        saveButton.addTarget(self, action: "saved", forControlEvents: .TouchUpInside)
        self.view.addSubview(saveButton)
        
        // Retakeボタンの生成
        retakeButton = UIButton(frame: CGRectMake(0,0, 120,50 ))
        retakeButton.backgroundColor = UIColor(hue: 0.5, saturation: 1.0, brightness: 1.0, alpha: 0.5)
        retakeButton.layer.masksToBounds = true
        retakeButton.setTitle("RETAKE", forState: UIControlState.Normal)
        retakeButton.layer.cornerRadius = 2.0
        retakeButton.layer.position = CGPoint(x: self.view.bounds.width/2 + 70, y: self.view.bounds.height - 100)
        retakeButton.tag = 1
        retakeButton.addTarget(self, action: "retake", forControlEvents: .TouchUpInside)
        self.view.addSubview(retakeButton)
        
        
        
        
    }
    
    func saved(){
        
        
        // FilterかけたイメージからJPEGを再び生成する
        // CGImageを作ってからじゃないとダメらしい
        // 詳細: stackoverflow.com/questions/29732886/uiimagejpegrepresentation-returns-nil
        //
        // ファイル名
        let NowDate: NSDate = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let currentDate:String = dateFormatter.stringFromDate(NowDate)
        
        if(LandScape){
            let tmpCGImg: CGImageRef = imageContext.createCGImage(outputCIImage, fromRect: outputCIImage.extent)
            if let data = UIImageJPEGRepresentation(UIImage(CGImage: tmpCGImg), 1.0){
                
                //outputImage = UIImage(data: data)!
                
                //UIImageWriteToSavedPhotosAlbum(UIImage(data: data)!, self, nil, nil)
                
                // 保存ディレクトリ
                if !fileManager.fileExistsAtPath(originalDir){
                    do{
                        try fileManager.createDirectoryAtPath(originalDir, withIntermediateDirectories: true, attributes: nil)
                    }
                    catch {
                        print("Unable to create directory: \(error)")
                    }
                }
                
                
                
                let photoname = "\(currentDate).jpg"
                let path = originalDir.stringByAppendingPathComponent(photoname)
                
                // 保存
                if(data.writeToFile(path, atomically: true)){
                    print("saved at \(path)")
                    writeData(NowDate, filename: photoname)
                }else{
                    print("error writing file")
                }
                
                
                
                
                
                
                /**let result = PHAssetChangeRequest.creationRequestForAssetFromImage(UIImage(data: data)!)
                let assetPlaceHolder = result.placeholderForCreatedAsset
                let addassets:NSArray = [assetPlaceHolder!]
                let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: assetAlbum)
                albumChangeRequest?.addAssets(addassets) **/
                
                print("saved")
                
                
                
            }else{
                print("failed")
            }
            
            
            // サムネイル保存
            let tmpThumbCGImg: CGImageRef = thumbImageContext.createCGImage(outputThumbCIImage, fromRect: outputThumbCIImage.extent)
            if let thumbData = UIImageJPEGRepresentation(UIImage(CGImage: tmpThumbCGImg), 1.0){
                
                
                if !fileManager.fileExistsAtPath(thumbnailDir){
                    
                    do{
                        try fileManager.createDirectoryAtPath(thumbnailDir, withIntermediateDirectories: true, attributes: nil)
                    }
                    catch {
                        "Unable to create thumb directory: \(error)"
                    }
                    
                }
                
                let thumb_photoname = "thumb_\(currentDate).jpg"
                let path = thumbnailDir.stringByAppendingPathComponent(thumb_photoname)
                
                if(thumbData.writeToFile(path, atomically: true)){
                    print("Thumbnail saved at \(path)")
                    
                    
                    
                    
                    saveFinished()
                    
                }else{
                    print("error writing thumbnail file")
                }
                
                
                
                
            }else{
                print("thumbnail failed")
            }
            
            
            
            
            
            
            
            
        }else{
            
            //UIImageWriteToSavedPhotosAlbum(outputImage, self, nil, nil)
            
            let data:NSData = UIImageJPEGRepresentation(outputImage, 1.0)!
            // 保存ディレクトリ
            if !fileManager.fileExistsAtPath(originalDir){
                do{
                    try fileManager.createDirectoryAtPath(originalDir, withIntermediateDirectories: true, attributes: nil)
                }
                catch {
                    print("Unable to create directory: \(error)")
                }
            }
            
            // ファイル名
            let NowDate: NSDate = NSDate()
            let dateFormatter = NSDateFormatter()
            dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
            dateFormatter.dateFormat = "yyyyMMddHHmmss"
            let currentDate:String = dateFormatter.stringFromDate(NowDate)
            
            var photoname = "\(currentDate).jpg"
            let path = originalDir.stringByAppendingPathComponent(photoname)
            
            // 保存
            if(data.writeToFile(path, atomically: true)){
                print("saved at \(path)")
                writeData(NowDate, filename: photoname)
            }else{
                print("error writing file")
            }
            
            /**let result = PHAssetChangeRequest.creationRequestForAssetFromImage(outputImage)
            let assetPlaceHolder = result.placeholderForCreatedAsset
            let addassets:NSArray = [assetPlaceHolder!]
            let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: assetAlbum)
            albumChangeRequest?.addAssets(addassets) **/
            
            print("www saved")
            
            // サムネイル保存
            let tmpThumbCGImg: CGImageRef = thumbImageContext.createCGImage(outputThumbCIImage, fromRect: outputThumbCIImage.extent)
            if let thumbData = UIImageJPEGRepresentation(UIImage(CGImage: tmpThumbCGImg), 1.0){
                
                
                if !fileManager.fileExistsAtPath(thumbnailDir){
                    
                    do{
                        try fileManager.createDirectoryAtPath(thumbnailDir, withIntermediateDirectories: true, attributes: nil)
                    }
                    catch {
                        "Unable to create thumb directory: \(error)"
                    }
                    
                }
                
                let thumb_photoname = "thumb_\(currentDate).jpg"
                let path = thumbnailDir.stringByAppendingPathComponent(thumb_photoname)
                
                if(thumbData.writeToFile(path, atomically: true)){
                    print("Thumbnail saved at \(path)")
                    
                    saveFinished()
                    
                }else{
                    print("error writing thumbnail file")
                }
                
                
                
                
            }else{
                print("thumbnail failed")
            }
            
            
            
            
        }
        
        
        
        
        
        
    }
    
    
    func image(image: UIImage, didFinishSavingWithError error:NSError!, contextInfo: UnsafeMutablePointer<Void>){
        
        
        if( error != nil){
            print(error.code)
            print("failed save")
        }else{
            print("image saved")
        }
    }
    
    func saveFinished(){
        
        image = UIImage()
        imageData = NSData()
        myImageView = UIImageView()
        
        LandScape = false
        outputImage = UIImage()
        outputCIImage = CIImage()
        
        imageContext = CIContext()
        
        outputThumbImage = UIImage()
        outputThumbCIImage = CIImage()
        thumbImageContext = CIContext()
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    func retake(){
        
        
        saveFinished()
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    func writeData(nowdate:NSDate, filename:String){
        
        let myContext: NSManagedObjectContext = appDelegate.managedObjectContext
        let myEntity: NSEntityDescription! = NSEntityDescription.entityForName("ImageData", inManagedObjectContext: myContext)
        
        myLocationManager.startUpdatingLocation()
        let latitude:Double = Double((myLocationManager.location?.coordinate.latitude)!)
        let longithde:Double = Double((myLocationManager.location?.coordinate.longitude)!)
        
        let newData = ImageData(entity: myEntity, insertIntoManagedObjectContext: myContext)
        
        newData.latitude = latitude
        newData.longitude = longithde
        newData.filename = filename
        newData.date = nowdate
        let TempCount:Int = appDelegate.Temperture_array.count
        let BarometerCount:Int = appDelegate.Barometer_array.count
        let HumidityCount:Int = appDelegate.Humidity_array.count
        let useraddCount:Int = appDelegate.useraddSensor_array.count
        let lightCount:Int = appDelegate.light_array.count
        
        if(TempCount > 0){
            newData.temperture = appDelegate.Temperture_array[TempCount - 1]
        }else{
            newData.temperture = 0.0
        }
        
        if(BarometerCount > 0){
            newData.barometer = appDelegate.Barometer_array[BarometerCount - 1]
        }else{
            newData.barometer = 0.0
        }
        
        if(HumidityCount > 0){
            newData.humidity = appDelegate.Humidity_array[HumidityCount - 1]
        }else{
            newData.humidity = 0.0
        }
        
        if(useraddCount > 0){
            
            newData.useradd = appDelegate.useraddSensor_array[useraddCount - 1]
            
            if(appDelegate.useraddSensor_type == 1){
                newData.useraddtype = "uv"
            }else if(appDelegate.useraddSensor_type == 2){
                newData.useraddtype = "sound"
            }else if(appDelegate.useraddSensor_type == 3){
                newData.useraddtype = "color"
            }
            
        }
        
        if(lightCount > 0){
            newData.light = appDelegate.light_array[lightCount - 1]
        }else{
            newData.light = 0.0
        }
        
        appDelegate.saveContext()
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        print("didChangeAuthorizationStatus");
        
        // 認証のステータスをログで表示.
        var statusStr = "";
        switch (status) {
        case .NotDetermined:
            statusStr = "NotDetermined"
        case .Restricted:
            statusStr = "Restricted"
        case .Denied:
            statusStr = "Denied"
        case .AuthorizedAlways:
            statusStr = "AuthorizedAlways"
        case .AuthorizedWhenInUse:
            statusStr = "AuthorizedWhenInUse"
        }
        print(" CLAuthorizationStatus: \(statusStr)")
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}