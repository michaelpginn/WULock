//
//  IDDetailedViewController.swift
//  WULock
//
//  Created by Tani Kay on 11/29/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit

class IDDetailedViewController: UIViewController {

    @IBOutlet weak var cardImg: UIImageView!
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        closeButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        retakeButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        
        
        
        // Do any additional setup after loading the view.
    }
    
    //hello

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
