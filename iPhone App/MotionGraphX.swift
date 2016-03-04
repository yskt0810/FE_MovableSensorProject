//
//  MotionGraphX.swift
//  FE_iOS2
//
//  Created by TsuchiyaYosuke on 2016/02/21.
//  Copyright © 2016年 net.ysklab. All rights reserved.
//

import Foundation
import UIKit

class MotionGraphX:BEMSimpleLineGraphView, BEMSimpleLineGraphDelegate,BEMSimpleLineGraphDataSource {
    
    
    var dataArray:[Float] = []
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        
    }
    
    
    //グラフのx軸の最大個数を返すメソッドを作成
    func numberOfPointsInLineGraph(graph: BEMSimpleLineGraphView) -> Int {
        
        return dataArray.count
        
    }
    
    // Y軸の値を返すメソッドを作成
    func lineGraph(graph: BEMSimpleLineGraphView, valueForPointAtIndex index: Int) -> CGFloat {
        
        return CGFloat(dataArray[index])
        
    }
    
    
}