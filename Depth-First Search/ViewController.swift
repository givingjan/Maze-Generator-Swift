//
//  ViewController.swift
//  Depth-First Search
//
//  Created by JaN on 2016/10/26.
//  Copyright © 2016年 Yu-Jan-Chen. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    //MARK: Constant
    let kStartPoint_x = 0
    let kStartPoint_y = 64
    let kRow = 32
    let kColumn = 30
    let kLineWidth : CGFloat = 4.0
    let kNodeWidth : CGFloat = 10
    let kMazeBackgroundColor : UIColor = UIColor.black
    let kLineColor : CGColor = UIColor.white.cgColor
    
    //MARK: Variable
    var m_aryNodes : [MazeNode] = []
    var m_aryVisited : [Int] = []
    var m_aryDrawPoint : [(from : CGPoint, to : CGPoint)] = []
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        dfs(index: 4)
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            self.drawMaze()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //MARK:  Method
    
    /// Building maze by kRow & kColumn
    func initView() {
        self.view.backgroundColor = kMazeBackgroundColor
        
        for y in (0...kColumn-1) {
            for x in (0...kRow-1) {
                let node = MazeNode(x: x * Int(kNodeWidth) + kStartPoint_x, y: y * Int(kNodeWidth) + kStartPoint_y, index:y * kColumn + x)
                
                self.m_aryNodes.append(node)
            }
        }
    }
    
    func dfs(index : Int) {
        print("go \(index)")
        // add current index to Visited list.
        addVisited(index: index)
        // get an array of around indexes from current index.
        let aryAround = getAroundIndexsArray(index: index)
        // get next index from aryAround.
        let nextIndex = getRandomIndex(aryAround: aryAround)
        
        // if nextIndex is equals "-1", means the currentIndex has no around Index can go,
        // because every indexes around currentIndex are all visited.
        if nextIndex == -1 {
            // now we have no route to go,
            // so we back to the indexes of visited,
            // then check their around indexes list.
            // every time we get no route we will run for loop again
            // but there is a condition check in loop,
            // so infinite loop will not happen.
            print("--------\(index) has no route,trying to find in Visited List.-------")
            for i in self.m_aryVisited {
                print("looking for visited index ...\(i)")
                // if i has other around indexes can find, call this function again.
                if getAroundIndexsArray(index: i).count != 0 {
                    print("get a index has other routes --->\(i)")
                    dfs(index: i)
                }
            }
            print("----finish loop of currentIndex :\(index)")
        }
        // if nextIndex is not "-1", means we can go nextIndex.
        else
        {
            // add the fromPoint and toPoint, we will using it after finish all dfs.
            self.m_aryDrawPoint.append((from:self.m_aryNodes[index].point,to:self.m_aryNodes[nextIndex].point))
            dfs(index: nextIndex)
        }
    }
    
    func getRandomIndex(aryAround : [Int]) -> Int {
        // no around indexes we return "-1".
        if aryAround.count == 0 {
            return -1
        }
        // we trying to get a index from aryAround by random.
        else {
            let randomIndex : Int = Int(arc4random_uniform(UInt32(aryAround.count)))
            return aryAround[randomIndex]
        }
    }
    
    func getAroundIndexsArray(index : Int) -> [Int] {
        // we trying to find around indexes without visited.
        var aryAround : [Int] = []
        // left
        if index%kRow != 0 {
            if isVisited(index: index-1) == false {
                aryAround.append(index-1)
            }
        }
        // right
        if index%kRow != kRow-1 {
            if isVisited(index: index+1) == false {
                aryAround.append(index+1)
            }
        }
        // top
        if index >= kRow {
            if isVisited(index: index-kRow) == false {
                aryAround.append(index-kRow)
            }
        }
        // bottom
        if  index < self.m_aryNodes.count - kRow {
            if isVisited(index: index+kRow) == false {
                aryAround.append(index+kRow)
            }
        }
//        print("[\(index)] Around : [\(aryAround)]")
        
        return aryAround
    }
    
    
    func addVisited(index : Int) {
        if isVisited(index: index) == false {
            self.m_aryVisited.insert(index, at: 0)
        }
    }
    
    func isVisited(index : Int) -> Bool {
        for i in self.m_aryVisited {
            if i == index {
                return true
            }
        }
        
        return false
    }
    
    
    /// Drawing maze
    func drawMaze() {
        let layer = CAShapeLayer()
        layer.lineWidth = kLineWidth
        layer.strokeColor = kLineColor
        let path = UIBezierPath()
        
        for p in self.m_aryDrawPoint {
            var startPoint : CGPoint = CGPoint(x: p.from.x + kNodeWidth/2, y: p.from.y + kNodeWidth/2)
            var endPoint : CGPoint = CGPoint(x: p.to.x + kNodeWidth/2, y: p.to.y + kNodeWidth/2)
            // go left
            if p.from.x > p.to.x {
                startPoint = CGPoint(x: (p.from.x + kNodeWidth/2) + kLineWidth/2,
                                     y: (p.from.y + kNodeWidth/2))
                endPoint = CGPoint(x: (p.to.x + kNodeWidth/2) - kLineWidth/2,
                                     y: (p.to.y + kNodeWidth/2))
            }
            // go right
            else if p.from.x < p.to.x {
                startPoint = CGPoint(x: (p.from.x + kNodeWidth/2) - kLineWidth/2,
                                     y: (p.from.y + kNodeWidth/2))
                endPoint = CGPoint(x: (p.to.x + kNodeWidth/2) + kLineWidth/2,
                                   y: (p.to.y + kNodeWidth/2))
            }
            
            path.move(to:startPoint)
            path.addLine(to:endPoint)
            
            layer.path = path.cgPath
            self.view.layer.addSublayer(layer)
            animate(layer: layer)
        }
        
    }
    
    func animate(layer : CALayer) {
        let pathAnimation : CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = Double(self.m_aryDrawPoint.count) * 0.02
        pathAnimation.fromValue = 0.0
        pathAnimation.toValue = 2.0
        layer.add(pathAnimation, forKey: "strokeEnd")
    }
}
