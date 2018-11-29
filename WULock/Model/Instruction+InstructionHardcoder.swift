//
//  ARToolsViewController+InstructionHardcoder.swift
//  WULock
//
//  Created by Michael Ginn on 11/29/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import Foundation
import SceneKit

/**
 Adds the hardcoded instruction sets for the three ttypes included
 */
extension Instruction{
    class func createS40InstructionList(numbers:[Int])->InstructionList{
        var instructions:InstructionList = []
        
        var inst_c_nodes:[SCNNode] = []
        let rightArrowPlane = SCNPlane(width: 0.1, height: 0.1)
        let arrowMaterial = SCNMaterial()
        arrowMaterial.diffuse.contents = UIImage(named: "rightarrow")
        
        
        rightArrowPlane.materials = [arrowMaterial]
        let arrow = SCNNode(geometry: rightArrowPlane)
        arrow.position.z = 0.01
        inst_c_nodes.append(arrow)
        let inst_c = Instruction(nodes: inst_c_nodes, text: "Press the c button")
        instructions.append(inst_c)
        
        
        
        return instructions
    }
}
