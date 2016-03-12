//
//  GetInfoView.swift
//  UberTest
//
//  Created by Kyle Haptonstall on 3/12/16.
//  Copyright © 2016 Kyle Haptonstall. All rights reserved.
//

import UIKit

class GetInfoView: UIViewController, UITextFieldDelegate{
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var allergiesTextField: UITextField!
    @IBOutlet weak var medicationsTextField: UITextField!
    
    var textFieldIndex = 0
    
    let speechHandler = SpeechHandler()
    
    @IBAction func onMicButton(sender: UIButton) {
        
        
    }
    
    
    override func viewDidLoad() {
        speechHandler.startSpeechHandler()
        
        nameTextField.delegate = self
        birthdayTextField.delegate = self
        allergiesTextField.delegate = self
        medicationsTextField.delegate = self
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("heardSpeech"), name: "NotificationIdentifier", object: nil)

        
        speechHandler.startListening()
        
        print(speechHandler.words)
        nameTextField.becomeFirstResponder()
    }
    
    func heardSpeech(){
        var text = speechHandler.heardText.lowercaseString
        print("Got speech", text)
        if text == "next"{
            self.switchTextField()
        }
        else if text == "send"{
            print("Sending")
        }
        else if text != ""{
            switch textFieldIndex{
            case 0:
                self.nameTextField.text = text
            case 1:
                self.birthdayTextField.text = text
            case 2:
                self.allergiesTextField.text = text
            case 3:
                self.medicationsTextField.text = text
            default:
                break
            }
            
        }
    }
    
    func switchTextField(){
        textFieldIndex += 1
        switch textFieldIndex{
        case 1:
            self.birthdayTextField.becomeFirstResponder()
        case 2:
            self.allergiesTextField.becomeFirstResponder()
        case 3:
            self.medicationsTextField.becomeFirstResponder()
        default:
            self.nameTextField.resignFirstResponder()
            self.birthdayTextField.resignFirstResponder()
            self.allergiesTextField.resignFirstResponder()
            self.medicationsTextField.resignFirstResponder()
            self.speechHandler.stopListening()
        }
    }
    
    
    
    
}
