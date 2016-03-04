//
//  SensorLog.swift
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

import UIKit
import CoreData

@objc(SensorLog)
class SensorLog: NSManagedObject {

    @NSManaged var date:NSDate
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var temperture: NSNumber
    @NSManaged var barometer: NSNumber
    @NSManaged var humidity: NSNumber
    @NSManaged var light: NSNumber
    @NSManaged var useradd: NSNumber
    @NSManaged var useraddtype: String
    @NSManaged var accx: NSNumber
    @NSManaged var accy: NSNumber
    @NSManaged var accz: NSNumber
    @NSManaged var gyrox: NSNumber
    @NSManaged var gyroy: NSNumber
    @NSManaged var gyroz: NSNumber
    @NSManaged var mgtx: NSNumber
    @NSManaged var mgty: NSNumber
    @NSManaged var mgtz: NSNumber
    
    
}