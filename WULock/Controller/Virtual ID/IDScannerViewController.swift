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
    
    var searchingForRects = false
    var rectDetector:CIDetector?
    
    var typeOfCard:String?
    
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
    
    //MARK: Interface methods
    @IBAction func capture(sender: UIButton){
        guard let currentFrame = sceneView.session.currentFrame else {return}
        findRectangle(frame: currentFrame)
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Rect Detection
    /**
     Takes a location and a frame and finds the rectangle in the scene (if it exists)
     */
    private func findRectangle(frame currentFrame: ARFrame){
        guard let detector = rectDetector else{return}
        searchingForRects = true
        DispatchQueue.global(qos: .background).async {
            let ciimage = CIImage(cvPixelBuffer: currentFrame.capturedImage)
            let focalLength = currentFrame.camera.intrinsics.columns.0.x
            
            let options:[String:Any] = [CIDetectorAspectRatio: 1.75, CIDetectorFocalLength: focalLength]
            
            
            
            let rects = detector.features(in: ciimage, options: options)
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
            
            //convert to cgimage
            let context = CIContext(options: nil)
            guard let cgImage = context.createCGImage(filteredImage, from: filteredImage.extent) else{return}
            
            let alertController = IDScannerAlertViewController(image: UIImage(cgImage: cgImage))
            alertController.delegate = self
            self.present(alertController, animated: true, completion: nil)
        }

    }
    
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
        print(image.cgImage)
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
