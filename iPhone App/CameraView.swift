//
//  CameraView.swift
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


import UIKit
import AVFoundation
import Photos
import CoreImage


class CameraView: UIViewController ,UIGestureRecognizerDelegate{
    
    var input:AVCaptureDeviceInput!
    var output:AVCaptureStillImageOutput!
    var session:AVCaptureSession!
    var preview:UIView!
    var camera: AVCaptureDevice!
    var sendImage: UIImage!
    
    var screenWidth: CGFloat = 0.0
    var screenHeight: CGFloat = 0.0
    
    var Landscape: Bool = false
    
    var shootButton: UIButton = UIButton()
    var backButton: UIButton = UIButton()
    
    var animateActivity: Bool!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // 画面タップでシャッターを切るための設定
        //let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapped:")
        
        //デリゲートに追加
        //tapGesture.delegate = self
        
        // Viewに追加
        //self.view.addGestureRecognizer(tapGesture)
        
        let TappedAction: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "viewTapped:")
        TappedAction.delegate = self
        self.view.addGestureRecognizer(TappedAction)
        
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onOrientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
    }
    
    // 向きが変わったら呼び出す
    func onOrientationChanged(notification: NSNotification){
        
        
        let deviceOrientation: UIDeviceOrientation! = UIDevice.currentDevice().orientation
        
        if UIDeviceOrientationIsLandscape(deviceOrientation){
            
            // 横向き判定
            //screenWidth = UIScreen.mainScreen().bounds.size.height
            //screenHeight = UIScreen.mainScreen().bounds.size.width
            
            Landscape = true
            print("端末の向きが横に")
            
        }else{
            
            // 縦向き判定
            //screenWidth = UIScreen.mainScreen().bounds.size.width
            //screenHeight = UIScreen.mainScreen().bounds.size.height
            Landscape = false
            print("端末の向きが縦に")
        }
        
        preview = UIView(frame: CGRectMake(0.0,0.0,screenWidth,screenHeight))
        
    }
    
    // メモリ管理のために
    override func viewWillAppear(animated: Bool) {
        
        setupDisplay()
        
        setupCamera()
        
    }
    
    // メモリ管理のために
    override func viewDidDisappear(animated: Bool) {
        
        session.stopRunning()
        
        for output in session.outputs {
            session.removeInput(input as? AVCaptureInput)
        }
        
        session = nil
        camera = nil
        
        print("Session Stopped")
        
    }
    
    // setup display
    func setupDisplay(){
        
        // スクリーンの幅
        screenWidth = UIScreen.mainScreen().bounds.size.width
        
        // スクリーンの高さ
        screenHeight = UIScreen.mainScreen().bounds.size.height
        
        preview = UIView(frame: CGRectMake(0.0,0.0,screenWidth,screenHeight))
        
        
        
    }
    
    
    // setup camera
    func setupCamera(){
        
        // セッション
        session = AVCaptureSession()
        
        session.sessionPreset = AVCaptureSessionPresetPhoto
        
        for captureDevice: AnyObject in AVCaptureDevice.devices(){
            
            // 背面カメラを取得
            if captureDevice.position == AVCaptureDevicePosition.Back {
                camera = captureDevice as? AVCaptureDevice
                try! camera.lockForConfiguration()
                camera.focusMode = .AutoFocus
                camera.unlockForConfiguration()
                
            }
            
        }
        
        
        // カメラからの入力データ
        do {
            input = try AVCaptureDeviceInput(device: camera) as AVCaptureDeviceInput
        }catch let error as NSError{
            print(error)
        }
        
        // 入力をセッションに追加
        if(session.canAddInput(input)){
            
            session.addInput(input)
            
        }
        
        // 静止画出力のインスタンス生成
        output = AVCaptureStillImageOutput()
        
        // 出力をセッションに追加
        if(session.canAddOutput(output)){
            session.addOutput(output)
        }
        
        // セッションからプレビューを表示
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        previewLayer.frame = preview.frame
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        // レイヤーをViewに設定
        // これを外すとプレビューがなくなる、けれど撮影はできる
        self.view.layer.addSublayer(previewLayer)
        
        
        shootButton = UIButton(frame: CGRectMake(0,0,120,50))
        shootButton.backgroundColor = UIColor.redColor()
        shootButton.layer.masksToBounds = true
        shootButton.setTitle("撮影", forState: UIControlState.Normal)
        shootButton.layer.cornerRadius = 2.0
        shootButton.layer.position = CGPoint(x: self.view.frame.width/2 - 70, y: self.view.frame.height-100 )
        shootButton.addTarget(self, action: "ButtonTapped", forControlEvents: .TouchUpInside)
        self.view.addSubview(shootButton)
        
        backButton = UIButton(frame: CGRectMake(0,0,120,50))
        backButton.backgroundColor = UIColor.redColor()
        backButton.layer.masksToBounds = true
        backButton.setTitle("戻る", forState: UIControlState.Normal)
        backButton.layer.cornerRadius = 2.0
        backButton.layer.position = CGPoint(x: self.view.frame.width/2 + 70, y: self.view.frame.height - 100)
        backButton.addTarget(self, action: "backButtonTapped", forControlEvents: .TouchUpInside)
        self.view.addSubview(backButton)
        
        session.startRunning()
        print("Session start")
        
    }
    
    func viewTapped(sender: UIGestureRecognizer){
        print("tapped \(sender.locationInView(view))")
        let location:CGPoint = sender.locationInView(preview)
        let viewSize: CGSize = self.view.bounds.size
        let pointofInterest: CGPoint = CGPointMake(location.y / viewSize.height, 1.0 - location.x / viewSize.width)
        //let pointofInterest: CGPoint = CGPointMake(1.0 - location.x / viewSize.width, location.y / viewSize.height)
        
        if(camera.isFocusModeSupported(AVCaptureFocusMode.AutoFocus)){
            do{
                try self.camera.lockForConfiguration()
                self.camera.focusPointOfInterest = pointofInterest
                self.camera.focusMode = AVCaptureFocusMode.AutoFocus
                self.camera.unlockForConfiguration()
                
            }catch let error {
                print (error)
            }
            
        }
    }
    
    
    
    // タップイベント
    func ButtonTapped(){
        
        print("タップ")
        takeStillPicture()
        
        
    }
    
    func backButtonTapped(){
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    
    func takeStillPicture(){
        
        // ビデオ出力に接続
        if let connection:AVCaptureConnection? = output.connectionWithMediaType(AVMediaTypeVideo){
            
            //ビデオ出力から画像を非同期で取得
            output.captureStillImageAsynchronouslyFromConnection(connection, completionHandler: {(imageDataBuffer, error) -> Void in
                
                // 取得画像のDataBufferをJpegに変換
                let imageData:NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataBuffer)
                
                // JpegからUIImageを作成
                //let image:UIImage = UIImage(data: imageData)!
                self.sendImage = UIImage(data:imageData)!
                
                let imageView:SavePhotoView = SavePhotoView()
                
                imageView.image = self.sendImage
                imageView.LandScape = self.Landscape
                
                //imageView.SetImage(imageData)
                
                imageView.modalTransitionStyle = UIModalTransitionStyle.PartialCurl
                
                self.presentViewController(imageView, animated: true, completion: nil)
                
                
                
                
                // アルバムに追加
                //UIImageWriteToSavedPhotosAlbum(self.sendImage, self, nil, nil)
                
                
            })
            
        }
        
        
    }
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
