//
//  EContactView.swift
//  UberTest
//
//  Created by Kyle Haptonstall on 3/12/16.
//  Copyright © 2016 Kyle Haptonstall. All rights reserved.
//

import UIKit
import CoreData

class EContactView: UIViewController, UITextFieldDelegate{
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    let coreDataHandler = CoreDataHandler()
    
    
    override func viewDidLoad() {
        nameTextField.delegate = self
        phoneTextField.delegate = self
        
        
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "onSave"), animated: true)
        
        let contact = coreDataHandler.retrieveSingleObject(forEntityName: "Contact")
        if contact != nil{
            nameTextField.text = contact!.valueForKey("name") as! String
            phoneTextField.text = contact!.valueForKey("number") as! String
        }

    }
    
    func onSave(){
        let name = nameTextField.text!
        let number = phoneTextField.text!
        var success = coreDataHandler.updateObject(withEntityName: "Contact", andValues: ["name": name, "number": number])
        print("Success?", success)
    }
    
   
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        nameTextField.resignFirstResponder()
        phoneTextField.resignFirstResponder()
    }
}
