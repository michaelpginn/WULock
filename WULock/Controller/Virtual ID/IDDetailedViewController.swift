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
    var imgCard: UIImage?
//    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardImg.image = imgCard
        cardImg.transform = CGAffineTransform(rotationAngle: (90.0 * .pi) / 180.0)

        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cameraBtn(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        
        let nc = NotificationCenter.default
        nc.post(Notification(name: Notification.Name(rawValue: "show-camera")))
        
//        self.dismiss(animated: true) {
//            super.performSegue(withIdentifier: "showCamera", sender: self.superclass)
//        }
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
