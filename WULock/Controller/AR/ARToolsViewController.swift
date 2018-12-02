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
    @IBOutlet weak var notificationView: UIVisualEffectView!
    @IBOutlet weak var notificationLabel: UILabel!
    
    var currentPlane:SCNNode? = nil
    
    var instructionLists: [String: InstructionList] = [:]
    var currentInstructionListKey:String = "" 
    var currentInstructionList:InstructionList? {
        get{
            return instructionLists[currentInstructionListKey]
        }
    }
    
    var instructionShown = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        let scene = SCNScene()
        sceneView.scene = scene
        
        notificationView.alpha = 0.0
        notificationView.layer.cornerRadius = 5.0
        
        reloadInstructions()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadInstructions), name: Notification.Name("codes_changed"), object: nil)
    }
    
    @objc private func reloadInstructions(){
        //get saved codes, if there aren't any, cry
        instructionLists.removeValue(forKey: "gym_s40")
        instructionLists.removeValue(forKey: "mailbox")
        if let gymLockerItem = VaultItem.getVaultObject(key: CodeSelectionTableViewController.GYM_LOCKER_DEFAULTS_KEY), let code = gymLockerItem.parse(){
            let codeStrings = code.map { (num) -> String in
                return "\(num)"
            }
            instructionLists["gym_s40"] = Instruction.createS40InstructionList(numbers: codeStrings) //should come from record
        }
        
        if let mailboxItem = VaultItem.getVaultObject(key: CodeSelectionTableViewController.MAILBOX_DEFAULTS_KEY), let code = mailboxItem.parse(){
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
        if !instructionShown{
            self.showNotification(text: "Swipe left to go to the next step")
            instructionShown = true
        }
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
            hideNotification()
            let instruction = index == -1 ? current.getInstruction() : current.getInstruction(index: index)
            self.currentPlane?.addChildNode(instruction.node)
            //create text node
            self.currentPlane?.addChildNode(NodeCreationManager.createTextNode(text: instruction.text, height: current.height, fontSize: current.fontSize))
            
            DispatchQueue.main.async {
                self.pageControl.currentPage = current.index
            }
        }else{
            //No instruction list, display an error message
            showNotification(text: "No combination selected, click select codes")
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
    
    @IBAction func swipedLeft(_ sender: Any) {
        hideNotification()
        currentInstructionList?.increment()
        displayInstruction()
    }
    
    @IBAction func swipedRight(_ sender: Any) {
        currentInstructionList?.decrement()
        displayInstruction()
    }
    
    
    func showNotification(text:String){
        DispatchQueue.main.async {
            self.notificationLabel.text = text
            UIView.animate(withDuration: 0.4) {
                self.notificationView.alpha = 1.0
            }
        }
    }
    
    func hideNotification(){
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.4) {
                self.notificationView.alpha = 0.0
            }
        }
    }
}
