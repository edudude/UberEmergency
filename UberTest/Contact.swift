//
//  Contact.swift
//  UberTest
//
//  Created by Kyle Haptonstall on 3/12/16.
//  Copyright © 2016 Kyle Haptonstall. All rights reserved.
//

import UIKit
import MessageUI


extension MainView: MFMessageComposeViewControllerDelegate{
    func sendMessage(hospitalName:String){
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = "Automatic message sent from Uber Emergency\n On my way to \(hospitalName)"
            controller.recipients = ["\(self.contactNumber!)"]
            controller.messageComposeDelegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        }
        
    }
    
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}

