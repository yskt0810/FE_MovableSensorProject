//
//  MapVIewController.swift
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
import MapKit
import UIKit
import CoreLocation

class MapViewController:UIViewController,MKMapViewDelegate,CLLocationManagerDelegate,UIPickerViewDelegate,UIToolbarDelegate,UIPickerViewDataSource {
    
    // MapView関連
    var FEMapView: MKMapView!
    var CurrentLocationManager: CLLocationManager = CLLocationManager()
    var currentLat: CLLocationDegrees = CLLocationDegrees()
    var currentLon: CLLocationDegrees = CLLocationDegrees()
    
    // PickerView関連
    
    //var selectItems:NSArray = ["TEMPERTURE","BAROMETER","HUMIDITY","USERADD SENSOR","LIGHT","ALTITUDE"]
    var selectItems:NSArray = []
    var SensorSelectToolBar: UIToolbar = UIToolbar()
    var SensorSelectTextField: UITextField = UITextField()
    var SensorSelectPickerView: UIPickerView = UIPickerView()
    var accLabel: UILabel = UILabel()
    var gyrLabel: UILabel = UILabel()
    var mgtLabel: UILabel = UILabel()
    var baseBaroLabel: UILabel = UILabel()
    
    // オーバーレイ関連
    var overlaytype:Int = 0
    var circleRadius:Int = 3;
    var selected:Int = 0;
    
    // オーバーレイ関連：Temperture
    var Temperture_circle: [MKCircle] = []
    var Temperture_flag = false
    var tmp_Temperture:Float = 0.0
    
    // オーバーレイ関連：Barometer
    var Barometer_circle: [MKCircle] = []
    var Barometer_flag = false
    var tmp_Barometer:Float = 0.0
    
    // オーバーレイ関連：Humidity
    var Humidity_circle: [MKCircle] = []
    var Humidity_flag = false
    var tmp_Humidity:Float = 0.0
    
    // オーバーレイ関連：UV Index
    var useraddSensor_circle: [MKCircle] = []
    var useraddSensor_flag = false
    var tmp_useraddSensor:Float = 0.0
    
    // オーバーレイ関連：Light
    var light_circle: [MKCircle] = []
    var light_flag = false
    var tmp_light:Float = 0.0
    
    // オーバーレイ関連：Altitude
    var altitude_circle: [MKCircle] = []
    var altitude_flag = false
    var tmp_altitude:Float = 0.0
    
    // ボタン関連
    var centralButton:UIButton = UIButton()
    var altCalibrationButton:UIButton = UIButton()
    var cameraButton: UIButton = UIButton()
    
    
    // 選択数値のアウトプットラベル
    var SelectedSensorData: UILabel = UILabel()
    
    // センサーデータを持ってくるための appDelegate定義
    var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    /****************************************
    *
    *               Initialize
    *
    *****************************************/
    
    init(){
        super.init(nibName: nil, bundle: nil)
        
        //self.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.Featured, tag: 2)
        self.tabBarItem.image = UIImage(named: "mapicon.png")
        self.tabBarItem.title = "Map View"
        
    }
    
    /****************************************
     *
     *               ViewDidLoad
     *
     *****************************************/

    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        
        if(appDelegate.useraddSensor_type == 1){
            selectItems = ["TEMPERTURE","BAROMETER","HUMIDITY","UV INDEX","LIGHT","ALTITUDE"]
        }else if(appDelegate.useraddSensor_type == 2){
            selectItems = ["TEMPERTURE","BAROMETER","HUMIDITY","SOUND LEVEL","LIGHT","ALTITUDE"]
        }else if(appDelegate.useraddSensor_type == 3){
            selectItems = ["TEMPERTURE","BAROMETER","HUMIDITY","COLORS","LIGHT","ALTITUDE"]
        }
        // Location Managerの生成
        CurrentLocationManager = CLLocationManager()
        
        // Delegateの設定
        CurrentLocationManager.delegate = self
        
        // 距離のフィルタ
        CurrentLocationManager.distanceFilter = 1000.0
        
        // 精度
        CurrentLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // セキュリティ認証のステータスを取得
        let status = CLLocationManager.authorizationStatus()
        
        // まだ認証が得られていない場合は、認証ダイアログを表示する
        if(status == CLAuthorizationStatus.NotDetermined){
            
            self.CurrentLocationManager.requestAlwaysAuthorization()
            
        }
        
        // 位置情報の更新の開始
        CurrentLocationManager.startUpdatingLocation()
        
        // MapViewの生成
        FEMapView = MKMapView()
        
        // MapViewサイズを画面全体にする
        FEMapView.frame = self.view.bounds
        
        // Delegateを設定
        FEMapView.delegate = self
        
        // MapViewをViewに追加
        self.view.addSubview(FEMapView)
        FEMapView.setCenterCoordinate(FEMapView.userLocation.coordinate, animated: true)
        FEMapView.userTrackingMode = MKUserTrackingMode.Follow
        
        
        //PickerViewの作成
        SensorSelectPickerView = UIPickerView()
        SensorSelectPickerView.showsSelectionIndicator = true
        SensorSelectPickerView.delegate = self
        
        // TextFieldの作成
        SensorSelectTextField = UITextField(frame: CGRectMake(self.view.frame.width/2-175,self.view.frame.height-100,350,40))
        SensorSelectTextField.font = UIFont.systemFontOfSize(20.0)
        SensorSelectTextField.placeholder = selectItems[0] as? String
        self.view.addSubview(SensorSelectTextField)
        
        
        
        // Toolbarの作成
        SensorSelectToolBar = UIToolbar(frame: CGRectMake(self.view.frame.width/2-200,self.view.frame.size.height/6,self.view.frame.size.width,40.0))
        SensorSelectToolBar.layer.position = CGPoint(x: self.view.frame.size.width/2-175, y: self.view.frame.size.height-20.0)
        SensorSelectToolBar.backgroundColor = UIColor.blackColor()
        SensorSelectToolBar.barStyle = UIBarStyle.Black
        SensorSelectToolBar.tintColor = UIColor.whiteColor()
        
        // ToolBarを閉じるボタンを追加
        let SensorSelectToolBarButton = UIBarButtonItem(title: "Close", style: .Bordered, target: self, action: "onClick:")
        SensorSelectToolBarButton.tag = 1
        SensorSelectToolBar.items = [SensorSelectToolBarButton]
        
        
        SensorSelectTextField.inputView = SensorSelectPickerView
        SensorSelectTextField.inputAccessoryView = SensorSelectToolBar
        
        
        // CentralButtonを作成
        let centralbutton_image: UIImage = UIImage(named: "centralicon.png")!
        centralButton.frame = CGRectMake(0, 0, 60, 60)
        centralButton.setImage(centralbutton_image, forState: .Normal)
        centralButton.layer.position = CGPoint(x: self.view.frame.size.width - 40, y: self.view.frame.size.height - 80.0)
        centralButton.tag = 1
        centralButton.addTarget(self, action: "onClickCentralButton", forControlEvents: .TouchUpInside)
        self.view.addSubview(centralButton)
        
        // CariburationButtonを作成
        let calibration_image: UIImage = UIImage(named: "calibrationicon.png")!
        altCalibrationButton.frame = CGRectMake(0, 0, 60, 60)
        altCalibrationButton.setImage(calibration_image, forState: .Normal)
        altCalibrationButton.layer.position = CGPoint(x: self.view.frame.size.width - 80, y: self.view.frame.size.height - 80.0)
        altCalibrationButton.tag = 1
        altCalibrationButton.addTarget(self, action: "onClickAltCalibrationButton", forControlEvents: .TouchUpInside)
        self.view.addSubview(altCalibrationButton)
        
        // CameraButton を作成
        let camerabutton_image:UIImage = UIImage(named: "cameraicon.png")!
        cameraButton.frame = CGRectMake(0, 0, 60, 60)
        cameraButton.setImage(camerabutton_image, forState: .Normal)
        cameraButton.layer.position = CGPoint(x: self.view.frame.size.width - 120, y: self.view.frame.size.height - 80.0)
        cameraButton.tag = 1
        cameraButton.addTarget(self, action: "onClickCameraButton", forControlEvents: .TouchUpInside)
        self.view.addSubview(cameraButton)
        
        SelectedSensorData.frame = CGRectMake(10, 10, self.view.frame.size.width, 150)
        SelectedSensorData.font = UIFont.systemFontOfSize(12)
        self.view.addSubview(SelectedSensorData)
        
        
        accLabel.frame = CGRectMake(10, 20, self.view.frame.size.width, 15)
        accLabel.font = UIFont.systemFontOfSize(12)
        self.view.addSubview(accLabel)
        
        gyrLabel.frame = CGRectMake(10, 35, self.view.frame.size.width, 15)
        gyrLabel.font = UIFont.systemFontOfSize(12)
        self.view.addSubview(gyrLabel)
        
        mgtLabel.frame = CGRectMake(10, 50, self.view.frame.size.width, 15)
        mgtLabel.font = UIFont.systemFontOfSize(12)
        self.view.addSubview(mgtLabel)
        
        baseBaroLabel.frame = CGRectMake(10, 65, self.view.frame.size.width, 15)
        baseBaroLabel.font = UIFont.systemFontOfSize(12)
        self.view.addSubview(baseBaroLabel)
        
        
        // １秒ごとにオーバーレイをアップデート
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "overlayUpdated", userInfo: nil, repeats: true)
        //NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:  "SensorLabelUpdate", userInfo:  nil, repeats: true)
        
        
    }
    
    
    
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool){
        print("region Did change Animated.")
    }
    
    
    func locationManager(manager: CLLocationManager!, didChangeAuthrizationStatus status: CLAuthorizationStatus){
        switch status{
            
        case .AuthorizedWhenInUse:
            print("AuthorizedWhenInUse");
            
        case .Authorized:
            print("Authorized");
            
        case .Denied:
            print("Denied");
            
        case .Restricted:
            print("Restricted");
            
        case .NotDetermined:
            print("NotDetermined");
        default:
            print("etc.");
            
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLat = (manager.location?.coordinate.latitude)!
        currentLon = (manager.location?.coordinate.longitude)!
        
        let newCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(currentLat, currentLon) as CLLocationCoordinate2D
        
        let newLatDist: CLLocationDistance = 800;
        let newLonDist: CLLocationDistance = 800;
        
        let newRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(newCoordinate, newLatDist, newLonDist)
        
        FEMapView.setRegion(newRegion, animated: true) 
        
    }
    
    
    /**********************************
     *
     *           ボタンイベント関連
     *
     **********************************/
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("ERROR")
        
    }
    
    
    func onClickCentralButton(){
        
        
        if(centralButton.tag == 1){
            CurrentLocationManager.startUpdatingLocation()
            
        }
        
    }
    
    
    func onClickAltCalibrationButton(){
        
        if(appDelegate.Altitude_array.capacity > 0){
            
            let AltCount:Int = appDelegate.Altitude_array.count
            appDelegate.base_altitude = appDelegate.Altitude_array[AltCount-1]
            baseBaroLabel.text = String(appDelegate.base_altitude)
        }
        
        
    }
    
    
    func onClickCameraButton(){
        
        let cameraDev: CameraView = CameraView()
        
        
        //imageView.modalTransitionStyle = UIModalTransitionStyle.PartialCurl
        
        //self.presentViewController(imageView, animated: true, completion: nil)
        
        cameraDev.modalTransitionStyle = UIModalTransitionStyle.PartialCurl
        self.presentViewController(cameraDev, animated: true, completion: nil)
        
    }
    
    
    
    
    
    
    
    
    
    //****************************************************
    
    func updateTempertureCircle(){
        
        if(Temperture_flag == true){
            for circle in Temperture_circle{
                FEMapView.removeOverlay(circle)
            }
            Temperture_flag = false
        }
        
        if(Temperture_flag == false){
            
            for(var i=0;i<appDelegate.Temperture_array.count;i++){
                
                let center: CLLocationCoordinate2D! = CLLocationCoordinate2DMake(appDelegate.latitude_array[i], appDelegate.longitude_array[i])
                let circle: MKCircle = MKCircle(centerCoordinate: center, radius: CLLocationDistance(5))
                tmp_Temperture = appDelegate.Temperture_array[i]
                overlaytype = 1
                FEMapView.addOverlay(circle)
                Temperture_circle.append(circle)
                
                
            }
            
            Temperture_flag = true
            
        }
    }
    
    
    
    func updateBarometerCircle(){
        
        if(Barometer_flag == true){
            for circle in Barometer_circle{
                FEMapView.removeOverlay(circle)
            }
            Barometer_flag = false
        }
        
        if(Barometer_flag == false){
            
            for(var i=0;i<appDelegate.Barometer_array.count;i++){
                
                let center: CLLocationCoordinate2D! = CLLocationCoordinate2DMake(appDelegate.latitude_array[i], appDelegate.longitude_array[i])
                let circle: MKCircle = MKCircle(centerCoordinate: center, radius: CLLocationDistance(5))
                tmp_Barometer = appDelegate.Barometer_array[i]
                overlaytype = 2
                FEMapView.addOverlay(circle)
                Barometer_circle.append(circle)
                
            }
            
            Barometer_flag = true
        }
        
    }
    
    
    func updateHumidityCircle(){
        
        if(Humidity_flag == true){
            
            for circle in Humidity_circle{
                FEMapView.removeOverlay(circle)
            }
            
            Humidity_flag = false
        }
        
        if(Humidity_flag == false){
            
            for(var i=0;i<appDelegate.Humidity_array.count;i++){
                
                let center: CLLocationCoordinate2D! = CLLocationCoordinate2DMake(appDelegate.latitude_array[i], appDelegate.longitude_array[i])
                let circle: MKCircle = MKCircle(centerCoordinate: center, radius: CLLocationDistance(5))
                tmp_Humidity = appDelegate.Humidity_array[i]
                overlaytype = 3
                FEMapView.addOverlay(circle)
                Humidity_circle.append(circle)
                
            }
            
            Humidity_flag = true
            
        }
        
        
    }
    
    
    
    func updateUseraddSensorCircle(){
        
        if(useraddSensor_flag == true){
            
            for circle in useraddSensor_circle{
                FEMapView.removeOverlay(circle)
            }
            
            useraddSensor_flag = false
        }
        
        if(useraddSensor_flag == false){
            
            for(var i=0;i<appDelegate.useraddSensor_array.count;i++){
                
                let center: CLLocationCoordinate2D! = CLLocationCoordinate2DMake(appDelegate.latitude_array[i], appDelegate.longitude_array[i])
                let circle: MKCircle = MKCircle(centerCoordinate: center, radius: CLLocationDistance(5))
                tmp_useraddSensor = appDelegate.useraddSensor_array[i]
                if(appDelegate.useraddSensor_type == 1){
                    overlaytype = 4
                }else if(appDelegate.useraddSensor_type == 2){
                    overlaytype = 8
                }else if(appDelegate.useraddSensor_type == 3){
                    overlaytype = 9
                }else{
                    overlaytype = 4
                }

                FEMapView.addOverlay(circle)
                useraddSensor_circle.append(circle)
                
            }
            
            useraddSensor_flag = true
            
        }
        
        
    }
    
    
    
    func updateLightCircle(){
        
        if(light_flag == true){
            
            for circle in light_circle{
                FEMapView.removeOverlay(circle)
            }
            
            light_flag = false
        }
        
        if(light_flag == false){
            
            for(var i=0;i<appDelegate.light_array.count;i++){
                
                let center: CLLocationCoordinate2D! = CLLocationCoordinate2DMake(appDelegate.latitude_array[i], appDelegate.longitude_array[i])
                let circle: MKCircle = MKCircle(centerCoordinate: center, radius: CLLocationDistance(5))
                tmp_light = appDelegate.light_array[i]
                overlaytype = 5 // LIGHTから UVに変更する
                FEMapView.addOverlay(circle)
                light_circle.append(circle)
                
            }
            
            light_flag = true
            
        }
        
        
        
    }
    
    func updateAltitudeCircle(){
        
        if(altitude_flag == true){
            
            for circle in altitude_circle {
                FEMapView.removeOverlay(circle)
            }
            altitude_flag = false
        }
        
        if(altitude_flag == false){
            
            for(var i=0; i<appDelegate.Altitude_array.count; i++){
                
                
                let center: CLLocationCoordinate2D! = CLLocationCoordinate2DMake(appDelegate.latitude_array[i], appDelegate.longitude_array[i])
                let circle: MKCircle = MKCircle(centerCoordinate: center, radius: CLLocationDistance(5))
                tmp_altitude = appDelegate.Altitude_array[i]
                overlaytype = 6
                FEMapView.addOverlay(circle)
                altitude_circle.append(circle)
                
                
            }
            
            altitude_flag = true
            
        }
        
    }
    
    
    
    
    
    
    
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let now: NSDate = NSDate()
        let myCalendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myComponentns = myCalendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute,NSCalendarUnit.Second, NSCalendarUnit.Weekday], fromDate: now)
        
        var night_flag:Int = 0;
        
        if (myComponentns.hour < 7 || myComponentns.hour > 16){
            night_flag = 1
        }else{
            night_flag = 0
        }
        
        
        if(overlaytype == 5){
            // LIGHT
            let myCircleRenderer: MKCircleRenderer = MKCircleRenderer(overlay: overlay)
            
            if(night_flag == 1){
                
                if(tmp_light > 200.00){
                    tmp_light = 200.00
                }
                
                let b = CGfloatMap(tmp_light, in_min: 0.0, in_max: 200.00, out_min: 0.0, out_max: 1)
                myCircleRenderer.fillColor = UIColor(hue:0.16, saturation: 1.0, brightness: b, alpha: 1.0)
                
            }else {
                
                if(tmp_light > 12000.00){
                    tmp_light = 12000.00
                }
                
                let h = CGfloatMap(tmp_light, in_min: 0.0, in_max: 12000.00, out_min: 240.00, out_max: 0.0)
                //let b = floatMap(tmp_light, in_min: 0.0, in_max: 12000.00, out_min: 0.5, out_max: 1.0)
                myCircleRenderer.fillColor = UIColor(hue: h/360, saturation: 1.0, brightness: 1.0, alpha: 1.0)
                
                
            }
            
            myCircleRenderer.lineWidth = 1.5
            
            return myCircleRenderer
            
        }else if(overlaytype == 4){
            // UV
            let myCircleRenderer: MKCircleRenderer = MKCircleRenderer(overlay: overlay)
            if(tmp_useraddSensor < 3.0){
                myCircleRenderer.fillColor = UIColor(hue: 0.56, saturation: 0.75, brightness: 1.0, alpha: 1.0)
            }else if(tmp_useraddSensor < 6.0){
                myCircleRenderer.fillColor = UIColor(hue: 60/360, saturation: 100/100, brightness: 100/100, alpha: 1.0)
            }else if(tmp_useraddSensor < 8.0){
                myCircleRenderer.fillColor = UIColor(hue: 40/360, saturation: 100/100, brightness: 100/100, alpha: 1.0)
            }else if(tmp_useraddSensor < 11.0){
                myCircleRenderer.fillColor = UIColor(hue: 12/360, saturation: 100/100, brightness: 100/100, alpha: 1.0)
            }else{
                myCircleRenderer.fillColor = UIColor(hue: 270/360, saturation: 100/100, brightness: 80/100, alpha: 1.0)
            }
            myCircleRenderer.lineWidth = 1.5
            
            return myCircleRenderer
            
        }else if(overlaytype == 1){
            
            let myCircleRenderer: MKCircleRenderer = MKCircleRenderer(overlay: overlay)
            let h = CGfloatMap(tmp_Temperture, in_min: -10.0, in_max: 50, out_min: 240.0, out_max: 0.0)
            myCircleRenderer.fillColor = UIColor(hue: h/360, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            
            
            myCircleRenderer.lineWidth = 1.5
            
            return myCircleRenderer
            
        }else if(overlaytype == 2){
            
            
            let myCircleRenderer: MKCircleRenderer = MKCircleRenderer(overlay: overlay)
            /**var pressure_difference = tmp_pressure2 - tmp_pressure1
            print(pressure_difference)
            if(pressure_difference > 1.0){pressure_difference = 1.0 }
            else if(pressure_difference < -1.0){ pressure_difference = -1.0 }
            
            let alt_diff:Float = floatMap(pressure_difference, in_min: -1.0, in_max: 1.0, out_min: -8.3, out_max: 8.3)
            // +- 1hpa = 8.3m 気圧の上下が激しいほど、高度差がある **/
            
            //altitude = 44330.8 * (1.0 - pow((tmp_pressure1/1013.25), 0.190263))
            
            let h = CGfloatMap(tmp_Barometer, in_min: 900.0, in_max: 1050.0, out_min: 0.75, out_max: 0.0)
            
            myCircleRenderer.fillColor = UIColor(hue: h, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            
            myCircleRenderer.lineWidth = 1.5
            
            return myCircleRenderer
            
        }else if(overlaytype == 3){
            
            let myCircleRenderer: MKCircleRenderer = MKCircleRenderer(overlay: overlay)
            let h = CGfloatMap(tmp_Humidity, in_min: 0.0, in_max: 100.0, out_min: 0.5, out_max: 0.66)
            myCircleRenderer.fillColor = UIColor(hue: h, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            myCircleRenderer.lineWidth = 1.5
            
            return myCircleRenderer
            
        }else if(overlaytype == 6){
            
            let myCircleRenderer: MKCircleRenderer = MKCircleRenderer(overlay: overlay)
            let h = CGfloatMap(tmp_altitude - appDelegate.base_altitude, in_min: -50.0, in_max: 50.0, out_min: 0.66, out_max: 0.0)
            myCircleRenderer.fillColor = UIColor(hue: h, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            myCircleRenderer.lineWidth = 1.5
            
            return myCircleRenderer
            
        }else if(overlaytype == 8){
            
            let myCircleRenderer: MKCircleRenderer = MKCircleRenderer(overlay: overlay)
            let h = CGfloatMap(tmp_useraddSensor, in_min: 0, in_max: 3300, out_min: 0.5, out_max: 0.02)
            myCircleRenderer.fillColor = UIColor(hue: h, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            myCircleRenderer.lineWidth = 1.5
            
            return myCircleRenderer
            
        }else{
            
            let dummyRenderer: MKOverlayRenderer = MKOverlayRenderer()
            return dummyRenderer
            
        }
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return selectItems.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return selectItems[row] as? String;
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        SensorSelectTextField.text = selectItems[row] as? String;
        selected = row;
        self.pickerChanged()
        SensorSelectTextField.resignFirstResponder()
        
    }
    
    //閉じる
    func onClick(sender: UIBarButtonItem) {
        
        SensorSelectTextField.resignFirstResponder()
    }
    
    func pickerChanged(){
        
        if(Temperture_flag == true){
            for circle in Temperture_circle{
                FEMapView.removeOverlay(circle)
            }
            Temperture_flag = false
        }
        
        
        if(Barometer_flag == true){
            for circle in Barometer_circle {
                FEMapView.removeOverlay(circle)
            }
            Barometer_flag = false
        }
        
        if(Humidity_flag == true){
            for circle in Humidity_circle {
                FEMapView.removeOverlay(circle)
            }
            Humidity_flag = false
            
        }
        
        
        if(useraddSensor_flag == true){
            for circle in useraddSensor_circle{
                FEMapView.removeOverlay(circle)
            }
            useraddSensor_flag = false;
        }
        
        if(light_flag == true){
            for circle in light_circle{
                FEMapView.removeOverlay(circle)
            }
            light_flag = false
        }
        
        if(altitude_flag == true){
            
            for circle in altitude_circle {
                FEMapView.removeOverlay(circle)
            }
            altitude_flag = false
        }
        
        switch selected {
            
        case 0:
            self.updateTempertureCircle()
            break
        case 1:
            self.updateBarometerCircle()
            break
            
        case 2:
            self.updateHumidityCircle()
            break
            
        case 3:
            self.updateUseraddSensorCircle()
            break
        case 4:
            self.updateLightCircle()
            break
        case 5:
            self.updateAltitudeCircle()
            break
            
        default:
            //self.updateLightCircle()
            print("ERROR")
            break
            
        }
        
        
    }
    
    
    func overlayUpdated(){
        
        if(Temperture_flag == true){
            for circle in Temperture_circle{
                FEMapView.removeOverlay(circle)
            }
            Temperture_flag = false
        }
        
        
        if(Barometer_flag == true){
            for circle in Barometer_circle {
                FEMapView.removeOverlay(circle)
            }
            Barometer_flag = false
        }
        
        if(Humidity_flag == true){
            for circle in Humidity_circle {
                FEMapView.removeOverlay(circle)
            }
            Humidity_flag = false
            
        }
        
        
        if(useraddSensor_flag == true){
            for circle in useraddSensor_circle{
                FEMapView.removeOverlay(circle)
            }
            useraddSensor_flag = false;
        }
        
        if(light_flag == true){
            for circle in light_circle{
                FEMapView.removeOverlay(circle)
            }
            light_flag = false
        }
        
        if(altitude_flag == true){
            
            for circle in altitude_circle {
                FEMapView.removeOverlay(circle)
            }
            altitude_flag = false
        }
        
        switch selected {
            
        case 0:
            self.updateTempertureCircle()
            break
        case 1:
            self.updateBarometerCircle()
            break
            
        case 2:
            self.updateHumidityCircle()
            break
            
        case 3:
            self.updateUseraddSensorCircle()
            break
        case 4:
            self.updateLightCircle()
            break
        case 5:
            self.updateAltitudeCircle()
            break
            
        default:
            //self.updateLightCircle()
            print("ERROR")
            break
            
        }
    }
    
    
    
    func CGfloatMap(x: Float, in_min: Float, in_max: Float, out_min: Float, out_max: Float)->CGFloat{
        
        return (CGFloat)((x - in_min) * (out_max - out_min) / (in_max -  in_min) + out_min)
        
    }
    
    func floatMap(x: Float, in_min:Float, in_max: Float, out_min: Float, out_max: Float)->Float{
        
        return ((x - in_min) * (out_max - out_min) / (in_max -  in_min) + out_min)
        
    }
    
    
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    required override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}