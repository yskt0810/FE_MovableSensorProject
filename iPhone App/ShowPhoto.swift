//
//  ShowPhoto.swift
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

class ShowPhoto:UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    
    var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let fileManager = NSFileManager.defaultManager()
    //
    let dir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0].stringByAppendingPathComponent("photo/thumb")
    
    var collectionView: UICollectionView!
    var flowLayout = UICollectionViewFlowLayout()
    var imageItems:[String] = []
    var imgFilePath:String = ""
    
    init(){
        super.init(nibName: nil, bundle: nil)
        
        self.view.backgroundColor = UIColor.whiteColor()
        //self.tabBarItem = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.Featured, tag:2)
        
        self.tabBarItem.image = UIImage(named: "albumicon.png")
        self.tabBarItem.title = "Photos"
        
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
        imageItems = self.getFileNames()
        
        flowLayout.scrollDirection = .Vertical
        flowLayout.minimumInteritemSpacing = 1.0
        flowLayout.minimumLineSpacing = 1.0
        flowLayout.itemSize = CGSizeMake((self.view.bounds.width/3) - 2, ((self.view.bounds.width/3)/4)*3)
        flowLayout.headerReferenceSize = CGSizeMake(0, 50)
        
        // コレクションビュー作成
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        collectionView.registerClass(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCell")
        collectionView.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        
        setupConstraints()
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        
        flowLayout = UICollectionViewFlowLayout()
        
        
        
    }
    
    private func setupConstraints(){
        
        var viewConstraints = [NSLayoutConstraint]()
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        viewConstraints.append(NSLayoutConstraint(item: collectionView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0.0))
        viewConstraints.append(NSLayoutConstraint(item: collectionView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
        viewConstraints.append(NSLayoutConstraint(item: collectionView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        viewConstraints.append(NSLayoutConstraint(item: collectionView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        
        // ビューに制約を追加
        view.addConstraints(viewConstraints)
        
    }
    
    // 回転を有効にするか
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    // 回転できる方向
    //func supportedInterfaceOrientations() -> Int {
    //    return Int(UIInterfaceOrientationMask.All.rawValue) // 値がUIntなので、Int型に変換
    //}
    
    // 画面回転する前の処理
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        // 縦画面では縦にスクロール、横画面では横にスクロールする。
        // 処理が行われたかわかりにくいので、collectionViewの背景色を画面方向によって変更
        if toInterfaceOrientation == .Portrait
            || toInterfaceOrientation == .PortraitUpsideDown{
                
                flowLayout.scrollDirection = .Vertical
                collectionView.backgroundColor = UIColor.whiteColor()
                
        }else if toInterfaceOrientation == .LandscapeLeft
            || toInterfaceOrientation == .LandscapeRight{
                
                flowLayout.scrollDirection = .Horizontal
                collectionView.backgroundColor = UIColor.whiteColor()
                
        }else{
            // 画面回転方向がunknownのときは縦にスクロール
            flowLayout.scrollDirection = .Vertical
            collectionView.backgroundColor = UIColor.orangeColor()
        }
    }
    
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageItems.count  // 4.CollectionViewにAutoLayoutを使用したカスタムセルを表示する
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCollectionViewCell
        cell.setupContents(indexPath.row, filePath:imageItems[indexPath.row])
        let TappedAction: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "ImageSelected:")
        cell.addGestureRecognizer(TappedAction)
        cell.userInteractionEnabled = true
        
        
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let headerReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "header", forIndexPath: indexPath) as UICollectionReusableView
        headerReusableView.backgroundColor = UIColor.whiteColor()
        
        return headerReusableView
    }
    
    
    
    func getFileNames()->[String]{
        
        //var error:NSError? = nil
        var filenames:[AnyObject] = []
        do{
            filenames =  try fileManager.contentsOfDirectoryAtPath(dir)
        }catch {
            print("Unable to filenames")
        }
        
        var tmp:[String] = []
        for filename:AnyObject in filenames {
            
            let path = dir + "/" + (filename as! String)
            
            tmp.append(path)
            
        }
        
        return tmp
        
        
    }
    
    func ImageSelected(sender:UITapGestureRecognizer){
        
        let touch = sender.locationInView(collectionView)
        let indexPath = collectionView.indexPathForItemAtPoint(touch)
        let tmpFilePath:String = imageItems[indexPath!.row]
        var tmpArr:[String] = tmpFilePath.componentsSeparatedByString("/")
        imgFilePath = (tmpArr.removeLast()).stringByReplacingOccurrencesOfString("thumb_", withString: "")
        
        
        
        let details: ShowDetailOfPhoto = ShowDetailOfPhoto()
        details.filename = imgFilePath
        details.setImage()
        
        
        details.modalTransitionStyle = UIModalTransitionStyle.PartialCurl
        
        presentViewController(details, animated: true, completion: nil)
        
        
        
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