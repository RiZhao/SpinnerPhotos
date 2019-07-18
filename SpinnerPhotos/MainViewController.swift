//
//  MainViewController.swift
//  SpinnerPhotos
//
//  Created by Ri Zhao on 2019-07-17.
//  Copyright © 2019 Ri Zhao. All rights reserved.
//

import UIKit
import Photos

let numberOfImages = 20

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var backgroundImageView: UIImageView!

    @IBOutlet weak var photosCollectionView: UICollectionView!{
        didSet{
            photosCollectionView.dataSource = self
            photosCollectionView.delegate = self
        }
    }
    
    @IBOutlet weak var spinnerView: UIView!
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
    
    var centerPoint: CGPoint!{
        didSet{
            //set the spinnerButtonView's center whenever the centerPoint is set
            self.spinnerButtonView.center = centerPoint
        }
    }
    
    var circle : Circle!
    var currentDegree: Int!{
        didSet{
            //update the label text whenever the current degree is set
            for view in self.spinnerButtonView.subviews{
                if let label = view as? UILabel{
                    label.text = "\(String(currentDegree!))"
                }
            }
            self.indexBasedOnDegree = self.currentDegree / (360 / numberOfImages)
        }
    }
    
    var indexBasedOnDegree: Int!{
        didSet{
            //check to see if the value of the index has changed because the value might not have changed if it has not changed a certain amount
            if oldValue != indexBasedOnDegree{
                let indexPath = IndexPath(row: indexBasedOnDegree, section: 0)
                self.photosCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
                self.setBackGroundImage(for: indexPath)
            }
        }
    }
    
    var images = [PHAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestPermissionAndSetup()
    }
    
    func drawBezierPath() {
        // set the origin point based on the bounds of the view
        let origin = CGPoint(x: self.spinnerView.bounds.width * 0.5, y: self.spinnerView.bounds.height * 0.5)
        
        //create a radius
        let radius = self.spinnerView.bounds.width * 0.4
        
        //create the path based on origin and radius
        let circlePath = UIBezierPath(arcCenter: origin, radius: radius, startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        //draw the path
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.green.cgColor
        shapeLayer.lineWidth = 3.0
        self.spinnerView.layer.insertSublayer(shapeLayer, below: self.spinnerButtonView.layer)
        spinnerButtonView.translatesAutoresizingMaskIntoConstraints = false
        
        //initialize center point of the spinner button
        self.centerPoint = CGPoint(x: origin.x + radius, y: self.spinnerView.bounds.height * 0.5)
        self.currentDegree = 0
        
        //initialize circle struct for calculating location of spinner button
        self.circle = Circle(origin: origin, radius: radius)
    }

    
    @objc func dragEmotionOnBezier(recognizer: UIPanGestureRecognizer){
        let point = recognizer.location(in: self.spinnerView)
        let circleData = self.circle.getPointInRelationToAngle(with: point)
        
        self.currentDegree = circleData.degree
        self.centerPoint = circleData.point
    }

    @objc func spinnerButtonTapped(recognizer: UITapGestureRecognizer) {
        self.animateButtonRandomly()
        self.reloadNewPhotos()
        
    }
    
    func animateButtonRandomly(){
        let origin = CGPoint(x: self.spinnerView.bounds.width * 0.5, y: self.spinnerView.bounds.height * 0.5)
        let radius = self.spinnerView.bounds.width * 0.4
        
        //create path with random degree from 0-359 so it won't go back to same location
        let randomDegree = Int.random(in: (360 / numberOfImages)..<360)
        let circlePath = UIBezierPath(arcCenter: origin, radius: radius, startAngle: CGFloat(currentDegree.degreeToRad()), endAngle:CGFloat(randomDegree.degreeToRad()), clockwise: true)
        
        //animate spinner button according to path
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.centerPoint = self.circle.getPointWithDegree(randomDegree)
            self.currentDegree = randomDegree
        }
        
        //calculate percentage of the circle the button needs to travel
        //use the percentage to apply to the animation duration so animation time is adjusted to match the distance being travelled
        let percentageOfCircle = randomDegree > currentDegree ? Double(randomDegree - currentDegree) / 360.0 : Double(360 + randomDegree - currentDegree) / 360.0
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = circlePath.cgPath
        // I set this one to make the animation go smoothly along the path
        animation.calculationMode = CAAnimationCalculationMode.paced
        animation.duration = percentageOfCircle * 1.5
        self.spinnerButtonView.layer.add(animation, forKey: nil)
        self.centerPoint = self.circle.getPointWithDegree(randomDegree)

        CATransaction.commit()
    }
}

// MARK: CollectionViewController Section
extension MainViewController{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfImages
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photocell", for: indexPath) as! PhotosCollectionViewCell
        if images.count > indexPath.row{
            let asset = images[indexPath.row]
            let manager = PHImageManager.default()
            if cell.tag != 0 {
                manager.cancelImageRequest(PHImageRequestID(cell.tag))
            }
            cell.tag = Int(manager.requestImage(for: asset,
                                                targetSize: CGSize(width: 120.0, height: 120.0),
                                                contentMode: .aspectFill,
                                                options: nil) { (result, _) in
                                                    cell.photoView.image = result
            })
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height * 0.9
        return CGSize(width: height, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: Photos Functions
extension MainViewController{
    func requestPermissionAndSetup(){
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                print("Good to proceed")
                DispatchQueue.main.async {
                    self.getImages()
                    self.drawBezierPath()
                }
            case .denied, .restricted:
                print("Not allowed")
            case .notDetermined:
                print("Not determined yet")
            @unknown default:
                print("unknown")
            }
        }
    }
    
    func getImages(){
        //create a fetch option that returns the photos with the latest being first
        let options = PHFetchOptions()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        options.sortDescriptors = [sortDescriptor]
        let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: options)
        //store the images in an array
        assets.enumerateObjects({ (object, count, stop) in
            self.images.append(object)
        })
        
        self.photosCollectionView.reloadData()
    }
    
    func reloadNewPhotos(){
        self.images.removeFirst(numberOfImages)
        self.photosCollectionView.reloadData()
    }
    
    func setBackGroundImage(for indexPath: IndexPath){
        guard images.count > indexPath.row else{
            return
        }
        let asset = images[indexPath.row]
        let manager = PHImageManager.default()
        //request for image and set view's background image to result
        manager.requestImage(for: asset,targetSize: CGSize(width: self.view.frame.width, height: self.view.frame.height), contentMode: .aspectFill, options: nil) { (result, _) in
                self.backgroundImageView.image = result
            }
        }
}

extension Int{
    func degreeToRad() -> Double{
        return Double(self) * Double.pi / 180
    }
}
