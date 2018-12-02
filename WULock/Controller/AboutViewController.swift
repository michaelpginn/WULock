//
//  AboutViewController.swift
//  WULock
//
//  Created by Tani Kay on 12/2/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var passwordSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func disablePassword(_ sender: Any) {
       let slider = sender as? UISwitch
        UserDefaults.standard.set(slider?.isOn, forKey: "passwordEnabled")
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
