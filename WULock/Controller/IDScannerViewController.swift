//
//  IDScannerViewController.swift
//  WUSTL Secure AR
//
//  Created by Michael Ginn on 11/12/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit
import ARKit

class IDScannerViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet weak var sceneView:ARSCNView!
    
    var searchingForRects = false
    var rectDetector:CIDetector?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.delegate = self
        
        let accuracy = [CIDetectorAccuracy:CIDetectorAccuracyHigh]
        rectDetector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: accuracy)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravity
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //adapted from https://github.com/mludowise/ARKitRectangleDetection
        guard let touch = touches.first,
            let currentFrame = sceneView.session.currentFrame else {
                return
        }
        
        let currentTouchLoc = touch.location(in: sceneView)
        findRectangle(locationInScene: currentTouchLoc, frame: currentFrame)
    }
    
    /**
     Takes a location and a frame and finds the rectangle in the scene (if it exists)
     */
    private func findRectangle(locationInScene location: CGPoint, frame currentFrame: ARFrame){
        guard let detector = rectDetector else{return}
        searchingForRects = true
        DispatchQueue.global(qos: .background).async {
            let ciimage = CIImage(cvPixelBuffer: currentFrame.capturedImage)
            
            let rects = detector.features(in: ciimage)
            if let rect = rects.first as? CIRectangleFeature{
                //self.drawRectFeature(rect)
                let result = self.drawHighlightOverlayForPoints(image: ciimage, topLeft: rect.topLeft, topRight: rect.topRight, bottomLeft: rect.bottomLeft, bottomRight: rect.bottomRight)
                let uiimage = UIImage(ciImage: result)
                DispatchQueue.main.sync {
                    let overlay = UIImageView(frame: self.view.bounds)
                    overlay.image = uiimage
                    self.view.addSubview(overlay)
                }
                print(result)
            }
        }
    }
    
    
    
    func drawHighlightOverlayForPoints(image: UIKit.CIImage, topLeft: CGPoint, topRight: CGPoint,
                                       bottomLeft: CGPoint, bottomRight: CGPoint) -> UIKit.CIImage {
        
        var overlay = UIKit.CIImage(color: CIColor(red: 1.0, green: 0.55, blue: 0.0, alpha: 0.45))
        overlay = overlay.cropped(to: image.extent)
        overlay = overlay.applyingFilter("CIPerspectiveTransformWithExtent",
                                         parameters: [
                                            "inputExtent": CIVector(cgRect: image.extent),
                                            "inputTopLeft": CIVector(cgPoint: topLeft),
                                            "inputTopRight": CIVector(cgPoint: topRight),
                                            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
                                            "inputBottomRight": CIVector(cgPoint: bottomRight)
            ])
        return overlay.composited(over: image)
    }
    
    private func drawRectFeature(_ rect:CIRectangleFeature){
        let path = UIBezierPath()
        path.move(to: rect.topLeft)
        path.addLine(to: rect.topRight)
        path.addLine(to: rect.bottomRight)
        path.addLine(to: rect.bottomLeft)
        path.addLine(to: rect.topLeft)
        path.close()
        
        print(path)
        let shapelayer = CAShapeLayer()
        shapelayer.path = path.cgPath
        shapelayer.fillColor = UIColor.blue.cgColor
        self.view.layer.addSublayer(shapelayer)
    }
    
}
