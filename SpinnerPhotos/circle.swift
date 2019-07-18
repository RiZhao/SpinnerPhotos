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
    
    var top : CGPoint
    var right : CGPoint
    var bottom : CGPoint
    var left : CGPoint
    var origin : CGPoint
    var radius : CGFloat
    
    func getPointInRelationToAngle(with point:CGPoint) -> CGPoint{
        let v2 = CGVector(dx: bottom.x - origin.x, dy: bottom.y - origin.y)
        let v1 = CGVector(dx: point.x - origin.x, dy: point.y - origin.y)
        let angle = atan2(v2.dy, v2.dx) - atan2(v1.dy, v1.dx)
  
        let x = radius * sin(angle) + origin.x
        let y = radius * cos(angle) + origin.y

        return CGPoint(x: x, y: y)
    }
    
}
