//
//  DriverArrivedView.swift
//  UberTest
//
//  Created by Kyle Haptonstall on 3/12/16.
//  Copyright © 2016 Kyle Haptonstall. All rights reserved.
//

import UIKit

class DriverArrivedView: UIViewController {
    
    
    @IBOutlet weak var driverArrived: UILabel!
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var modalView: UIView!
    
    override func viewDidLoad() {
        
        imageView.layer.cornerRadius = imageView.frame.height / 2
        imageView.clipsToBounds = true
        driverArrived.hidden = true
        setupView()
    }
    
    
    func setupView(){
        modalView.layer.shadowColor = UIColor.blackColor().CGColor
        modalView.layer.shadowOffset = CGSizeMake(1.0, 5.0);
        modalView.layer.shadowOpacity = 1
        modalView.layer.shadowRadius = 3
        modalView.clipsToBounds = false
        modalView.layer.cornerRadius = 4
        
    }
}
