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
    
    var planes:[UUID:Plane] = [:]
    
    enum SessionType{
        case automatic
        case manual
    }
    
    var currentSessionType:SessionType{
        get{
            if segmentControl.selectedSegmentIndex == 0{
                return .automatic
            }else{
                return .manual
            }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        
        createSession(type: currentSessionType)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    private func createSession(type:SessionType){
        let queue = DispatchQueue(label: "background")
        queue.async {
            if type == .automatic{
                let configuration = ARImageTrackingConfiguration()
                if let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) {
                    configuration.trackingImages = referenceImages
                }

                self.sceneView.session.run(configuration)
                self.hideNotification()
            }else if type == .manual{
                let configuration = ARWorldTrackingConfiguration()
                self.sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
                configuration.planeDetection = .vertical
                configuration.isLightEstimationEnabled = true
                
                self.sceneView.session.run(configuration)
                self.showNotification(text: "Tap the center of the lock")
                self.planes = [:]
                print(self.sceneView.session.configuration)
            }
        }
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
    
    //MARK: User interaction
    @IBAction func swipedLeft(_ sender: Any) {
        hideNotification()
        currentInstructionList?.increment()
        displayInstruction()
    }
    
    @IBAction func swipedRight(_ sender: Any) {
        currentInstructionList?.decrement()
        displayInstruction()
    }
    
    @IBAction func segmentChanged(_ sender:UISegmentedControl){
        if sender.selectedSegmentIndex == 0{
            createSession(type: .automatic)
        }else{
            createSession(type: .manual)
        }
    }
    
    //MARK: ARSCNView Delegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        print("Seeing \((anchor as? ARImageAnchor)?.referenceImage.name ?? "")")
        if currentSessionType == .automatic{
            if let imageAnchor = anchor as? ARImageAnchor{
                if !instructionShown{
                    self.showNotification(text: "Swipe left to go to the next step")
                    instructionShown = true
                }
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
            }}
        else{
            if let planeAnchor = anchor as? ARPlaneAnchor{
                print("Found plane")
                let plane = Plane(anchor: planeAnchor)
                self.planes[anchor.identifier] = plane
                node.addChildNode(plane)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        //From https://collectiveidea.com/blog/archives/2018/05/08/part-2-arkit-wall-and-plane-detection-for-ios-11.3
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        if let plane = planes[planeAnchor.identifier] {
            plane.updateWith(anchor: planeAnchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        self.currentInstructionListKey = ""
        self.pageControl.numberOfPages = 0
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
    
    //MARK: Notifications
    
    
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
