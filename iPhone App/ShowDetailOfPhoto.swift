//
//  ShowDetailOfPhoto.swift
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
import UIKit
import Photos
import CoreData

class ShowDetailOfPhoto: UIViewController {
    
    
    let dir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0].stringByAppendingPathComponent("photo/original")
    
    var filename:String!
    var BackButton: UIButton!
    var iv: UIImageView!
    
    var img: UIImage!
    var imageWidth:CGFloat = 0.0
    var imageHeight:CGFloat = 0.0
    var latitudeLabel: UILabel = UILabel()
    var longitudeLabel: UILabel = UILabel()
    var dateLabel: UILabel = UILabel()
    var filenameLabel: UILabel = UILabel()
    var tempertureLabel:UILabel = UILabel()
    var BarometerLabel:UILabel = UILabel()
    var humidityLabel:UILabel = UILabel()
    var useraddSensorLabel:UILabel = UILabel()
    var lightLabel:UILabel = UILabel()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        
        
        
        
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setImage(){
        
        let path = dir.stringByAppendingPathComponent(filename)
        img = UIImage(contentsOfFile: path)
        
        let screenWidth = self.view.bounds.width
        let screenHeight = self.view.bounds.height
        imageWidth = img.size.width
        imageHeight = img.size.height
        
        iv = UIImageView(image: img)
        //myImageView.contentMode = .ScaleAspectFit
        let scale = screenWidth / imageWidth
        let rect:CGRect = CGRectMake(0, 0, imageWidth*scale, imageHeight*scale)
        iv.frame = rect
        iv.center = CGPointMake(screenWidth/2, screenHeight/2)
        
        self.view.addSubview(iv)
        
        // ボタンの生成
        BackButton = UIButton()
        BackButton = UIButton(frame: CGRectMake(10,20,50,50))
        BackButton.backgroundColor = UIColor(hue: 100, saturation: 1.0, brightness: 1.0, alpha: 0.5)
        BackButton.layer.masksToBounds = true
        BackButton.setTitle("BACK", forState: UIControlState.Normal)
        BackButton.layer.cornerRadius = 2.0
        BackButton.tag = 1
        BackButton.addTarget(self, action: "back", forControlEvents: .TouchUpInside)
        self.view.addSubview(BackButton)
        
        // ラベルの生成
        dateLabel.frame = CGRectMake(80, 20, 200, 15)
        dateLabel.font = UIFont.systemFontOfSize(12)
        self.view.addSubview(dateLabel)
        
        latitudeLabel.frame = CGRectMake(80, 35, 200, 15)
        latitudeLabel.font = UIFont.systemFontOfSize(12)
        self.view.addSubview(latitudeLabel)
        
        longitudeLabel.frame = CGRectMake(80, 50, 200, 15)
        longitudeLabel.font = UIFont.systemFontOfSize(12)
        self.view.addSubview(longitudeLabel)
        
        tempertureLabel.frame = CGRectMake(80, 65, 300, 15)
        tempertureLabel.font = UIFont.systemFontOfSize(12)
        self.view.addSubview(tempertureLabel)
        
        BarometerLabel.frame = CGRectMake(80, 80, 300, 15)
        BarometerLabel.font = UIFont.systemFontOfSize(12)
        self.view.addSubview(BarometerLabel)
        
        humidityLabel.frame = CGRectMake(80, 95, 300, 15)
        humidityLabel.font = UIFont.systemFontOfSize(12)
        self.view.addSubview(humidityLabel)
        
        useraddSensorLabel.frame = CGRectMake(80, 110, 300, 15)
        useraddSensorLabel.font = UIFont.systemFontOfSize(12)
        self.view.addSubview(useraddSensorLabel)
        
        lightLabel.frame = CGRectMake(80, 125, 300, 15)
        lightLabel.font = UIFont.systemFontOfSize(12)
        self.view.addSubview(lightLabel)
        
        
        setImageMetaData(filename)
        
    }
    
    func setImageMetaData(filename:String){
        
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if let ImageContext: NSManagedObjectContext = appDel.managedObjectContext {
            
            let entityDiscription = NSEntityDescription.entityForName("ImageData", inManagedObjectContext: ImageContext)
            let fetchRequest = NSFetchRequest()
            fetchRequest.entity = entityDiscription
            let predicate = NSPredicate(format: "filename LIKE %@", filename)
            fetchRequest.predicate = predicate
            
            
            do{
                let results = try ImageContext.executeFetchRequest(fetchRequest)
                for managedObject in results {
                    
                    let output:ImageData = managedObject as! ImageData
                    //print("latitude: \(output.latitude), longitude: \(output.longitude), date: \(output.date), filename: \(output.filename)")
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
                    dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
                    let currentDate:String = dateFormatter.stringFromDate(output.date)
                    
                    dateLabel.text = "Date: " + currentDate
                    latitudeLabel.text = "Latitude: " + String(output.latitude)
                    longitudeLabel.text = "Longitude: " + String(output.longitude)
                    tempertureLabel.text = "Temperture: " + String(output.temperture) + " Celcius degree"
                    BarometerLabel.text = "Barometer: " + String(output.barometer) + " hPa"
                    humidityLabel.text = "Humidity: " + String(output.humidity) + " %"
                    if(output.useraddtype == "uv"){
                        useraddSensorLabel.text = "UV Index: " + String(output.useradd) + " "
                    }else if(output.useraddtype == "sound"){
                        let dB = 20 * log10(Double(output.useradd) / 1.5)
                        useraddSensorLabel.text = "Sound Level: " + String(output.useradd) + " mV " + String(dB) + " db"
                    }

                    

                    lightLabel.text = "LIGHT: " + String(output.useradd) + " "
                    
                    
                }
                
            }catch let error as NSError {
                
                print(error)
            }
            
            /**let ImageRequest: NSFetchRequest = NSFetchRequest(entityName: "ImageData")
            ImageRequest.returnsObjectsAsFaults = false
            
            do{
            let ImageResults: NSArray! = try ImageContext.executeFetchRequest(ImageRequest)
            
            for ResultData in ImageResults {
            
            let data:ImageData = ResultData as! ImageData
            
            if(data.filename == filename){
            print("latitude: \(data.latitude) longitude: \(data.longitude) date: \( data.date)")
            
            }
            
            }
            
            }catch let error as NSError {
            print(error)
            } **/
            
            
        } else {
            
            print("Core Data Read Error")
            
        }
        
        
        
        
    }
    
    
    
    
    
    
    
    
    func back(){
        
        img = UIImage()
        filename = ""
        
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}