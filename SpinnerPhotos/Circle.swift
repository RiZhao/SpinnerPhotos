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
    
    var origin : CGPoint
    var radius : CGFloat
    
    func getPointInRelationToAngle(with point:CGPoint) -> (point: CGPoint, degree: Int){
        //calculate angle between the bottom point and the currently selected point
        //use the radians and radius to calculate for new x, y
        //translate the x, y to the view's bounds by applying the origin
        let v1 = CGVector(dx: radius, dy: 0)
        let v2 = CGVector(dx: point.x - origin.x, dy: point.y - origin.y)
        let angle = atan2(v2.dy, v2.dx) - atan2(v1.dy, v1.dx)
        var deg = angle * CGFloat(180.0 / Double.pi)
        if deg < 0 { deg += 360.0 }
        let x = radius * cos(angle) + origin.x
        let y = radius * sin(angle) + origin.y

        return (CGPoint(x: x, y: y), Int(deg))
    }
    
    func getPointWithDegree(_ degree: Int) -> CGPoint{
        let angle = CGFloat(degree.degreeToRad())
        return CGPoint(x: radius * cos(angle) + origin.x, y: radius * sin(angle) + origin.y)
    }
}
