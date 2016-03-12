
import UIKit
import p2_OAuth2

class MainView: UIViewController {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var access_token:String?
    
    @IBAction func onTestAPICall(sender: AnyObject) {
        makeRequest()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Loaded")
        do{
            let url = try appDelegate.oauth.authorizeURL()
            UIApplication.sharedApplication().openURL(url)
            appDelegate.oauth.onAuthorize = { parameters in
                //  print("Did authorize with parameters: \(parameters)")
                self.access_token = parameters["access_token"] as! String
                print(parameters["access_token"] )
                
                
            }
            appDelegate.oauth.onFailure = { error in        // `error` is nil on cancel
                if nil != error {
                    print("Authorization went wrong: \(error!)")
                }
            }
            
        }
        catch{
            
        }
        
    }
    
    
    func makeRequest(){
        let params:[String: AnyObject] = [
            "product_id" : "6e731b60-2994-4f68-b586-74c077573bbd",
            "start_latitude" : 21.3088621,
            "start_longitude" : -157.8086632,
            "end_latitude" : 21.7088621,
            "end_longitude" : -157.8086632]
        
        
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
                
                print("Result -> \(result)")
                
            } catch {
                print("Error -> \(error)")
            }
        }
        
        task.resume()
    }
    
}
