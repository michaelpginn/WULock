//
//  Instruction.swift
//  WULock
//
//  Created by Michael Ginn on 11/29/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit
import SceneKit

typealias InstructionList = [Instruction]

class Instruction: NSObject {
    var nodes:[SCNNode] = []
    var text:String
    
    init(nodes:[SCNNode], text:String){
        self.nodes = nodes
        self.text = text
    }
}
