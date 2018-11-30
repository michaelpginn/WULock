//
//  NodeCreationManager.swift
//  WULock
//
//  Created by Michael Ginn on 11/30/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit
import SceneKit

class NodeCreationManager: NSObject {
    class func createArrowNode(xyPos: (Float, Float), facingRight:Bool)->SCNNode{
        let rightArrowPlane = SCNPlane(width: 0.02, height: 0.02)
        let arrowMaterial = SCNMaterial()
        
        if facingRight{
            arrowMaterial.diffuse.contents = UIImage(named: "rightArrow")
        }else{
            arrowMaterial.diffuse.contents = UIImage(named: "leftArrow")
        }
        rightArrowPlane.materials = [arrowMaterial]
        let arrow = SCNNode(geometry: rightArrowPlane)
        arrow.position.z = 0.01
        arrow.position.x = xyPos.0
        arrow.position.y = xyPos.1
        arrow.runAction(bounceAction(directionLeft: facingRight))
        return arrow
    }
    
    
    private class func bounceAction(directionLeft:Bool)->SCNAction{
        let mult:CGFloat = directionLeft ? -1 : 1
        return SCNAction.repeatForever(
            SCNAction.sequence([
            SCNAction.moveBy(x: mult * 0.01, y: 0, z: 0, duration: 0.7),
            SCNAction.wait(duration: 0.1),
            SCNAction.moveBy(x: mult * -1 * 0.01, y: 0, z: 0, duration: 0.7),
            SCNAction.wait(duration: 0.1)
            ]))
        
    }
    
    public class func createTextNode(text:String)->SCNNode{
        let scnText = SCNText(string: text, extrusionDepth: 1)
        scnText.flatness = 0.1
        scnText.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        
        let textNode = SCNNode(geometry: scnText)
        //textNode.eulerAngles.x = -.pi / 2
        let SCALE_FACTOR: Float = 0.0008
        textNode.scale = SCNVector3(SCALE_FACTOR, SCALE_FACTOR, SCALE_FACTOR)
        textNode.position.x = -textNode.boundingBox.max.x * 0.5 * SCALE_FACTOR
        textNode.position.z = 0.01
        textNode.position.y = 0.07
        
        return textNode
    }
}
