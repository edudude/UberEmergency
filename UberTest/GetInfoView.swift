//
//  GetInfoView.swift
//  UberTest
//
//  Created by Kyle Haptonstall on 3/12/16.
//  Copyright © 2016 Kyle Haptonstall. All rights reserved.
//

import UIKit
import MessageUI

class GetInfoView: UIViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate{
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var allergiesTextField: UITextField!
    @IBOutlet weak var medicationsTextField: UITextField!
    
    var textFieldIndex = 0
    
    let speechHandler = SpeechHandler()
    
    @IBOutlet weak var buttonBackground: UIButton!
    
    @IBOutlet weak var micButton: UIButton!
    @IBAction func onMicButton(sender: UIButton) {
        
        sender.selected = !sender.selected
        
        if sender.selected{
            speechHandler.startListening()
            switch textFieldIndex{
            case 0:
                nameTextField.becomeFirstResponder()
            case 1:
                birthdayTextField.becomeFirstResponder()
            case 2:
                allergiesTextField.becomeFirstResponder()
            case 3:
                medicationsTextField.becomeFirstResponder()
            default:
                break
            }
            
            buttonBackground.hidden = false
            
            
            buttonBackground.transform = CGAffineTransformMakeScale(1.1, 1.1);
            UIView.animateWithDuration(0.5, delay: 0.0, options: [.CurveEaseOut, .Autoreverse, .Repeat], animations: {
                self.buttonBackground.transform = CGAffineTransformIdentity
                }, completion: nil)
        
        
        }
        else{
            speechHandler.stopListening()
            buttonBackground.layer.removeAllAnimations()
            buttonBackground.hidden = true
            UIView.animateWithDuration(0.5, delay: 0.0, options: [.CurveEaseOut], animations: {
                self.buttonBackground.transform = CGAffineTransformIdentity
                }, completion: nil)
        }
    }
    
    var frameOrigin:CGFloat!
    
    
    override func viewDidLoad() {
        
        frameOrigin = self.view.frame.origin.y
        
        speechHandler.startSpeechHandler()
        
        buttonBackground.hidden = true
        let origImage = UIImage(named: "ButtonBG");
        let tintedImage = origImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        buttonBackground.setImage(tintedImage, forState: .Normal)
        buttonBackground.tintColor = UIColor(red: 0.7569, green: 0.7569, blue: 0.7569, alpha: 1.0) 

        
        
        
        nameTextField.delegate = self
        birthdayTextField.delegate = self
        allergiesTextField.delegate = self
        medicationsTextField.delegate = self

        /* let dummyView = UIView(frame: CGRectMake(0, 0, 0, 0))

        nameTextField.inputView = dummyView
        birthdayTextField.inputView = dummyView
        allergiesTextField.inputView = dummyView
        birthdayTextField.inputView = dummyView
        */
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("heardSpeech"), name: "NotificationIdentifier", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)

    }
    
    func heardSpeech(){
        let text = speechHandler.heardText.lowercaseString
        print("Got speech", text)
        if text.containsString("next"){
            self.switchTextField()
        }
        else if text.containsString("send"){
            
            let name = self.nameTextField.text == "" ? "N/A" : self.nameTextField.text
            let birthday = self.birthdayTextField.text == "" ? "N/A" : self.birthdayTextField.text
            let allergies = self.allergiesTextField.text == "" ? "None" : self.allergiesTextField.text
            let meds = self.medicationsTextField.text == "" ? "None" : self.medicationsTextField.text

            let mailComposeViewController = configuredMailComposeViewController(name!, birthday: birthday!, allergies: allergies!, meds: meds!)
            
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        }
        else if text != ""{
            switch textFieldIndex{
            case 0:
                self.nameTextField.text = "    \(text)"
            case 1:
                self.birthdayTextField.text = "    \(text)"
            case 2:
                self.allergiesTextField.text = "    \(text)"
            case 3:
                self.medicationsTextField.text = "    \(text)"
            default:
                break
            }
            
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        nameTextField.resignFirstResponder()
        birthdayTextField.resignFirstResponder()
        allergiesTextField.resignFirstResponder()
        medicationsTextField.resignFirstResponder()

    }
    
    
    func keyboardWillShow(sender: NSNotification) {
        
        if self.view.frame.origin.y >= 0 {
            self.view.frame.origin.y -= 100
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        if self.view.frame.origin.y < 0{
            self.view.frame.origin.y += 100
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
    
    func configuredMailComposeViewController(name: String, birthday: String, allergies: String, meds: String) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["khaptonstall93@gmail.com"])
        mailComposerVC.setSubject("Incoming Patient Info")
        mailComposerVC.setMessageBody(
            "Patient Name: \(name)\n Birthday: \(birthday)\n Allergies: \(allergies)\n Medications: \(meds)", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
}
