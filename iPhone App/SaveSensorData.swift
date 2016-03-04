//
//  SaveSensorData.swift
//  FE_iOS2
//
//  Created by TsuchiyaYosuke on 2016/02/19.
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
import CoreData
import UIKit


class SaveSensorData:NSObject {
    
    
    override init() {
        
    }
    
    func SaveToCoreDataTable(get_date:NSDate, get_latitude:NSNumber, get_longitude:NSNumber, get_useraddType:String, SensorArray: [String]){
        
        
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let myContext: NSManagedObjectContext = appDel.managedObjectContext
        let myEntity: NSEntityDescription! = NSEntityDescription.entityForName("SensorLog", inManagedObjectContext: myContext)
        
        let newData = SensorLog(entity: myEntity, insertIntoManagedObjectContext: myContext)
        
        newData.date = get_date
        newData.latitude = get_latitude
        newData.longitude = get_longitude
        
        newData.useradd = Float(SensorArray[0])!
        newData.temperture = Float(SensorArray[1])!
        newData.barometer = Float(SensorArray[2])!
        newData.humidity = Float(SensorArray[3])!
        
        newData.light = Float(SensorArray[4])!
        
        newData.useraddtype = get_useraddType
        
        newData.accx = Float(SensorArray[5])!
        newData.accy = Float(SensorArray[6])!
        newData.accz = Float(SensorArray[7])!
        
        newData.gyrox = Float(SensorArray[8])!
        newData.gyroy = Float(SensorArray[9])!
        newData.gyroz = Float(SensorArray[10])!
        
        newData.mgtx = Float(SensorArray[11])!
        newData.mgty = Float(SensorArray[12])!
        newData.mgtz = Float(SensorArray[13])!
        
        appDel.saveContext()
        
        
        
        
    }
    
    
}