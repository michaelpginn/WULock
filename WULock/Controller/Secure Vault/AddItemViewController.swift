//
//  AddItemViewController.swift
//  WULock
//
//  Created by Michael Ginn on 11/26/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit

class AddItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ItemTypePickerControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    private var currentSelectedType:ItemType = .other
    private var defaultFields:[ItemField] = []
    private var userFields:[ItemField] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //modified from https://stackoverflow.com/questions/37370801/how-to-add-a-container-view-programmatically
        let pickerController = ItemTypePickerController()
        pickerController.delegate = self
        addChild(pickerController)
        pickerController.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(pickerController.view)
        NSLayoutConstraint.activate([
            pickerController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pickerController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            pickerController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            pickerController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    // MARK: ItemTypePickerControllerDelegate method
    func optionSelected(type:ItemType) {
        //reload the table view with the correct fields
        currentSelectedType = type
        defaultFields = []
        for field in type.getDefaultFields(){
            defaultFields.append(ItemField(fieldDescription: field, fieldValue: ""))
        }
        tableView.reloadSections(IndexSet(integer: 0), with: .fade)
    }
    
    // MARK: Interface methods
    @IBAction func save(_ sender: Any) {
        //make sure to shift focus from all fields
        self.view.endEditing(true)
        //Create a new VaultItem object by getting data from each field
        var fields:[ItemField] = []
        for field in defaultFields{
            fields.append(field)
        }
        for field in userFields{
            if field.fieldDescription != ""{
                fields.append(field)
            }
        }
        
        
        let newItem = VaultItem(type: currentSelectedType, fields: fields)
        
        if currentSelectedType == .mailbox || currentSelectedType == .gymLocker{
            guard newItem.canParse() else{
                let alert = UIAlertController(title: "Error", message: "The combination value could not be parsed, use the suggested format.", preferredStyle: .alert)
                let accept = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alert.addAction(accept)
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
            let context = appDelegate.managedObjectContext
            _ = newItem.getManagedObject(context: context)
            do{
                try context.save()
                
                let nc = NotificationCenter.default
                nc.post(Notification(name: Notification.Name("vault_changed")))
                
                self.dismiss(animated: true, completion: nil)
            }catch let e {
                print(e.localizedDescription)
            }
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //Figure out what cell we're in
        guard let cell = textField.superview?.superview as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell) else{return}
        
        let newText = textField.text ?? ""
        
        if indexPath.section == 0{
            //Text was entered in a default field
            defaultFields[indexPath.row].fieldValue = newText
        }else if indexPath.section == 1{
            //Text was entered in a custom field, figure out if it was the first or second textbox
            if textField.tag == 1{
                userFields[indexPath.row].fieldDescription = newText
            }else if textField.tag == 2{
                userFields[indexPath.row].fieldValue = newText
            }
        }
    }
    
    //MARK: TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 //one for default fields, one for user entered ones
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return defaultFields.count
        }else if section == 1{
            return userFields.count + 1
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier:String
        
        if indexPath.section == 0{
            identifier = "setFieldCell"
        }else if indexPath.section == 1 && indexPath.row != userFields.count{
            identifier = "customFieldCell"
        }else{
            identifier = "addFieldCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
            if let button = cell.viewWithTag(1) as? UIButton{
                button.addTarget(self, action: #selector(addCell), for: .touchUpInside)
            }
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? FieldTableViewCell else{return UITableViewCell()}
        
        
        
        if indexPath.section == 0{
            let field = defaultFields[indexPath.row]
            cell.setDescription(field.fieldDescription)
            
            //Set placeholders for values that need parsing
            if field.fieldDescription == "Combination"{
                if currentSelectedType == .gymLocker{
                    cell.setPlaceholder("####")
                }else if currentSelectedType == .mailbox{
                    cell.setPlaceholder("##-##-##")
                }
                
            }
        }
        
        cell.valueTextField.delegate = self
        cell.descTextField?.delegate = self
        
        return cell
    }
    
    @objc func addCell(){
        userFields.append(ItemField(fieldDescription: "", fieldValue: ""))
        tableView.reloadSections(IndexSet(integer: 1), with: .fade)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1 && indexPath.row != userFields.count
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        userFields.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    // MARK: ScrollView Management
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    @objc func adjustForKeyboard(notification:Notification){
        //Adapted from https://www.hackingwithswift.com/example-code/uikit/how-to-adjust-a-uiscrollview-to-fit-the-keyboard
        guard let userInfo = notification.userInfo,
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else{return}
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification{
            tableView.contentInset = UIEdgeInsets.zero
        }else{
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
    }
}
