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
    
    var currentPlane:SCNNode? = nil
    
    var instructionLists: [String: InstructionList] = [:]
    var currentInstructionListKey:String = "gym_s40" // TODO: Change this
    var currentInstructionList:InstructionList? {
        get{
            return instructionLists[currentInstructionListKey]
        }
    }
    var currentInstructionListIndex = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        let scene = SCNScene()
        sceneView.scene = scene
        
        instructionLists["gym_s40"] = Instruction.createS40InstructionList(numbers: ["1","2","3","4"]) //should come from record
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
            
            //figure out what we're seeing
            if referenceImage.name == "gym_s40"{
                currentInstructionListKey = "gym_s40"
            }else if referenceImage.name?.range(of: "mailbox") != nil{
                currentInstructionListKey = "mailbox"
            }else if referenceImage.name == "gym_rec"{
                currentInstructionListKey = "gym_rec"
            }
            
            //get the plane of the anchor
            let plane = SCNPlane(width: referenceImage.physicalSize.width, height: referenceImage.physicalSize.height)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.clear
            plane.materials = [material]
            let planeNode = SCNNode(geometry: plane)
            planeNode.opacity = 1.0
            planeNode.eulerAngles.x = -.pi / 2
            node.addChildNode(planeNode)
            self.currentPlane = planeNode
            displayInstruction()
        }
    }
    
    func displayInstruction(index:Int = -1){
        //clear current instructions
        currentPlane?.enumerateChildNodes({ (node, stop) in
            node.removeFromParentNode()
        })
        
        let theIndex = index == -1 ? currentInstructionListIndex : index
        if let current = currentInstructionList{
            let instruction = current[theIndex]
            self.currentPlane?.addChildNode(instruction.node)
            //create text node
            self.currentPlane?.addChildNode(NodeCreationManager.createTextNode(text: instruction.text))
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let currentList = currentInstructionList{
            guard let touch = touches.first else{return}
            let location = touch.location(in: self.view)
            if location.x > view.bounds.width / 2 && currentInstructionListIndex < currentList.count - 1{
                currentInstructionListIndex += 1
            }else if location.x < view.bounds.width / 2 && currentInstructionListIndex > 0{
                currentInstructionListIndex -= 1
            }
            displayInstruction()
        }
    }
}
