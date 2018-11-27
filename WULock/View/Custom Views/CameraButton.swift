//
//  CameraButton.swift
//  WULock
//
//  Created by Michael Ginn on 11/20/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit

class CameraButton: UIButton {
    private var whitePath:UIBezierPath?
    private var outerBlackPath: UIBezierPath?
    private var innerBlackPath: UIBezierPath?

    override func draw(_ rect: CGRect) {
        //draw circle
        let radius = min(rect.width / 2, rect.height/2) - 8.0
        let center = CGPoint(x: rect.width / 2.0, y: rect.height / 2.0)
        let lineWidth:CGFloat = 6.5
        whitePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        
        UIColor.white.setStroke()
        whitePath!.lineWidth = lineWidth
        whitePath!.stroke()
        
        outerBlackPath = UIBezierPath(arcCenter: center, radius: radius + lineWidth / 2.0, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        UIColor.black.setStroke()
        outerBlackPath!.lineWidth = 0.2
        outerBlackPath!.stroke()
        
        innerBlackPath = UIBezierPath(arcCenter: center, radius: radius - lineWidth / 2.0, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        UIColor.black.setStroke()
        innerBlackPath!.lineWidth = 0.2
        innerBlackPath!.stroke()
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let animation = CABasicAnimation(keyPath: "path")
//        
//    }

}
