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

    private enum Button:String{
        case num1 = "1"
        case num2 = "2"
        case num3 = "3"
        case num4 = "4"
        case num5 = "5"
        case num6 = "6"
        case num7 = "7"
        case num8 = "8"
        case num9 = "9"
        case num0 = "0"
        case cButton = "C"
        case lockButton = "key"
        
        func s40index()->(Int, Int){
            switch (self){
            case .num1:
                return (0, 5)
            case .num2:
                return (1, 5)
            case .num3:
                return (0, 4)
            case .num4:
                return (1, 4)
            case .num5:
                return (0, 3)
            case .num6:
                return (1, 3)
            case .num7:
                return (0, 2)
            case .num8:
                return (1, 2)
            case .num9:
                return (0, 1)
            case .num0:
                return (1, 1)
            case .cButton:
                return (0, 0)
            case .lockButton:
                return (1, 0)
            }
        }
        
        func s40Pos()->(Float, Float){
            var xs:[Float] = [-0.02, 0.018]
            var ys:[Float] = [-0.014, -0.004, 0.0057, 0.0154, 0.0251, 0.0348]
            let x = xs[self.s40index().0]
            let y = ys[self.s40index().1]
            return (x,y)
        }
    }
    
    class func createS40InstructionList(numbers:[String])->InstructionList{
        
        
        var instructions:InstructionList = []
        
        let inst_c = Instruction(node: createArrowNode(xyPos: Button.cButton.s40Pos(), facingRight: true), text: "Press the c button")
        instructions.append(inst_c)
        
        //next, get the numbered steps (should be four numbers)
        for number in numbers{
            if let button = Button(rawValue: number){
                let facingRight = button.s40index().0 == 0
                let inst_n = Instruction(node: createArrowNode(xyPos: button.s40Pos(), facingRight: facingRight), text: "Press " + number)
                instructions.append(inst_n)
            }
        }
        
        let inst_l = Instruction(node: createArrowNode(xyPos: Button.lockButton.s40Pos(), facingRight: false), text: "Press the lock button")
        instructions.append(inst_l)
        
        return instructions
    }
    
    private class func createArrowNode(xyPos: (Float, Float), facingRight:Bool)->SCNNode{
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
        return arrow
    }
}
