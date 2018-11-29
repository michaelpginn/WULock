//
//  ARToolsViewController.swift
//  WUSTL Secure AR
//
//  Created by Michael Ginn on 11/9/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit
import ARKit

class ARToolsViewController: UIViewController, ARSCNViewDelegate {
    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        let scene = SCNScene()
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        
        
        let configuration = ARImageTrackingConfiguration()
        if let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) {
           configuration.trackingImages = referenceImages
        }
        sceneView.session.run(configuration)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK: ARSCNView Delegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("Seeing \((anchor as? ARImageAnchor)?.referenceImage.name ?? "")")
        if let imageAnchor = anchor as? ARImageAnchor{
            let referenceImage = imageAnchor.referenceImage
            
            //figure out which type of image it is
            let plane = SCNPlane(width: referenceImage.physicalSize.width, height: referenceImage.physicalSize.height)
            let planeNode = SCNNode(geometry: plane)
            planeNode.opacity = 0.20
            planeNode.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode)
        }
    }
    
    
    
    // TODO: Overlay instructions either for lock, gym locker (estrogym), or gym locker (rec center)
    // TODO: If the user has saved a locker or mail combo, display choice somewhere
    /* Plan:
     - Search for records of type gym locker or mail
     - Display a button somewhere on ARKit, "Choose combination"
     - When clicked, show a little popup that has, separated into two categories, mail room and gym
     - For each, show all records matching, with selection indicator
     - When one is selected, dismiss
     - Detect reference image, check against known images
     - If mail room: show mail room steps using curved arrows (animated?)
     - If gym: show buttons using arrows
     - User can advance to next step by tapping right side of screen, go back by tapping left side
        *how to indicate?
     - when done, show restart button
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }

}
