//
//  ImageCollectionViewCell.swift
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

class ImageCollectionViewCell: UICollectionViewCell{
    
    let imageView = UIImageView()
    let numLabel = UILabel()
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstraint()
        
    }
    
    private func setupView(){
        
        self.backgroundColor = UIColor.lightGrayColor()
        imageView.contentMode = UIViewContentMode.ScaleToFill
        
        
        numLabel.font = UIFont.boldSystemFontOfSize(40.0)
        numLabel.textColor = UIColor.orangeColor()
        
        self.addSubview(imageView)
        self.addSubview(numLabel)
        
        
    }
    
    private func setupConstraint(){
        
        var viewConstraints = [NSLayoutConstraint]()
        
        // imageView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        viewConstraints.append(NSLayoutConstraint(item: imageView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0))
        viewConstraints.append(NSLayoutConstraint(item: imageView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        viewConstraints.append(NSLayoutConstraint(item: imageView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
        viewConstraints.append(NSLayoutConstraint(item: imageView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        
        // numLabel
        //numLabel.translatesAutoresizingMaskIntoConstraints = false
        //var numLabelConstraints = [NSLayoutConstraint]()
        //numLabelConstraints.append(NSLayoutConstraint(item: numLabel, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40.0))
        //viewConstraints.append(NSLayoutConstraint(item: numLabel, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        //viewConstraints.append(NSLayoutConstraint(item: numLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0))
        //viewConstraints.append(NSLayoutConstraint(item: numLabel, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        
        //numLabel.addConstraints(numLabelConstraints)
        self.addConstraints(viewConstraints)
        
    }
    
    func setupContents(num:Int, filePath:String){
        numLabel.text = "\(num)"
        
        imageView.image = UIImage(contentsOfFile: filePath)
    }
    
    
    
    
    
}