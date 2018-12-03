//
//  Plane.swift
//  WULock
//
//  Created by Michael Ginn on 12/2/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit
import ARKit

class Plane: SCNNode {
    //Adapted from https://collectiveidea.com/blog/archives/2018/05/08/part-2-arkit-wall-and-plane-detection-for-ios-11.3
    let plane:SCNPlane
    
    init(anchor: ARPlaneAnchor){
        plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        super.init()
        plane.cornerRadius = 0.05
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        planeNode.eulerAngles.x = -.pi / 2
        
        planeNode.opacity = 0.0
        
        addChildNode(planeNode)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateWith(anchor: ARPlaneAnchor){
        //when plane is changed
        plane.width = CGFloat(anchor.extent.x)
        plane.height = CGFloat(anchor.extent.z)
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
    }
}
