//
//  MazeNode.swift
//  Depth-First Search
//
//  Created by JaN on 2016/10/28.
//  Copyright © 2016年 Yu-Jan-Chen. All rights reserved.
//

import UIKit

struct MazeNode {
    var x = 0
    var y = 0
    var index = 0    
    var point : CGPoint {
        return CGPoint(x: x, y: y)
    }
}

