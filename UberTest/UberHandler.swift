//
//  UberHandler.swift
//  UberTest
//
//  Created by Kyle Haptonstall on 3/11/16.
//  Copyright © 2016 Kyle Haptonstall. All rights reserved.
//

import UIKit
import p2_OAuth2

class UberHandler {

    
    func authorizeUser() -> String?{
        var accessToken:String?
        do{
            let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
            let url = try appDel.oauth.authorizeURL()
            UIApplication.sharedApplication().openURL(url)
            appDel.oauth.onAuthorize = { parameters in
                accessToken = parameters["access_token"] as! String
               // print(parameters["access_token"] )
                
                
            }
            appDel.oauth.onFailure = { error in        // `error` is nil on cancel
                if nil != error {
                    print("Authorization went wrong: \(error!)")
                }
            }
            
        }
        catch{
            
        }
        return accessToken

    }
    
    
    func makeRequest(productID:String, startLat: Double, startLng: Double, endLat: Double, endLng: Double, completion: (() -> Void)){
        
        let params:[String: AnyObject] = [
            "product_id" : "\(productID)",
            "start_latitude" : startLat,
            "start_longitude" : startLng,
            "end_latitude" : endLat,
            "end_longitude" : endLng]
        /*
        let params:[String: AnyObject] = [
            "product_id" : "6e731b60-2994-4f68-b586-74c077573bbd",
            "start_latitude" : 21.3088621,
            "start_longitude" : -157.8086632,
            "end_latitude" : 21.7088621,
            "end_longitude" : -157.8086632]
        */
        
        let urlPath = "https://sandbox-api.uber.com/v1/requests"
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: configuration)
        
        guard let endpoint = NSURL(string: urlPath) else { print("Error creating endpoint");return }
        
        let request = appDelegate.oauth.request(forURL: NSURL(string:urlPath)!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField:"Content-Type")
        
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted)
        
        request.HTTPMethod = "POST"
        
        print("Prepare to make request -> \(request)")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            if error != nil{
                print("Error -> \(error)")
                return
            }
            
            do {
                let result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                let json = JSON(data: data!)
                print("JSON", json)

                for (key,subJson):(String, JSON) in json{
                    completion()
                    break
                }

                
            } catch {
                print("Error -> \(error)")
            }
        }
        
        task.resume()
    }
    
    func getProducts(atLat lat: Double, atLon lon: Double, completion: ((
        String) -> Void)){
        var urlPath = "https://api.uber.com/v1/products?latitude=\(lat)&longitude=\(lon)"

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        var session = NSURLSession(configuration: configuration)
        
        guard let endpoint = NSURL(string: urlPath) else { print("Error creating endpoint");return }
        
        let request = appDelegate.oauth.request(forURL: NSURL(string:urlPath)!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField:"Content-Type")
        
        
        request.HTTPMethod = "GET"
        
        print("Prepare to make request -> \(request)")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            if error != nil{
                print("Error -> \(error)")
                return
            }
            
            do {
                let result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)

                let json = JSON(data: data!)
                let results = json["products"]

                var firstProductID:String = ""
                
                for (index,subJson):(String, JSON) in results {
                    firstProductID = subJson["product_id"].stringValue
                    break
                   // print(subJson["product_id"])
                   // print(subJson["display_name"])
                }
                
                completion(firstProductID)
                
            } catch {
                print("Error -> \(error)")
            }
        }
        
        task.resume()
    }
    
    
    func createRandomDriver() -> [String: AnyObject]{
        let names = [
            "Deloras",
            "Dannielle",
            "Sam",
            "Alan",
            "Joy",
            "Mabel",
            "Lloyd",
            "Avery",
            "Lucrecia",
            "Allen"]
        
        let plates = [
            "931 2471",
            "800 3899",
            "XWM 4874",
            "XZX 4099",
            "420 5332",
            "484 8757",
            "DBW 4356",
            "877 6382",
            "JYM 1926",
            "275 4693"]
        
        let eta = Int(arc4random_uniform(8) + 3)
        
        let index = Int(arc4random_uniform(10) + 1)
        let driverName = names[index]
        let driverPlate = plates[index]
        
        return ["Name": driverName, "Plate": driverPlate, "ETA": eta]
    }
}