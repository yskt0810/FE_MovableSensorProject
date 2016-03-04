//
//  GraphView.swift
//  FE_iOS2
//
//  Created by TsuchiyaYosuke on 2016/02/17.
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

class GraphView: UIViewController,BEMSimpleLineGraphDelegate,BEMSimpleLineGraphDataSource {
    
    
    var SensorSegControl: UISegmentedControl!
    var SensorSegArray: NSArray! = []
    
    var MotionSensorSegControl: UISegmentedControl!
    var MotionSensorArray: NSArray! = []
    
    var GraphView: BEMSimpleLineGraphView!
    var appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var MotionGraph1:BEMSimpleLineGraphView!
    var MotionGraph2:BEMSimpleLineGraphView!
    var MotionGraph3:BEMSimpleLineGraphView!
    
    var selectedIndex:Int = 0;
    var selectedMotionIndex:Int = 0
    
    var SensorMaxValue: Float = 0.0
    var SensorMinValue: Float = 0.0
    var SensorAverageValue: Float = 0.0
    var SensorCurrentValue: Float = 0.0
    var SensorMaxValueLabel: UILabel = UILabel()
    var SensorMinValueLabel: UILabel = UILabel()
    var SensorAverageValueLabel: UILabel = UILabel()
    var SensorCurrentValueLabel: UILabel = UILabel()
    var currentSelectedSensorLabel: UILabel = UILabel()
    
    var motionXValueLabel: UILabel = UILabel()
    var motionYValueLabel: UILabel = UILabel()
    var motionZValueLabel: UILabel = UILabel()
        
    //var myScrollView:UIScrollView!
    
    init(){
        super.init(nibName: nil, bundle: nil)
        
        self.view.backgroundColor = UIColor.whiteColor()
        //self.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.Featured, tag:2)
        
        self.tabBarItem.image = UIImage(named: "graphicon.png")
        self.tabBarItem.title = "Graph"
        
    }
    
    
    override func viewDidLoad() {
        
        
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        if(appDel.useraddSensor_type == 1){
            SensorSegArray = ["気温","気圧","湿度","UV","照度","高低差"]
        }else if(appDel.useraddSensor_type == 2){
            SensorSegArray = ["気温","気圧","湿度","騒音","照度","高低差"]
        }else if(appDel.useraddSensor_type == 3){
            SensorSegArray = ["気温","気圧","湿度","色","照度","高低差"]
        }
        
        MotionSensorArray = ["加速度","ジャイロ","地磁気"]
        
  
        //myScrollView = UIScrollView()
        //myScrollView.frame = CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height)
        
        
        
        // グラフのViewを作成（今回はメンビューと同じ大きさのビューをつくる
        GraphView = BEMSimpleLineGraphView(frame: CGRectMake(0,60,self.view.bounds.width,200))
        GraphView.dataSource = self
        GraphView.delegate = self
        
        GraphView.enableBezierCurve = true
        GraphView.enableYAxisLabel = false
        GraphView.enableXAxisLabel = false
        GraphView.enableReferenceAxisFrame = true
        GraphView.enableReferenceXAxisLines = true
        GraphView.enableReferenceYAxisLines = false
        
        GraphView.widthLine = 1
        GraphView.colorLine = UIColor.greenColor()
        GraphView.colorTop = UIColor.whiteColor()
        GraphView.colorBottom = UIColor.whiteColor()
        GraphView.animationGraphStyle = BEMLineAnimation.None
        
        
        self.view.addSubview(GraphView)
        

        //Motion Graph
        let backgroundlabel:UILabel = UILabel(frame: CGRect(x: 0,y: 320,width: self.view.bounds.width,height: 330));
        backgroundlabel.backgroundColor = UIColor.lightGrayColor()
        
        self.view.addSubview(backgroundlabel)
        
        
        MotionGraph1 = BEMSimpleLineGraphView(frame: CGRectMake(0,280,self.view.bounds.width,100))
        
        
        MotionGraph1.delegate = self
        MotionGraph1.dataSource = self
        
        
        MotionGraph1.enableBezierCurve = true
        MotionGraph1.enableYAxisLabel = false
        MotionGraph1.enableXAxisLabel = false
        MotionGraph1.enableReferenceAxisFrame = true
        MotionGraph1.enableReferenceXAxisLines = true
        MotionGraph1.enableReferenceYAxisLines = false
        MotionGraph1.widthLine = 1
        MotionGraph1.colorLine = UIColor.redColor()
        MotionGraph1.colorTop = UIColor.lightGrayColor()
        MotionGraph1.colorBottom = UIColor.lightGrayColor()
        
        
        MotionGraph1.animationGraphStyle = BEMLineAnimation.None
        self.view.addSubview(MotionGraph1)
        
        MotionGraph2 = BEMSimpleLineGraphView(frame: CGRectMake(0,380 ,self.view.bounds.width,100))
        
        MotionGraph2.delegate = self
        MotionGraph2.dataSource = self
        
        
        MotionGraph2.enableBezierCurve = true
        MotionGraph2.enableYAxisLabel = false
        MotionGraph2.enableXAxisLabel = false
        MotionGraph2.enableReferenceAxisFrame = true
        MotionGraph2.enableReferenceXAxisLines = true
        MotionGraph2.enableReferenceYAxisLines = false
        MotionGraph2.widthLine = 1
        MotionGraph2.colorLine = UIColor.greenColor()
        MotionGraph2.colorTop = UIColor.lightGrayColor()
        MotionGraph2.colorBottom = UIColor.lightGrayColor()
        
        
        MotionGraph2.animationGraphStyle = BEMLineAnimation.None
        self.view.addSubview(MotionGraph2)
        
        MotionGraph3 = BEMSimpleLineGraphView(frame: CGRectMake(0,480, self.view.bounds.width,100))
        
        MotionGraph3.delegate = self
        MotionGraph3.dataSource = self
        
        
        MotionGraph3.enableBezierCurve = true
        MotionGraph3.enableYAxisLabel = false
        MotionGraph3.enableXAxisLabel = false
        MotionGraph3.enableReferenceAxisFrame = true
        MotionGraph3.enableReferenceXAxisLines = true
        MotionGraph3.enableReferenceYAxisLines = false
        MotionGraph3.widthLine = 1
        MotionGraph3.colorLine = UIColor.blueColor()
        MotionGraph3.colorTop = UIColor.lightGrayColor()
        MotionGraph3.colorBottom = UIColor.lightGrayColor()
        
        
        MotionGraph3.animationGraphStyle = BEMLineAnimation.None
        self.view.addSubview(MotionGraph3)
        
        
        
        SensorSegControl = UISegmentedControl(items: SensorSegArray as [AnyObject])
        SensorSegControl.center = CGPoint(x: self.view.bounds.width/2, y: 40)
        SensorSegControl.backgroundColor = UIColor.grayColor()
        SensorSegControl.tintColor = UIColor.whiteColor()
        SensorSegControl.selectedSegmentIndex = 0
        SensorSegControl.addTarget(self, action: "SegconChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        self.view.addSubview(SensorSegControl)
        
        SensorMaxValueLabel = UILabel(frame: CGRect(x: 0, y: 60, width: self.view.bounds.width/2, height: 15))
        SensorMaxValueLabel.font = UIFont.systemFontOfSize(12)
        SensorMaxValueLabel.text = "最大値：" + String(SensorMaxValue)
        self.view.addSubview(SensorMaxValueLabel)
        
        SensorMinValueLabel = UILabel(frame: CGRect(x: (self.view.bounds.width / 2), y: 60, width: self.view.bounds.width / 2 , height: 15))
        SensorMinValueLabel.font = UIFont.systemFontOfSize(12)
        SensorMinValueLabel.text = "最小値：" + String(SensorMinValue)
        self.view.addSubview(SensorMinValueLabel)
        
        
        SensorAverageValueLabel = UILabel(frame: CGRect(x: 0, y: 80, width: self.view.bounds.width/2, height: 15))
        SensorAverageValueLabel.font = UIFont.systemFontOfSize(12)
        SensorAverageValueLabel.text = "平均値：" + String(SensorAverageValue)
        self.view.addSubview(SensorAverageValueLabel)
        
        
        SensorCurrentValueLabel = UILabel(frame: CGRect(x: (self.view.bounds.width / 2), y: 80, width: self.view.bounds.width, height: 15))
        SensorCurrentValueLabel.font = UIFont.systemFontOfSize(12)
        SensorCurrentValueLabel.text = "現在値：" + String(SensorCurrentValue)
        self.view.addSubview(SensorCurrentValueLabel)
        
        
        
        MotionSensorSegControl = UISegmentedControl(items: MotionSensorArray as [AnyObject])
        MotionSensorSegControl.center = CGPoint(x: self.view.bounds.width/2, y: 250)
        MotionSensorSegControl.backgroundColor = UIColor.grayColor()
        MotionSensorSegControl.tintColor = UIColor.whiteColor()
        MotionSensorSegControl.selectedSegmentIndex = 0
        MotionSensorSegControl.addTarget(self, action: "MotionSegconChanged:", forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(MotionSensorSegControl)
        
        motionXValueLabel = UILabel(frame: CGRect(x: 0, y: 280, width: self.view.bounds.width, height: 15))
        motionXValueLabel.font = UIFont.systemFontOfSize(12)
        motionXValueLabel.textColor = UIColor.whiteColor()
        motionXValueLabel.text = "X軸"
        self.view.addSubview(motionXValueLabel)
        
        motionYValueLabel = UILabel(frame: CGRect(x: 0, y:380, width: self.view.bounds.width, height: 15))
        motionYValueLabel.font = UIFont.systemFontOfSize(12)
        motionYValueLabel.textColor = UIColor.whiteColor()
        motionYValueLabel.text = "Y軸"
        self.view.addSubview(motionYValueLabel)
        
        motionZValueLabel = UILabel(frame: CGRect(x: 0, y: 460, width: self.view.bounds.width, height: 15))
        motionZValueLabel.font = UIFont.systemFontOfSize(12)
        motionZValueLabel.textColor = UIColor.whiteColor()
        motionZValueLabel.text = "Z軸"
        self.view.addSubview(motionZValueLabel)
        
        
        
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "Updated", userInfo: nil, repeats: true)
        
        

    }
    
    func onClickCameraButton(){
        
        let cameraDev: CameraView = CameraView()
        
        
        //imageView.modalTransitionStyle = UIModalTransitionStyle.PartialCurl
        
        //self.presentViewController(imageView, animated: true, completion: nil)
        
        cameraDev.modalTransitionStyle = UIModalTransitionStyle.PartialCurl
        self.presentViewController(cameraDev, animated: true, completion: nil)
        
    }

    
    func Updated(){
        switch selectedIndex{
        case 0:
            GraphView.colorLine = UIColor.greenColor()
            if(appDel.Temperture_array.count > 0){
                SensorMaxValue = appDel.Temperture_array.maxElement()!
                SensorMinValue = appDel.Temperture_array.minElement()!
                SensorAverageValue = calcAverage(appDel.Temperture_array)
                SensorCurrentValue = appDel.Temperture_array[appDel.Temperture_array.count-1]
                
                SensorMaxValueLabel.text = "最大値：" + String(SensorMaxValue) + " °C"
                SensorMinValueLabel.text = "最小値：" + String(SensorMinValue) + " °C"
                SensorAverageValueLabel.text = "平均値：" + String(SensorAverageValue) + " °C"
                SensorCurrentValueLabel.text = "現在値：" + String(SensorCurrentValue) + " °C"
            }
            break

            
        case 1:
            GraphView.colorLine = UIColor.blueColor()
            if(appDel.Barometer_array.count > 0){
                SensorMaxValue = appDel.Barometer_array.maxElement()!
                SensorMinValue = appDel.Barometer_array.minElement()!
                SensorAverageValue = calcAverage(appDel.Barometer_array)
                SensorCurrentValue = appDel.Barometer_array[appDel.Barometer_array.count-1]
                
                SensorMaxValueLabel.text = "最大値：" + String(SensorMaxValue) + " hPa"
                SensorMinValueLabel.text = "最小値：" + String(SensorMinValue) + " hPa"
                SensorAverageValueLabel.text = "平均値：" + String(SensorAverageValue) + " hPa"
                SensorCurrentValueLabel.text = "現在値：" + String(SensorCurrentValue) + " hPa"
            }
            
        case 2:
            GraphView.colorLine = UIColor.orangeColor()
            if(appDel.Humidity_array.count > 0){
                SensorMaxValue = appDel.Humidity_array.maxElement()!
                SensorMinValue = appDel.Humidity_array.minElement()!
                SensorAverageValue = calcAverage(appDel.Humidity_array)
                SensorCurrentValue = appDel.Humidity_array[appDel.Humidity_array.count-1]
                
                SensorMaxValueLabel.text = "最大値：" + String(SensorMaxValue) + " %"
                SensorMinValueLabel.text = "最小値：" + String(SensorMinValue) + " %"
                SensorAverageValueLabel.text = "平均値：" + String(SensorAverageValue) + " %"
                SensorCurrentValueLabel.text = "現在値：" + String(SensorCurrentValue) + " %"
            }
            break
            
        case 3:
            GraphView.colorLine = UIColor.redColor()
            if(appDel.useraddSensor_array.count > 0){
                SensorMaxValue = appDel.useraddSensor_array.maxElement()!
                SensorMinValue = appDel.useraddSensor_array.minElement()!
                SensorAverageValue = calcAverage(appDel.useraddSensor_array)
                SensorCurrentValue = appDel.useraddSensor_array[appDel.useraddSensor_array.count-1]
                
                if(appDel.useraddSensor_type == 2){
                    
                    
                    let MaxdB = 20 * log10(SensorMaxValue / 1.5)
                    let MindB = 20 * log10(SensorMinValue / 1.5)
                    let AvdD = 20 * log10(SensorAverageValue / 1.5)
                    let CurrentdB = 20 * log10(SensorCurrentValue / 1.5)
                    
                    SensorMaxValueLabel.text = "最大値：" + String(SensorMaxValue) + " mV " + String(MaxdB) + " dB"
                    SensorMinValueLabel.text = "最小値：" + String(SensorMinValue) + " mV " + String(MindB) + " dB"
                    SensorAverageValueLabel.text = "平均値：" + String(SensorAverageValue) + " mV " + String(AvdD) + " dB"
                    SensorCurrentValueLabel.text = "現在値：" + String(SensorCurrentValue) + " mV " + String(CurrentdB) + " dB"

                    
                }else {
                    SensorMaxValueLabel.text = "最大値：" + String(SensorMaxValue)
                    SensorMinValueLabel.text = "最小値：" + String(SensorMinValue)
                    SensorAverageValueLabel.text = "平均値：" + String(SensorAverageValue)
                    SensorCurrentValueLabel.text = "現在値：" + String(SensorCurrentValue)
                }
            }
            break
        case 4:
            GraphView.colorLine = UIColor(hue: 0.15, saturation: 0.7, brightness: 1.0, alpha: 1.0)
            //GraphView.colorTop = UIColor.grayColor()
            //GraphView.colorBottom = UIColor.grayColor()
            
            if(appDel.light_array.count > 0){
                SensorMaxValue = appDel.light_array.maxElement()!
                SensorMinValue = appDel.light_array.minElement()!
                SensorAverageValue = calcAverage(appDel.light_array)
                SensorCurrentValue = appDel.light_array[appDel.light_array.count-1]
                
                SensorMaxValueLabel.text = "最大値：" + String(SensorMaxValue) + " Lux"
                SensorMinValueLabel.text = "最小値：" + String(SensorMinValue) + " Lux"
                SensorAverageValueLabel.text = "平均値：" + String(SensorAverageValue) + " Lux"
                SensorCurrentValueLabel.text = "現在値：" + String(SensorCurrentValue) + " Lux"
            }
            break
            
        case 5:
            GraphView.colorLine = UIColor.purpleColor()
            if(appDel.Altitude_array.count > 0){
                SensorMaxValue = appDel.Altitude_array.maxElement()! - appDel.base_altitude
                SensorMinValue = appDel.Altitude_array.minElement()! - appDel.base_altitude
                SensorAverageValue = calcAverage(appDel.Altitude_array) - appDel.base_altitude
                SensorCurrentValue = appDel.Altitude_array[appDel.Altitude_array.count-1] - appDel.base_altitude
                
                SensorMaxValueLabel.text = "最大値：" + String(SensorMaxValue) + " m"
                SensorMinValueLabel.text = "最小値：" + String(SensorMinValue) + " m"
                SensorAverageValueLabel.text = "平均値：" + String(SensorAverageValue) + " m"
                SensorCurrentValueLabel.text = "現在値：" + String(SensorCurrentValue) + " m"
            }
            break
        default:
            GraphView.colorLine = UIColor.greenColor()
            if(appDel.Temperture_array.count > 0){
                SensorMaxValue = appDel.Temperture_array.maxElement()!
                SensorMinValue = appDel.Temperture_array.minElement()!
                SensorAverageValue = calcAverage(appDel.Temperture_array)
                SensorCurrentValue = appDel.Temperture_array[appDel.Temperture_array.count-1]
                
                SensorMaxValueLabel.text = "最大値：" + String(SensorMaxValue) + " °C"
                SensorMinValueLabel.text = "最小値：" + String(SensorMinValue) + " °C"
                SensorAverageValueLabel.text = "平均値：" + String(SensorAverageValue) + "°C"
                SensorCurrentValueLabel.text = "現在値：" + String(SensorCurrentValue) + " °C"
            }
            break
        }
        
        switch selectedMotionIndex {
        case 0:
            if(appDel.ax_array.count > 0){
                motionXValueLabel.text = "加速度　X軸：" + String(appDel.ax_array[appDel.ax_array.count - 1] / 1000) + " G"
            }
            if(appDel.ay_array.count > 0){
                motionYValueLabel.text = "加速度　Y軸：" + String(appDel.ay_array[appDel.ay_array.count - 1] / 1000) + " G"
            }
            if(appDel.az_array.count > 0){
                motionZValueLabel.text = "加速度　Z軸：" + String(appDel.az_array[appDel.az_array.count - 1] / 1000) + " G"
            }
            break
            
        case 1:
            if(appDel.gx_array.count > 0){
                motionXValueLabel.text = "ジャイロ　X軸：" + String(appDel.gx_array[appDel.gx_array.count - 1]) + " deg/s"
            }
            if(appDel.gy_array.count > 0){
                motionYValueLabel.text = "ジャイロ　Y軸：" + String(appDel.gy_array[appDel.gy_array.count - 1]) + " deg/s"
            }
            if(appDel.gz_array.count > 0){
                motionZValueLabel.text = "ジャイロ　Z軸：" + String(appDel.gz_array[appDel.gz_array.count - 1]) + " deg/s"
            }
            break
            
        case 2:
            if(appDel.mx_array.count > 0){
                motionXValueLabel.text = "地磁気　X軸：" + String(appDel.mx_array[appDel.mx_array.count - 1] / 10) + " uT(microtersa)"
            }
            if(appDel.my_array.count > 0){
                motionYValueLabel.text = "地磁気　Y軸：" + String(appDel.my_array[appDel.my_array.count - 1] / 10) + " uT(microtersa)"
            }
            if(appDel.mz_array.count > 0){
                motionZValueLabel.text = "地磁気　Z軸：" + String(appDel.mz_array[appDel.mz_array.count - 1] / 10) + " uT(microtersa)"
            }
            break
            
        default:
            if(appDel.ax_array.count > 0){
                motionXValueLabel.text = "加速度　X軸：" + String(appDel.ax_array[appDel.ax_array.count - 1] / 1000) + " G"
            }
            if(appDel.ay_array.count > 0){
                motionYValueLabel.text = "加速度　Y軸：" + String(appDel.ay_array[appDel.ay_array.count - 1] / 1000) + " G"
            }
            if(appDel.az_array.count > 0){
                motionZValueLabel.text = "加速度　Z軸：" + String(appDel.az_array[appDel.az_array.count - 1] / 1000) + " G"
            }
            break
            
        }
        
        GraphView.reloadGraph()
        MotionGraph1.reloadGraph()
        MotionGraph2.reloadGraph()
        MotionGraph3.reloadGraph()
        
    }
    
    func getRandomNumber(Min _Min : Float, Max _Max : Float)->Float {
        
        return ( Float(arc4random_uniform(UINT32_MAX)) / Float(UINT32_MAX) ) * (_Max - _Min) + _Min
    }
    
    //グラフのx軸の最大個数を返すメソッドを作成
    func numberOfPointsInLineGraph(graph: BEMSimpleLineGraphView) -> Int {
        //return SampleData.count
        
        if(graph.isEqual(MotionGraph1)){
            
            switch selectedMotionIndex {
            case 0:
                return appDel.ax_array.count
            case 1:
                return appDel.gx_array.count
            case 2:
                return appDel.mx_array.count
            default:
                return appDel.ax_array.count
            }
            
        }else if(graph.isEqual(MotionGraph2)){
            
            switch selectedMotionIndex {
            case 0:
                return appDel.ay_array.count
            case 1:
                return appDel.gy_array.count
            case 2:
                return appDel.my_array.count
            default:
                return appDel.ay_array.count
            }
            
        }else if(graph.isEqual(MotionGraph3)){
            
            switch selectedMotionIndex {
            case 0:
                return appDel.az_array.count
            case 1:
                return appDel.gz_array.count
            case 2:
                return appDel.mz_array.count
            default:
                return appDel.az_array.count
            }
            
        }else{
        
            switch selectedIndex{
            case 0:
                return appDel.Temperture_array.count
            case 1:
                return appDel.Barometer_array.count
            case 2:
                return appDel.Humidity_array.count
            case 3:
                return appDel.useraddSensor_array.count
            case 4:
                return appDel.light_array.count
            case 5:
                return appDel.Altitude_array.count
            default:
                return appDel.Temperture_array.count
            }
        }
    }
    
    // Y軸の値を返すメソッドを作成
    func lineGraph(graph: BEMSimpleLineGraphView, valueForPointAtIndex index: Int) -> CGFloat {
        
        if(graph.isEqual(MotionGraph1)){
            switch selectedMotionIndex{
            case 0:
                return CGFloat(appDel.ax_array[index])
            case 1:
                return CGFloat(appDel.gx_array[index])
            case 2:
                return CGFloat(appDel.mx_array[index])
            default:
                return CGFloat(appDel.ax_array[index])
            }
            
        
        }else if(graph.isEqual(MotionGraph2)){
            switch selectedMotionIndex{
            case 0:
                return CGFloat(appDel.ay_array[index])
            case 1:
                return CGFloat(appDel.gy_array[index])
            case 2:
                return CGFloat(appDel.my_array[index])
            default:
                return CGFloat(appDel.ay_array[index])
            }
            
        }else if(graph.isEqual(MotionGraph3)){
            
            switch selectedMotionIndex{
            case 0:
                return CGFloat(appDel.az_array[index])
            case 1:
                return CGFloat(appDel.gz_array[index])
            case 2:
                return CGFloat(appDel.mz_array[index])
            default:
                return CGFloat(appDel.az_array[index])
            }
            
        }else {
            switch selectedIndex{
            case 0:
                return CGFloat(appDel.Temperture_array[index])
                
            case 1:
                return CGFloat(appDel.Barometer_array[index])
            case 2:
                return CGFloat(appDel.Humidity_array[index])
            case 3:
                return CGFloat(appDel.useraddSensor_array[index])
            case 4:
                var lux: Float
                if(appDel.light_array[index] == 100000){
                    lux = 14000
                }else{
                    lux = appDel.light_array[index]
                }
                
                return CGFloat(lux)
                
            case 5:
                return CGFloat(appDel.Altitude_array[index] - appDel.base_altitude)
                
            default:
                return CGFloat(appDel.Temperture_array[index])
                
            }
        }
        
        
    }
    
    
    
    
        //return CGFloat(appDel.Barometer_array[index])
    
    // X軸のラベルを返すメソッドを作成
    //func lineGraph(graph: BEMSimpleLineGraphView, labelOnXAxisForIndex index: Int) -> String {
        
    //    return SampleLabel[index]
        
    //}
    
    
    
    func SegconChanged(segcon: UISegmentedControl){
        
        
       //SensorSegLabel.text = SensorSegArray[segcon.selectedSegmentIndex] as? String
        selectedIndex = segcon.selectedSegmentIndex
        currentSelectedSensorLabel.text = (SensorSegArray[segcon.selectedSegmentIndex] as! String)
        
    }
    
    func MotionSegconChanged(segcon: UISegmentedControl){
        selectedMotionIndex = segcon.selectedSegmentIndex
        
        
    }
    
    
    func calcAverage(array: [Float])->Float{
        
        var sum:Float = 0.0
        for (var i=0;i<array.count;i++){
            sum = sum + array[i]
        }
        
        let average = sum / Float(array.count)
        
        print(average)
        return average
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

