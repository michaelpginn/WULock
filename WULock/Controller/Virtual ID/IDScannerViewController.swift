//
//  IDScannerViewController.swift
//  WUSTL Secure AR
//
//  Created by Michael Ginn on 11/12/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit
import ARKit
import CoreData

class IDScannerViewController: UIViewController, ARSCNViewDelegate, IDScannerAlertViewControllerDelegate {
    @IBOutlet weak var sceneView:ARSCNView!
    @IBOutlet weak var cameraButton: CameraButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var modeSegment: UISegmentedControl!
    @IBOutlet weak var detectLabel: UILabel!
    
    enum CaptureMode{
        case rect
        case wustlID
    }
    var currentMode:CaptureMode = .wustlID
    var searchingForRects = false
    var rectDetector:CIDetector?
    var currentPlaneNode:SCNNode?
    var typeOfCard:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.delegate = self
        
        let accuracy = [CIDetectorAccuracy:CIDetectorAccuracyHigh]
        rectDetector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: accuracy)
        
        if typeOfCard == CardImage.BACK_IMAGE_TYPE{
            modeSegment.isHidden = true
            modeSegment.isEnabled = false
            detectLabel.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        createSession()
    }
    
    private func createSession(){
        sceneView.session.pause()
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode() }
        
        let queue = DispatchQueue(label: "background")
        queue.async {
            if self.currentMode == .rect{
                let configuration = ARWorldTrackingConfiguration()
                configuration.worldAlignment = .gravity
                configuration.planeDetection = .horizontal
                self.sceneView.session.run(configuration, options: [ARSession.RunOptions.resetTracking, ARSession.RunOptions.removeExistingAnchors])
            }else{
                let configuration = ARImageTrackingConfiguration()
                if let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "Student ID", bundle: nil) {
                    configuration.trackingImages = referenceImages
                }
                self.sceneView.session.run(configuration, options: [ARSession.RunOptions.resetTracking, ARSession.RunOptions.removeExistingAnchors])
            }
        }
        
    }
    
    //MARK: Interface methods
    @IBAction func capture(sender: UIButton){
        guard let currentFrame = sceneView.session.currentFrame else {return}
        if currentMode == .rect{
            findRectangle(frame: currentFrame, completion: {
                image in
                DispatchQueue.main.async {
                    let alertController = IDScannerAlertViewController(image: image)
                    alertController.delegate = self
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }else{
            currentPlaneNode?.opacity = 0.0
            let image = getImageUsingSCNPlane(frame: currentFrame)
            let alertController = IDScannerAlertViewController(image: image)
            alertController.delegate = self
            self.present(alertController, animated: true, completion: nil)
            currentPlaneNode?.opacity = 1.0
        }
        
        
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changedSegment(_ sender: UISegmentedControl){
        if sender.selectedSegmentIndex == 0{
            currentMode = .wustlID
        }else{
            currentMode = .rect
        }
        createSession()
    }
    
    //MARK: Rect Detection
    
    private func findRectangle(frame currentFrame: ARFrame, completion:@escaping (UIImage)->Void){
        guard let detector = rectDetector else{return}
        searchingForRects = true
        DispatchQueue.global(qos: .background).async {
            let ciimage = CIImage(cvPixelBuffer: currentFrame.capturedImage)
            let focalLength = currentFrame.camera.intrinsics.columns.0.x
            
            let options:[String:Any] = [CIDetectorAspectRatio: 1.75, CIDetectorFocalLength: focalLength]
            
            
            let rects = detector.features(in: ciimage, options: options)
            if let rect = rects.first as? CIRectangleFeature{
                //self.drawRectFeature(rect)
                completion(self.convertRectFeatureToImage(rect: rect, ciimage:ciimage))
            }
        }
    }
    
    
    
    
    private func convertRectFeatureToImage(rect:CIRectangleFeature, ciimage:CIImage)->UIImage{

            //get the image using a perspective transform
            var rectCoords: [String:Any] = [:]
            rectCoords["inputTopLeft"] = CIVector(cgPoint: rect.bottomLeft)
            rectCoords["inputTopRight"] = CIVector(cgPoint: rect.topLeft)
            rectCoords["inputBottomLeft"] = CIVector(cgPoint: rect.bottomRight)
            rectCoords["inputBottomRight"] = CIVector(cgPoint: rect.topRight)
            let filteredImage = ciimage.applyingFilter("CIPerspectiveCorrection", parameters: rectCoords)
            
            //convert to cgimage
            let context = CIContext(options: nil)
            guard let cgImage = context.createCGImage(filteredImage, from: filteredImage.extent) else{return UIImage()}
        
            return UIImage(cgImage: cgImage)
        

    }
    
    //MARK: AR methods
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        if let imageAnchor = anchor as? ARImageAnchor{
            let size = imageAnchor.referenceImage.physicalSize
            let plane = SCNPlane(width: size.width, height: size.height)
            plane.cornerRadius = size.width / 34.0
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.blue.withAlphaComponent(0.5)
            plane.materials = [material]
            let planeNode = SCNNode(geometry: plane)
            planeNode.opacity = 1.0
            planeNode.eulerAngles.x = -.pi / 2
            currentPlaneNode = planeNode
            node.addChildNode(planeNode)
        }
    }
    
    func getImageUsingSCNPlane(frame:ARFrame)->UIImage{
        
        let image = sceneView.snapshot()
        print(image.size)
        
        guard let cgimage = image.cgImage else{return UIImage()}
        let ciimage = CIImage(cgImage: cgimage)
//        var ciimage = CIImage(cvPixelBuffer: frame.capturedImage)
//        ciimage = ciimage.oriented(.right)
        
        let ratio = ciimage.extent.maxX / sceneView.frame.width
        print(sceneView.frame.width)
        print(ratio)
        
        if let plane = currentPlaneNode{
            let localmax = plane.boundingBox.max //top right
            let localmin = plane.boundingBox.min //bottom left
            let max = plane.convertPosition(localmax, to: nil)
            let min = plane.convertPosition(localmin, to: nil)
            
            let projectedMax = sceneView.projectPoint(max)
            let projectedMin = sceneView.projectPoint(min)
            
            print("projmax: \(projectedMax), projmin: \(projectedMin)")
            print("imagebounds: \(ciimage.extent)")
            
            //coords are the same between ui and scn
            let projMaxX = CGFloat(projectedMax.x) * ratio
            let projMaxY = CGFloat(projectedMax.y) * ratio
            let projMinX = CGFloat(projectedMin.x) * ratio
            let projMinY = CGFloat(projectedMin.y) * ratio
            
            let height = ciimage.extent.height
            
            let bottomLeft = CGPoint(x: projMinX, y: height - projMinY)
            let bottomRight = CGPoint(x: projMaxX, y: height - projMinY)
            let topLeft = CGPoint(x: projMinX, y: height - projMaxY)
            let topRight = CGPoint(x: projMaxX, y: height - projMaxY)
            
            var rectCoords: [String:Any] = [:]
            rectCoords["inputTopLeft"] = CIVector(cgPoint: topLeft)
            rectCoords["inputTopRight"] = CIVector(cgPoint: topRight)
            rectCoords["inputBottomLeft"] = CIVector(cgPoint: bottomLeft)
            rectCoords["inputBottomRight"] = CIVector(cgPoint: bottomRight)
            let filteredImage = ciimage.applyingFilter("CIPerspectiveCorrection", parameters: rectCoords)
            
            //convert to cgimage
            let context = CIContext(options: nil)
            guard let cgImage = context.createCGImage(filteredImage, from: filteredImage.extent) else{return UIImage()}
            
            return UIImage(cgImage: cgImage)
        }else{
            return UIImage()
        }
    }
    
    /**
     Called when the user clicks the accept button in the alert.
     */
    func didAccept(image: UIImage) {
        guard let type = typeOfCard else{return}
        //save image
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjContext = appDelegate.managedObjectContext
        var imageRecord:CardImage? = nil
        
        //First find any record for this side of the card that already exist
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CardImage")
        fetchRequest.predicate = NSPredicate(format: "type==%@", type)
        
        do{
            let results = try managedObjContext.fetch(fetchRequest)
            if results.count > 0{
                imageRecord = results.first as? CardImage
            }
        }catch let e{
            print(e.localizedDescription)
        }
        
        //otherwise, create a new record in CoreData
        if imageRecord == nil{
            imageRecord = CardImage(context: managedObjContext)
        }
        
        imageRecord?.type = type
        if let imageData = image.pngData(){
            imageRecord?.imagedata = imageData as NSData
        }
        
        do{
            try managedObjContext.save()
        }catch{
            print("error saving image")
        }
        
        //notify
        let nc = NotificationCenter.default
        nc.post(Notification(name: Notification.Name("coredata-updated")))
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
//    func drawHighlightOverlayForPoints(image: UIKit.CIImage, topLeft: CGPoint, topRight: CGPoint,
//                                       bottomLeft: CGPoint, bottomRight: CGPoint) -> UIKit.CIImage {
//
//        var overlay = UIKit.CIImage(color: CIColor(red: 1.0, green: 0.55, blue: 0.0, alpha: 0.45))
//        overlay = overlay.cropped(to: image.extent)
//        overlay = overlay.applyingFilter("CIPerspectiveTransformWithExtent",
//                                         parameters: [
//                                            "inputExtent": CIVector(cgRect: image.extent),
//                                            "inputTopLeft": CIVector(cgPoint: topLeft),
//                                            "inputTopRight": CIVector(cgPoint: topRight),
//                                            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
//                                            "inputBottomRight": CIVector(cgPoint: bottomRight)
//            ])
//        return overlay.composited(over: image)
//    }
    
//    private func drawRectFeature(_ rect:CIRectangleFeature){
//        let path = UIBezierPath()
//        path.move(to: rect.topLeft)
//        path.addLine(to: rect.topRight)
//        path.addLine(to: rect.bottomRight)
//        path.addLine(to: rect.bottomLeft)
//        path.addLine(to: rect.topLeft)
//        path.close()
//
//        print(path)
//        let shapelayer = CAShapeLayer()
//        shapelayer.path = path.cgPath
//        shapelayer.fillColor = UIColor.blue.cgColor
//        self.view.layer.addSublayer(shapelayer)
//    }
    
    
    
}
