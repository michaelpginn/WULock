//
//  IDViewController.swift
//  WULock
//
//  Created by Michael Ginn on 11/13/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit
import CoreData

class IDViewController: UIViewController {
    @IBOutlet weak var cardFrontImageButton:UIButton!
    @IBOutlet weak var cardBackImageButton:UIButton!
    
    var typeForSegue:String?
    var frontBackSet = (false, false)
    
    let defaults = UserDefaults.standard
    let CARD_CORNER_RADIUS: CGFloat = 10.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //cardFrontImageButton.layer.cornerRadius = CARD_CORNER_RADIUS
        cardFrontImageButton.layer.cornerRadius = CARD_CORNER_RADIUS
        cardFrontImageButton.clipsToBounds = true
        cardBackImageButton.layer.cornerRadius = CARD_CORNER_RADIUS
        cardBackImageButton.clipsToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(getImagesForCards), name: Notification.Name("coredata-updated"), object: nil)
        
        getImagesForCards()
    }
    
    @objc func getImagesForCards(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CardImage")
        do{
            let results = try managedObjContext.fetch(fetchRequest)
            for record in results as! [CardImage]{
                setFromRecord(record: record)
            }
        }catch let e{
            print(e.localizedDescription)
        }
    }
    
    func setFromRecord(record:CardImage){
        guard let data = record.imagedata as Data?, let image = UIImage(data: data) else{return}
        if record.type == CardImage.FRONT_IMAGE_TYPE{
            frontBackSet.0 = true
            cardFrontImageButton.setBackgroundImage(image, for: .normal)
            cardFrontImageButton.setTitle(nil, for: .normal)
        }else if record.type == CardImage.BACK_IMAGE_TYPE{
            frontBackSet.1 = true
            cardBackImageButton.setBackgroundImage(image, for: .normal)
            cardBackImageButton.setTitle(nil, for: .normal)
        }
    }
    
    @IBAction func frontTapped(sender:UIButton!){
        if frontBackSet.0{
            
        }else{
            typeForSegue = CardImage.FRONT_IMAGE_TYPE
            self.performSegue(withIdentifier: "showCamera", sender: self)
        }
    }

    @IBAction func backTapped(sender:UIButton!){
        if frontBackSet.1{
            
        }else{
            typeForSegue = CardImage.BACK_IMAGE_TYPE
            self.performSegue(withIdentifier: "showCamera", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCamera", let destVC = segue.destination as? IDScannerViewController{
            destVC.typeOfCard = self.typeForSegue
        }
    }
}
