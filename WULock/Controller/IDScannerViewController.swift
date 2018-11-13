//
//  IDScannerViewController.swift
//  WUSTL Secure AR
//
//  Created by Michael Ginn on 11/12/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit
import ARKit

class IDScannerViewController: UIViewController, ARSCNViewDelegate, IDScannerAlertViewControllerDelegate {
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
                self.displayAlertController(rect: rect, ciimage:ciimage)
            }
        }
    }
    
    private func displayAlertController(rect:CIRectangleFeature, ciimage:CIImage){
        DispatchQueue.main.sync {
            //get the image using a perspective transform
            var rectCoords: [String:Any] = [:]
            rectCoords["inputTopLeft"] = CIVector(cgPoint: rect.bottomLeft)
            rectCoords["inputTopRight"] = CIVector(cgPoint: rect.topLeft)
            rectCoords["inputBottomLeft"] = CIVector(cgPoint: rect.bottomRight)
            rectCoords["inputBottomRight"] = CIVector(cgPoint: rect.topRight)
            let filteredImage = ciimage.applyingFilter("CIPerspectiveCorrection", parameters: rectCoords)
            
            let alertController = IDScannerAlertViewController(image: UIImage(ciImage: filteredImage))
            alertController.delegate = self
            self.present(alertController, animated: true, completion: nil)
        }

    }
    
    func didAccept(image: UIImage) {
        
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
