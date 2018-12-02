//
//  Instruction.swift
//  WULock
//
//  Created by Michael Ginn on 11/29/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit
import SceneKit

/**
 Wrapper for array of Instruction objects that holds the current index so we don't have to keep track
 */
class InstructionList{
    private var instructions:[Instruction]
    private(set) var index:Int = 0
    
    public var fontSize:CGFloat = 10.0
    public var height:Float = 0.07
    
    init(){
        self.instructions = []
    }
    
    init(instructions:[Instruction], fontSize:CGFloat = 10.0, height:Float = 0.7){
        self.instructions = instructions
        self.fontSize = fontSize
        self.height = height
    }
    
    func append(_ inst:Instruction){
        self.instructions.append(inst)
    }
    
    func getInstruction()->Instruction{
        return instructions[index]
    }
    
    func increment(){ if index < instructions.count - 1 {index += 1}}
    func decrement(){ if index > 0 {index -= 1}}
    
    func getInstruction(index:Int)->Instruction{
        return instructions[index]
    }
    
    var count:Int {get {return instructions.count}}
}

/**
 Holds a single instruction, consisting of a description string and a SCNNode to be displayed
 */
class Instruction: NSObject {
    var node:SCNNode
    var text:String
    
    init(node:SCNNode, text:String){
        self.node = node
        self.text = text
    }
}
