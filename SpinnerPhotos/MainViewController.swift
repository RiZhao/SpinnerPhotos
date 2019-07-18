//
//  MainViewController.swift
//  SpinnerPhotos
//
//  Created by Ri Zhao on 2019-07-17.
//  Copyright © 2019 Ri Zhao. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var spinnerView: UIView!{
        didSet{
            self.drawBezierPath()
        }
    }
    
    @IBOutlet weak var spinnerButtonView: UIView!
    
    var centerPoint: CGPoint! {
        didSet{
            self.spinnerButtonView.center = centerPoint
        }
    }
    
    var circle : Circle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dragPan = UIPanGestureRecognizer(target: self, action: #selector(dragEmotionOnBezier(recognizer:)))
        self.spinnerButtonView.addGestureRecognizer(dragPan)
    }
    
    func drawBezierPath() {
        let centerPoint = CGPoint(x: self.spinnerView.bounds.width * 0.5, y: self.spinnerView.bounds.height * 0.5)
        let radius = self.spinnerView.bounds.width * 0.4
        let circlePath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = UIColor.blue.cgColor
        shapeLayer.strokeColor = UIColor.green.cgColor
        shapeLayer.lineWidth = 3.0
        self.spinnerView.layer.addSublayer(shapeLayer)
        spinnerButtonView.translatesAutoresizingMaskIntoConstraints = false
        
        self.centerPoint = CGPoint(x: self.spinnerView.bounds.width * 0.5, y: self.spinnerView.bounds.height * 0.5 - self.spinnerView.bounds.width * 0.4)
        self.circle = Circle(top: CGPoint(x: centerPoint.x, y: centerPoint.y - radius), right: CGPoint(x: centerPoint.x + radius, y: centerPoint.y), bottom: CGPoint(x: centerPoint.x, y: centerPoint.y + radius), left: CGPoint(x: centerPoint.x - radius, y: centerPoint.y), origin: centerPoint, radius: radius)
    }

    
    @objc func dragEmotionOnBezier(recognizer: UIPanGestureRecognizer) {
        
        let point = recognizer.location(in: self.spinnerView)
        let newPoint = self.circle.getPointInRelationToAngle(with: point)
        self.centerPoint = newPoint
        
    }
    
    func getLocationOnPath(for point: CGPoint) -> CGPoint{
        return CGPoint()
    }

}

