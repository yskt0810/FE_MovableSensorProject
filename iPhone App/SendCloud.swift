//
//  Cloud.swift
//  FE_iOS2
//
//  Created by TsuchiyaYosuke on 2016/02/01.
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

class SendCloud:NSObject,NSURLSessionDelegate,NSURLSessionDataDelegate{
    
    
    let ServerConfig:NSURLSessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("backgroundTask")
    var ServerRequest:NSMutableURLRequest = NSMutableURLRequest()
    var SendDataString:NSString = ""
    var SendData:NSData = NSData()
    
    var ServerUrl:NSURL = NSURL()
    
    var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func SendSensorToServer(PeripheralUUID:String, SensorData: String){
        
        
        ServerUrl = NSURL(string: "https://ysklab.sakura.ne.jp/test/test.php")!
        
        ServerRequest = NSMutableURLRequest(URL: ServerUrl)
        ServerRequest.HTTPMethod = "POST"
        
        SendDataString = "uuid=" + (appDelegate.uuid as String) + "&data=" + SensorData
        SendData = SendDataString.dataUsingEncoding(NSUTF8StringEncoding)!
        ServerRequest.HTTPBody = SendData
        
        print(SendDataString)
        
        NSURLConnection.sendAsynchronousRequest(ServerRequest, queue: NSOperationQueue.mainQueue(), completionHandler: self.getHTTP)
    }
    
    func getHTTP(res:NSURLResponse?, data:NSData?, error:NSError?){
        
        if let HTTPResponse = res as? NSHTTPURLResponse {
            print(HTTPResponse.statusCode)
        }
        
    }
}