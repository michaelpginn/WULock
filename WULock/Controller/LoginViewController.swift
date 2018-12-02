//
//  LoginViewController.swift
//  WULock
//
//  Created by Michael Ginn on 12/2/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        authenticateUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    @IBAction func authenticate(_ sender: Any) {
        authenticateUser()

    }
    
    private func authenticateUser(){
        let context = LAContext()
        var error:NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error){
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Authenticate to use WULock") { (success, error) in
                if success{
                    DispatchQueue.main.async {
                        self.dismiss(animated: false, completion: nil)
                    }
                    
                }else{
                    
                }
            }
        }else{
            self.dismiss(animated: false, completion: nil)
        }
    }
    
}
