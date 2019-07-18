//
//  circle.swift
//  SpinnerPhotos
//
//  Created by Ri Zhao on 2019-07-17.
//  Copyright © 2019 Ri Zhao. All rights reserved.
//

import Foundation
import UIKit

struct Circle {
    
    enum quadrant {
        case topLeft, topRight, bottomLeft, bottomRight
    }
    
    var top : CGPoint
    var right : CGPoint
    var bottom : CGPoint
    var left : CGPoint
    var origin : CGPoint
    var radius : CGFloat
    func setBoundary(for point: CGPoint) -> CGPoint{
        return getY(with: CGPoint(x: min(max(point.x, self.left.x), self.right.x), y: min(max(point.y, self.top.y), self.bottom.y)))
    }
    
    func getY(with point:CGPoint) -> CGPoint{
        let v2 = CGVector(dx: bottom.x - origin.x, dy: bottom.y - origin.y)
        let v1 = CGVector(dx: point.x - origin.x, dy: point.y - origin.y)
        let angle = atan2(v2.dy, v2.dx) - atan2(v1.dy, v1.dx)
  
        let x = radius * sin(angle) + origin.x
        let y = radius * cos(angle) + origin.y
        print("x : \(x), y : \(y)")
//        print("radius \(radius)")
//        print("point x \(point.x - origin.x)")
//        print("multiply \((point.x - origin.x) * (point.x - origin.x))")
//        print("subtract \(radius - (point.x - origin.x) * (point.x - origin.x))")
//        print("square root \((radius - (point.x - origin.x) * (point.x - origin.x)).squareRoot())")
//        let y = abs((radius - (point.x - origin.x) * (point.x - origin.x)).squareRoot())
//        print(y)
        return CGPoint(x: x, y: y)
    }
    
    func findQuadrant(for point: CGPoint) -> quadrant{
        if point.x >= origin.x && point.y < origin.y{
            return quadrant.topRight
        }else if point.x > origin.x && point.y >= origin.y{
            return quadrant.bottomRight
        }else if point.x <= origin.x && point.y > origin.y{
            return quadrant.bottomLeft
        }else{
            return quadrant.topLeft
        }
    }
}
