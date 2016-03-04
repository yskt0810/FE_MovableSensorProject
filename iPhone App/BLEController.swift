//
//  ViewController.swift
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

import UIKit
import CoreBluetooth

class BLEController: UIViewController,UITableViewDelegate,UITableViewDataSource,CBCentralManagerDelegate,UITextFieldDelegate {
    
    // 変数定義
    
    var myTableView: UITableView!
    var myUuids: NSMutableArray = NSMutableArray()
    var myNames: NSMutableArray = NSMutableArray()
    var myPeripheral: NSMutableArray = NSMutableArray()
    var myCentralManager: CBCentralManager!
    var myTargetPeripheral: CBPeripheral!
    var myButton: UIButton = UIButton()
    
    var TempField: UITextField = UITextField()
    var BarometerField: UITextField = UITextField()
    var AltitudeField: UITextField = UITextField()
    var HumidityField: UITextField = UITextField()
    var useraddSensorField: UITextField = UITextField()
    var LightField: UITextField = UITextField()
    
    var SendString:String = ""
    
    var BLEMain:BLEConnection = BLEConnection()
    
    var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    init(){
        
        super.init(nibName: nil, bundle: nil)
        
        //self.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.Featured, tag: 1)
        self.tabBarItem.image = UIImage(named: "bleicon.png")
        self.tabBarItem.title = "Sensor"
        
        
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let barHeight: CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height / 2
        
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        
        // Table Viewの生成
        myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight / 2))
        
        // Cellの登録
        myTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DataSourceの設定
        myTableView.dataSource = self
        
        myTableView.delegate = self
        
        self.view.addSubview(myTableView)
        
        // BLEスキャンボタンの設定
        myButton.frame = CGRectMake(0, 0, 200, 40)
        myButton.backgroundColor = UIColor.redColor()
        myButton.layer.masksToBounds = true
        myButton.setTitle("SCAN", forState: UIControlState.Normal)
        myButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        myButton.layer.cornerRadius = 2.0
        myButton.layer.position = CGPoint(x: self.view.frame.width/2, y: displayHeight)
        myButton.tag = 1
        myButton.addTarget(self, action: "onClickMyButton", forControlEvents: .TouchUpInside)
        
        self.view.addSubview(myButton)
        
        BLEMain = BLEConnection()
        
        //値表示フィールドの生成
        TempField = UITextField(frame: CGRectMake(displayWidth/2-160,displayHeight+50,150,30))
        TempField.delegate = self
        TempField.borderStyle = UITextBorderStyle.RoundedRect
        
        HumidityField = UITextField(frame: CGRectMake(displayWidth/2 + 10,displayHeight+50,150,30))
        HumidityField.delegate = self
        HumidityField.borderStyle = UITextBorderStyle.RoundedRect
        
        BarometerField = UITextField(frame: CGRectMake(displayWidth/2 - 160, displayHeight+90, 150, 30))
        BarometerField.delegate = self
        BarometerField.borderStyle = UITextBorderStyle.RoundedRect
        
        AltitudeField = UITextField(frame: CGRectMake(displayWidth/2 + 10, displayHeight+90, 150, 30))
        AltitudeField.delegate = self
        AltitudeField.borderStyle = UITextBorderStyle.RoundedRect
        
        useraddSensorField = UITextField(frame: CGRectMake(displayWidth/2 - 160, displayHeight+130, 150,30))
        useraddSensorField.delegate = self
        useraddSensorField.borderStyle = UITextBorderStyle.RoundedRect
        
        LightField = UITextField(frame: CGRectMake(displayWidth/2 + 10,displayHeight+130,150,30))
        LightField.delegate = self
        LightField.borderStyle = UITextBorderStyle.RoundedRect
            
        self.view.addSubview(TempField)
        self.view.addSubview(BarometerField)
        self.view.addSubview(HumidityField)
        self.view.addSubview(AltitudeField)
        self.view.addSubview(useraddSensorField)
        self.view.addSubview(LightField)
        
        // TextFieldを1秒ごとに更新するタイマーを設定
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "textFieldUpdate", userInfo: nil, repeats: true)
        
    }
    
    
    func textFieldUpdate(){
        
        let tempCount:Int = appDelegate.Temperture_array.count
        if(tempCount > 0){
            TempField.text = String(appDelegate.Temperture_array[tempCount-1]) + " °C"
        }
        
        let barometerCount:Int = appDelegate.Barometer_array.count
        if(barometerCount > 0){
            BarometerField.text = String(appDelegate.Barometer_array[barometerCount-1]) + " hPa"
        }
        
        let HumidityCount:Int = appDelegate.Humidity_array.count
        if(HumidityCount > 0){
            HumidityField.text = String(appDelegate.Humidity_array[HumidityCount-1]) + " %"
        }
        
        let UVCount:Int = appDelegate.useraddSensor_array.count
        if(UVCount>0){
            if(appDelegate.useraddSensor_type == 1){
                useraddSensorField.text = String(appDelegate.useraddSensor_array[UVCount-1])
            }else if (appDelegate.useraddSensor_type == 2){
                let dB = 20 * log10(appDelegate.useraddSensor_array[UVCount - 1] / 1.5)
                useraddSensorField.text = String(appDelegate.useraddSensor_array[UVCount-1]) + ", " + String(dB) + " dB"
            }
            
        }
        
        let LightCount:Int = appDelegate.light_array.count
        if(LightCount>0){
            LightField.text = String(appDelegate.light_array[LightCount-1]) + " Lux"
        }
        
        let AltitudeCount:Int = appDelegate.Altitude_array.count
        if(AltitudeCount > 0){
            AltitudeField.text = String(appDelegate.Altitude_array[AltitudeCount-1] - appDelegate.base_altitude) + " m"
        }
        

        
    }
    
    /*********************************
     *  
     *        Table View関連
     *
     *********************************/
    
    
    // Cellが選択された時に呼び出されるメソッド
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Num: \(indexPath.row)")
        print("Uuid: \(myUuids[indexPath.row])")
        print("Name: \(myNames[indexPath.row])")
        
        self.myTargetPeripheral = myPeripheral[indexPath.row] as! CBPeripheral
        myCentralManager.connectPeripheral(self.myTargetPeripheral, options: nil)
        
    }
    
    // Cellの総数を返すメソッド
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return myUuids.count
        
    }
    
    // Cellに値を設定するメソッド
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyCell")
        
        cell.textLabel!.sizeToFit()
        cell.textLabel!.textColor = UIColor.redColor()
        if(myNames[indexPath.row] as! String == "BLESerial2"){
            cell.textLabel!.text = "\(myUuids[indexPath.row])"
            cell.textLabel!.font = UIFont.systemFontOfSize(12)
            
            cell.detailTextLabel!.text = "\(myNames[indexPath.row])"
            cell.detailTextLabel!.font = UIFont.systemFontOfSize(12)
        }

        
        return cell
        
    }
    
    
    /********************************
     *
     *      BLEデバイス表示関連
     *
     ********************************/
    
    // Scanボタンを押すと、CoreBluetoothを起動
    func onClickMyButton(){
        
        // BLE関連の配列をリセット
        myNames = NSMutableArray()
        myUuids = NSMutableArray()
        myPeripheral = NSMutableArray()
        
        // Core Bluetoothを初期化および起動
        myCentralManager = CBCentralManager(delegate: self, queue: nil, options:nil)
        
        
    }
    
    // BLEの状態を取得する
    func centralManagerDidUpdateState(central: CBCentralManager) {
        print("state \(central.state)")
        switch(central.state){
            
        case .PoweredOff:
            print("Bluetooth 電源OFF")
        case .PoweredOn:
            print("Bluetooth 電源ON")
            //BLEデバイスの検出を開始
            myCentralManager.scanForPeripheralsWithServices(nil, options: nil)
        case .Resetting:
            print("Resetting")
        case .Unauthorized:
            print("非認証状態")
        case .Unsupported:
            print("非対応")
        default:
            print("デフォルト")
        }
        
    }
    
    // BLEデバイスが検出された時に呼び出される
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("peripheral.name: \(peripheral.name)")
        print("advertisementData: \(advertisementData)")
        print("RSSI: \(RSSI)")
        print("peripheral.identifier.UUIDString: \(peripheral.identifier.UUIDString)")
        
        var name: NSString? = advertisementData["kCBAdvDataLocalName"] as? NSString
        if(name == nil){
            name = "no name"
        }
        
        myNames.addObject(name!)
        myPeripheral.addObject(peripheral)
        myUuids.addObject(peripheral.identifier.UUIDString)
        
        myTableView.reloadData()
        
    }
    
    
    /************************************
     *
     *       BLE Peripheral接続関連
     *
     ************************************/
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        print("connect")
        
        print("Set Peripheral")
        BLEMain = BLEConnection()
        
        appDelegate.ble_uuid = peripheral.identifier.UUIDString;
        BLEMain.setPeripheral(peripheral)
        BLEMain.setCentralManager(central)
        BLEMain.searchService()
        
    }
    
    
    
    
    
    
    
    
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    required override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

