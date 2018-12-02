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
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var currentPlane:SCNNode? = nil
    
    var instructionLists: [String: InstructionList] = [:]
    var currentInstructionListKey:String = "" 
    var currentInstructionList:InstructionList? {
        get{
            return instructionLists[currentInstructionListKey]
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        let scene = SCNScene()
        sceneView.scene = scene
        
        reloadInstructions()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadInstructions), name: Notification.Name("codes_changed"), object: nil)
    }
    
    @objc private func reloadInstructions(){
        //get saved codes, if there aren't any, cry
        if let gymLockerItem = VaultItem.getObjectForKey(key: CodeSelectionTableViewController.GYM_LOCKER_DEFAULTS_KEY), let code = gymLockerItem.parse(){
            let codeStrings = code.map { (num) -> String in
                return "\(num)"
            }
            instructionLists["gym_s40"] = Instruction.createS40InstructionList(numbers: codeStrings) //should come from record
        }
        
        if let mailboxItem = VaultItem.getObjectForKey(key: CodeSelectionTableViewController.MAILBOX_DEFAULTS_KEY), let code = mailboxItem.parse(){
            let codeStrings = code.map { (num) -> String in
                return "\(num)"
            }
            instructionLists["mailbox"] = Instruction.createMailboxInstructionList(combo: codeStrings)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        
        let queue = DispatchQueue(label: "background")
        queue.async {
            let configuration = ARImageTrackingConfiguration()
            if let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) {
                configuration.trackingImages = referenceImages
            }
            self.sceneView.session.run(configuration)
        }
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK: User interaction
    
    
    //MARK: ARSCNView Delegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("Seeing \((anchor as? ARImageAnchor)?.referenceImage.name ?? "")")
        if let imageAnchor = anchor as? ARImageAnchor{
            let referenceImage = imageAnchor.referenceImage
            guard let refName = referenceImage.name else{return}
            //figure out what we're seeing
            if refName.range(of: "gyms40") != nil{
                currentInstructionListKey = "gym_s40"
                
            }else if refName.range(of: "mailbox") != nil{
                currentInstructionListKey = "mailbox"
            }
            
            
            DispatchQueue.main.async {
                self.pageControl.numberOfPages = self.currentInstructionList?.count ?? 0
            }
            
            
            //get the plane of the anchor
            let planeNode = NodeCreationManager.createPlaneNode(size: referenceImage.physicalSize)
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
        
        
        if let current = currentInstructionList{
            let instruction = index == -1 ? current.getInstruction() : current.getInstruction(index: index)
            self.currentPlane?.addChildNode(instruction.node)
            //create text node
            self.currentPlane?.addChildNode(NodeCreationManager.createTextNode(text: instruction.text, height: current.height, fontSize: current.fontSize))
            
            DispatchQueue.main.async {
                self.pageControl.currentPage = current.index
            }
        }
        
    }
    
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
        if currentInstructionList != nil{
            guard let touch = touches.first else{return}
            let location = touch.location(in: self.view)
            if location.x > view.bounds.width / 2{
                currentInstructionList?.increment()
            }else if location.x < view.bounds.width / 2{
                currentInstructionList?.decrement()
            }
            displayInstruction()
        }
    }
}
