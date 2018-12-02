//
//  NodeCreationManager.swift
//  WULock
//
//  Created by Michael Ginn on 11/30/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class NodeCreationManager: NSObject {
    
    class func createPlaneNode(size:CGSize)->SCNNode{
        let plane = SCNPlane(width: size.width, height: size.height)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.clear
        plane.materials = [material]
        let planeNode = SCNNode(geometry: plane)
        planeNode.opacity = 1.0
        planeNode.eulerAngles.x = -.pi / 2
        return planeNode
    }
    
    class func createMailboxPlaneNode(hit:ARHitTestResult)->SCNNode{
        let size = CGSize(width: 0.048*4, height: 0.0889*4)
        let plane = SCNPlane(width: size.width, height: size.height)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.gray
        plane.materials = [material]
        let planeNode = SCNNode(geometry: plane)
        planeNode.opacity = 1.0
        
        planeNode.transform = SCNMatrix4(hit.anchor!.transform)

        //Align the plane
        planeNode.eulerAngles = SCNVector3Make(planeNode.eulerAngles.x + (3 * Float.pi / 2), planeNode.eulerAngles.y + Float.pi, planeNode.eulerAngles.z)
        
        let position = SCNVector3Make(hit.worldTransform.columns.3.x + planeNode.geometry!.boundingBox.min.z, hit.worldTransform.columns.3.y, hit.worldTransform.columns.3.z)
        planeNode.position = position
        
        return planeNode
    }
    
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
    
    public class func createTextNode(text:String, height:Float = 0.07, fontSize:CGFloat = 10.0)->SCNNode{
        let scnText = SCNText(string: text, extrusionDepth: 1)
        scnText.flatness = 0.1
        scnText.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        
        let textNode = SCNNode(geometry: scnText)
        let SCALE_FACTOR: Float = 0.0008
        textNode.scale = SCNVector3(SCALE_FACTOR, SCALE_FACTOR, SCALE_FACTOR)
        textNode.position.x = -textNode.boundingBox.max.x * 0.5 * SCALE_FACTOR
        textNode.position.z = 0.01
        textNode.position.y = height
        
        return textNode
    }
    
    enum ClockDirection{
        case clockwise
        case counterclockwise
    }
    
    public class func createCurvedArrowNode(xyPos: (Float, Float), direction: ClockDirection)->SCNNode{
        let arrowPlane = SCNPlane(width: 0.036, height: 0.012)
        let arrowMaterial = SCNMaterial()
        
        if direction == .clockwise{
            arrowMaterial.diffuse.contents = UIImage(named: "cwArrow")
        }else{
            arrowMaterial.diffuse.contents = UIImage(named: "ccwArrow")
        }
        arrowPlane.materials = [arrowMaterial]
        let arrow = SCNNode(geometry: arrowPlane)
        arrow.position.z = 0.01
        arrow.position.x = xyPos.0
        arrow.position.y = xyPos.1
        return arrow
    }
    
}
