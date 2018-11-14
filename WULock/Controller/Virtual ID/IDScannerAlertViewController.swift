//
//  IDScannerAlertViewController.swift
//  WULock
//
//  Created by Michael Ginn on 11/12/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit

protocol IDScannerAlertViewControllerDelegate{
    func didAccept(image:UIImage)
}

class IDScannerAlertViewController: UIViewController {
    @IBOutlet weak var imageView:UIImageView!
    
    var delegate: IDScannerAlertViewControllerDelegate?
    var image:UIImage?
    
    
    convenience init(image:UIImage){
        self.init(nibName: "IDScanDialog", bundle: nil)
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
        self.image = image
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.imageView.image = image
    }
    

    @IBAction func cancel(sender:UIButton!){
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func accept(sender:UIButton!){
        self.dismiss(animated: true) {
            if let delegate = self.delegate, let image = self.image{
                delegate.didAccept(image: image)
            }
        }
        
        
    }
}
