//
//  MainViewController.swift
//  SpinnerPhotos
//
//  Created by Ri Zhao on 2019-07-17.
//  Copyright © 2019 Ri Zhao. All rights reserved.
//

import UIKit

/*
 P1) Make an app with a wheel in the middle of the screen, with a button at the top of the wheel. The button should display where it is on the wheel in degrees(0-360). The user should be able to drag the button around the wheel, and the button text should update to show its new value. Pressing the button will cause the button to rotate around the wheel a random amount, again updating it's displayed value.
 
 P2) Pick a number between 10-20(we'll call it X). Load X random images from the users camera roll into a queue at the bottom of the screen. When the user presses the button in the wheel, as the button rotates around the wheel, the background of the app should display the image in the queue which correlates with the current position of the button. So if X = 10, and if the button has a current value of 0 degrees, the first image in the queue should display as the background image. When the button value changes to 36, the background image should change to the second image in the queue. Every time the user presses the button, X should regenerate and a new selection of images should be loaded
 
 */

class MainViewController: UIViewController {

    @IBOutlet weak var spinnerView: UIView!{
        didSet{
            self.drawBezierPath()
        }
    }

    
    @IBOutlet weak var spinnerButtonView: UIView!{
        didSet{
            let label = UILabel(frame: spinnerButtonView.bounds)
            spinnerButtonView.addSubview(label)
            label.textColor = .white
            label.textAlignment = .center
            
            spinnerButtonView.clipsToBounds = false
            spinnerButtonView.bounds = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 50))
            spinnerButtonView.layer.cornerRadius = 5.0
            
            let dragPan = UIPanGestureRecognizer(target: self, action: #selector(dragEmotionOnBezier(recognizer:)))
            spinnerButtonView.addGestureRecognizer(dragPan)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(spinnerButtonTapped(recognizer:)))
            spinnerButtonView.addGestureRecognizer(tap)
            tap.require(toFail: dragPan)
        }
    }
    
    var centerPoint: CGPoint! {
        didSet{
            self.spinnerButtonView.center = centerPoint
        }
    }
    
    var circle : Circle!
    
    var currentDegree: Int!{
        didSet{
            for view in self.spinnerButtonView.subviews{
                if let label = view as? UILabel{
                    label.text = "\(String(currentDegree!))"
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        self.spinnerView.layer.insertSublayer(shapeLayer, below: self.spinnerButtonView.layer)
        spinnerButtonView.translatesAutoresizingMaskIntoConstraints = false
        
        self.centerPoint = CGPoint(x: self.spinnerView.bounds.width * 0.5, y: self.spinnerView.bounds.height * 0.5 - self.spinnerView.bounds.width * 0.4)
        self.currentDegree = 270
        self.circle = Circle(top: CGPoint(x: centerPoint.x, y: centerPoint.y - radius), right: CGPoint(x: centerPoint.x + radius, y: centerPoint.y), bottom: CGPoint(x: centerPoint.x, y: centerPoint.y + radius), left: CGPoint(x: centerPoint.x - radius, y: centerPoint.y), origin: centerPoint, radius: radius)
    }

    
    @objc func dragEmotionOnBezier(recognizer: UIPanGestureRecognizer) {
        let point = recognizer.location(in: self.spinnerView)
        let circleData = self.circle.getPointInRelationToAngle(with: point)
        
        self.currentDegree = circleData.degree
        
        self.centerPoint = circleData.point
    }

    @objc func spinnerButtonTapped(recognizer: UITapGestureRecognizer) {
        self.animateButtonRandomly()
    }
    
    func animateButtonRandomly(){
        let centerPoint = CGPoint(x: self.spinnerView.bounds.width * 0.5, y: self.spinnerView.bounds.height * 0.5)
        let radius = self.spinnerView.bounds.width * 0.4
        let randomDegree = Int.random(in: 0..<360)
        let circlePath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: CGFloat(currentDegree.degreeToRad()), endAngle:CGFloat(randomDegree.degreeToRad()), clockwise: true)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.centerPoint = self.circle.getPointWithDegree(randomDegree)
            self.currentDegree = randomDegree
        }
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = circlePath.cgPath
        // I set this one to make the animation go smoothly along the path
        animation.calculationMode = CAAnimationCalculationMode.paced
        animation.duration = 1.5
        self.spinnerButtonView.layer.add(animation, forKey: nil)
        self.centerPoint = self.circle.getPointWithDegree(randomDegree)

        CATransaction.commit()
    }
}

extension Int{
    func degreeToRad() -> Double{
        return Double(self) * Double.pi / 180
    }
}
