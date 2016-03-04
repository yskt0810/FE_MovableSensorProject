//
//  BLEConnection.swift
//  FE_iOS2
//
//  Created by TsuchiyaYosuke on 2016/01/31.
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
import CoreBluetooth
import CoreLocation
import UIKit

class BLEConnection:NSObject,CBPeripheralDelegate,CLLocationManagerDelegate {
    
    var CurrentServiceUuids: NSMutableArray = NSMutableArray()
    var CurrentService: NSMutableArray = NSMutableArray()
    var CurrentCharacteristics: NSMutableArray = NSMutableArray()
    var CurrentCharacteristicUuids: NSMutableArray = NSMutableArray()
    
    var TargetPeripheral:CBPeripheral!
    var CurrentCentralManager: CBCentralManager!
    var targetService: CBService!
    var targetCharacteristics: CBCharacteristic!
    
    var BLESerial2_service: String = "BD011F22-7D3C-0DB6-E441-55873E44EF40";
    //                                BD011F22-7D3C-0DB6-E441-55873D44EF40
    
    var BLESerial2_rx: String = "2A750D7D-BD9A-928F-B744-7D5A70CEF1F9";
    var BLESerial2_tx: String = "0503B819-C75B-BA9B-3641-6A7F338DD9BD";
    
    var tmp_data:NSMutableData! = NSMutableData()
    var outputString:String = "";
    
    // Delegateへデータを飛ばす
    var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // HTTP送信用文字列
    var SensorDataSendString: String = ""
    var SendDatatoCloud:SendCloud = SendCloud()
    var SendCount:Int = 0;
    
    // 接続先のPeripheralを設定
    func setPeripheral(target: CBPeripheral){
        self.TargetPeripheral = target
        print(target)
    }
    
    
    // Central Managerを設定
    func setCentralManager(manager: CBCentralManager){
        self.CurrentCentralManager = manager
        print(manager)
    }
    
    // Serviceの検索
    func searchService(){
        print("search Service")
        self.TargetPeripheral.delegate = self
        self.TargetPeripheral.discoverServices(nil)
        
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        print("didDiscoverServices")
        for service in peripheral.services! {
            CurrentServiceUuids.addObject(service.UUID)
            CurrentService.addObject(service)
            //print("P: \(peripheral.name) - Discovered service S:'\(service.UUID)'")
            
        }
        
        for_service: for(var i=0; i < CurrentServiceUuids.count; i++){
            print(CurrentServiceUuids[i])
            print(CBUUID(string: BLESerial2_service))
            
            if(CurrentServiceUuids[i] as! CBUUID == CBUUID(string: "BD011F22-7D3C-0DB6-E441-55873D44EF40")){
                print("IDENTIFIED TARGET SERVICE")
                targetService = CurrentService[i] as! CBService
                break for_service
            }
        }
        
        if(targetService != nil){
                self.searchCharacteristics()
        }

    }
    
    // Characteristics の検索
    func searchCharacteristics(){
        self.TargetPeripheral.delegate = self
        self.TargetPeripheral.discoverCharacteristics(nil, forService: self.targetService)
        
    }
    
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        print("didDiscoveredCharacteristicsForService")
        
        if(error != nil){
            print("error* \(error)")
        }
        
        for characteristics in service.characteristics! {
            CurrentCharacteristicUuids.addObject(characteristics.UUID)
            CurrentCharacteristics.addObject(characteristics)
            print(characteristics)
        }
        
        for_characteristics: for(var i=0;i<CurrentCharacteristicUuids.count;i++){
            if(CurrentCharacteristicUuids[i] as! CBUUID == CBUUID(string: BLESerial2_rx) ){
                targetCharacteristics = CurrentCharacteristics[i] as! CBCharacteristic
                break for_characteristics
            }
        }
        
        if(self.targetCharacteristics != nil){
            self.TargetPeripheral.setNotifyValue(true, forCharacteristic: targetCharacteristics)
        }
        
    }
    
    // Notify
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        //appDelegate.ble_connection = true
        
        if error != nil {
            print("Notify更新失敗... error: \(error)")
            
        }else{
            print("Notify... isNotifying: \(characteristic.isNotifying)")
        }
        
    }
    
    // Write
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("Success!")
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForDescriptor descriptor: CBDescriptor, error: NSError?) {
        print("Success!")
    }
    
    // Read
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
       
        
        let tmp = characteristic.value
        var datas:NSData? = NSData()
        
        datas = NSData(bytes: UnsafePointer<UInt16>((tmp?.bytes)!), length: 15) // 8byte
        
        var out:String?
        
        if(datas != nil){
            
            tmp_data.appendData(datas!)
            
            out = NSString(data: tmp_data!, encoding: NSASCIIStringEncoding) as? String
            //out = NSString(data: tmp_data!, encoding: NSNonLossyASCIIStringEncoding) as? String
            
            if(out != nil){
                out = out?.stringByReplacingOccurrencesOfString("\0", withString: "")
                out = out?.stringByReplacingOccurrencesOfString(" ", withString: "")
                
                print(out)
                if let range = out?.rangeOfString("<>"){
                    var arr = out?.componentsSeparatedByString("<>")
                    
                
                    let splited:String = arr![0]
                    
                    
                    if let check = splited.rangeOfString(","){
                        var values = splited.componentsSeparatedByString(",")
                        
                        let myLocationManager = CLLocationManager()
                        myLocationManager.delegate = self
                        
                        if(values.count == 17){
                            
                            //print(arr![0])
                            
                            
                            let NowDate: NSDate = NSDate()
                            let dateFormatter = NSDateFormatter()
                            dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
                            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
                            let currentDate:String = dateFormatter.stringFromDate(NowDate)
                            
                            /**var useraddtype: String = ""
                            if(appDelegate.useraddSensor_type == 1){
                                useraddtype = "uv"
                            }else if (appDelegate.useraddSensor_type == 2){
                                useraddtype = "sound"
                            }else if (appDelegate.useraddSensor_type == 3){
                                useraddtype = "color"
                            }**/

                            
                            
                            SensorDataSendString += currentDate + ","
                            
                            
                            // Latitude
                            if(appDelegate.latitude_array.count > 300){
                                appDelegate.latitude_array.removeFirst()
                            }

                            
                            var currentLat:CLLocationDegrees = 0.0
            
                            if myLocationManager.location?.coordinate.latitude != nil {
                                currentLat = (myLocationManager.location?.coordinate.latitude)!
                            }else if (appDelegate.latitude_array.count > 0){
                                currentLat = appDelegate.latitude_array[appDelegate.latitude_array.count - 1]
                            }else {
                                currentLat = 0
                            }
                            appDelegate.latitude_array.append(currentLat)
                            
                            
                            SensorDataSendString += String(currentLat) + ","
                            
                            
                            // Longitude
                            if(appDelegate.longitude_array.count > 300){
                                appDelegate.longitude_array.removeFirst()
                            }
                            
                            var currentLon:CLLocationDegrees
                            if myLocationManager.location?.coordinate.longitude != nil {
                                currentLon = (myLocationManager.location?.coordinate.longitude)!
                            }else if (appDelegate.longitude_array.count > 0){
                                currentLon = appDelegate.longitude_array[appDelegate.longitude_array.count - 1]
                            }else {
                                currentLon = 0
                            }
                            
                            appDelegate.longitude_array.append(currentLon)
                            SensorDataSendString += String(currentLon) + ","
                            
                            
                            // additional Sensor Value: Sound
                            if(appDelegate.useraddSensor_array.count > 300){
                                appDelegate.useraddSensor_array.removeFirst()
                            }
                            values[0] = values[0].stringByReplacingOccurrencesOfString(" ", withString: "")
                            appDelegate.useraddSensor_array.append(Float(values[0])!)
                            var useraddtype: String = ""
                            if(appDelegate.useraddSensor_type == 1){
                                useraddtype = "uv"
                            }else if(appDelegate.useraddSensor_type == 2){
                                useraddtype = "sound"
                            }else{
                                useraddtype = "color"
                            }
                            
                            SensorDataSendString += useraddtype + ":" + values[0] + ","
                            
                            // Temperture
                            if(appDelegate.Temperture_array.count > 300){
                                appDelegate.Temperture_array.removeFirst()
                            }
                            values[1] = values[1].stringByReplacingOccurrencesOfString(" ", withString: "")
                            appDelegate.Temperture_array.append(Float(values[1])!)
                            SensorDataSendString += values[1] + ","
                            
                            
                            // Barometer
                            if(appDelegate.Barometer_array.count > 300){
                                appDelegate.Barometer_array.removeFirst()
                            }
                            values[2] = values[2].stringByReplacingOccurrencesOfString(" ", withString: "")
                            appDelegate.Barometer_array.append(Float(values[2])!)
                            SensorDataSendString += values[2] + ","
                            
                            //Altitude
                            if(appDelegate.Altitude_array.count > 300){
                                appDelegate.Altitude_array.removeFirst()
                            }
                            
                            var altitude:Float = 44330.8 * (1.0 - pow((Float(values[2])!/1013.25),0.190263))
                            
                            
                            
                            if(appDelegate.Altitude_array.count < 1){
                                appDelegate.base_altitude = altitude
                            }
                            
                            appDelegate.Altitude_array.append(altitude);
                            
                            // Humidity
                            if(appDelegate.Humidity_array.count > 300){
                                appDelegate.Humidity_array.removeFirst()
                            }
                            values[3] = values[3].stringByReplacingOccurrencesOfString(" ", withString: "")
                            appDelegate.Humidity_array.append(Float(values[3])!)
                            SensorDataSendString += values[3] + ","
                            
                            
                            
                            //Light
                            if(appDelegate.light_array.count > 300){
                                appDelegate.light_array.removeFirst()
                            }
                            values[4] = values[4].stringByReplacingOccurrencesOfString(" ", withString: "")
                            appDelegate.light_array.append(Float(values[4])!)
                            SensorDataSendString += values[4] + ","
                            
                            // AX
                            if(appDelegate.ax_array.count > 300){
                                appDelegate.ax_array.removeFirst()
                            }
                            values[5] = values[5].stringByReplacingOccurrencesOfString(" ", withString: "")
                            appDelegate.ax_array.append(Float(values[5])!)
                            SensorDataSendString += values[5] + ","
                            
                            // AY
                            if(appDelegate.ay_array.count > 300){
                                appDelegate.ay_array.removeFirst()
                            }
                            values[6] = values[6].stringByReplacingOccurrencesOfString(" ", withString: "")
                            appDelegate.ay_array.append(Float(values[6])!)
                            SensorDataSendString += values[6] + ","
                            
                            // AZ
                            if(appDelegate.az_array.count > 300){
                                appDelegate.az_array.removeFirst()
                            }
                            values[7] = values[7].stringByReplacingOccurrencesOfString(" ", withString: "")
                            appDelegate.az_array.append(Float(values[7])!)
                            SensorDataSendString += values[7] + ","
                            
                            // GX
                            if(appDelegate.gx_array.count > 300){
                                appDelegate.gx_array.removeFirst()
                            }
                            values[8] = values[8].stringByReplacingOccurrencesOfString(" ", withString: "")
                            appDelegate.gx_array.append(Float(values[8])!)
                            SensorDataSendString += values[8] + ","
                            
                            // GY
                            if(appDelegate.gy_array.count > 300){
                                appDelegate.gy_array.removeFirst()
                            }
                            values[9] = values[9].stringByReplacingOccurrencesOfString(" ", withString: "")
                            appDelegate.gy_array.append(Float(values[9])!)
                            SensorDataSendString += values[9] + ","
                            
                            //GZ
                            if(appDelegate.gz_array.count > 300){
                                appDelegate.gz_array.removeFirst()
                            }
                            values[10] = values[10].stringByReplacingOccurrencesOfString(" ", withString: "")
                            appDelegate.gz_array.append(Float(values[10])!)
                            SensorDataSendString += values[10] + ","
                            
                            // MX
                            if(appDelegate.mx_array.count > 300){
                                appDelegate.mx_array.removeFirst()
                            }
                            values[11] = values[11].stringByReplacingOccurrencesOfString(" ", withString: "")
                            appDelegate.mx_array.append(Float(values[11])!)
                            SensorDataSendString += values[11] + ","
                            
                            // MY
                            if(appDelegate.my_array.count > 300){
                                appDelegate.my_array.removeFirst()
                            }
                            values[12] = values[12].stringByReplacingOccurrencesOfString(" ", withString: "")
                            appDelegate.my_array.append(Float(values[12])!)
                            SensorDataSendString += values[12] + ","
                            
                            // MZ
                            if(appDelegate.mz_array.count > 300){
                                appDelegate.mz_array.removeFirst()
                            }
                            values[13] = values[13].stringByReplacingOccurrencesOfString(" ", withString: "")
                            appDelegate.mz_array.append(Float(values[13])!)
                            SensorDataSendString += values[13] + "\n"
                            
                            
                            
                            if(SendCount == 30){
                                SendDatatoCloud.SendSensorToServer(TargetPeripheral.identifier.UUIDString, SensorData: SensorDataSendString)
                                SensorDataSendString = ""
                                SendCount = 0
                            }else{
                                SendCount = SendCount + 1;
                            }
                            
                            
                            let SaveData:SaveSensorData = SaveSensorData()
                            SaveData.SaveToCoreDataTable(NowDate, get_latitude: currentLat, get_longitude: currentLon, get_useraddType: useraddtype, SensorArray: values)
                            
                            
                            tmp_data = NSMutableData()
                            
                        }else{
                            tmp_data = NSMutableData()
                        }
                    }
                }
            }
            
            
            
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}