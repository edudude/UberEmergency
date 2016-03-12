
import UIKit
import p2_OAuth2
import CoreLocation
import GoogleMaps


class MainView: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate{
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var access_token:String?
    let locationManager = CLLocationManager()
    var loc:CLLocationCoordinate2D?
    var uberHandler = UberHandler()
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var secondaryLabel: UILabel!
    
    @IBAction func onOrderUber(sender: UIButton) {
        
        guard let currLoc = self.loc else { return }
        
        // Step 1: Get the product ID's of nearby Uber's
        uberHandler.getProducts(atLat: currLoc.latitude, atLon: currLoc.longitude) { (response) in
            if response != ""{
                let productID = response
                
                // Step 2: Get nearest hospitals
                self.getNearestHospital() { (result) in
                    if let hospitalDic = result as? [String:AnyObject] {
                        let name:String = hospitalDic["Name"] as! String
                        let destinationLat:Double = hospitalDic["Lat"] as! Double
                        let destinationLon:Double = hospitalDic["Lon"] as!  Double

                        // Step 3: Order Uber
                        self.uberHandler.makeRequest(productID, startLat: currLoc.latitude, startLng: currLoc.longitude, endLat: destinationLat, endLng: destinationLon) { _ in
                            
                                let driver: [String: AnyObject] = self.uberHandler.createRandomDriver()
                                print("DRIVER", driver)
                                let name = driver["Name"] as! String
                                let plate = driver["Plate"] as! String
                                let eta = driver["ETA"] as! Int
                            
                                dispatch_async(dispatch_get_main_queue()){
                                    self.mainLabel.text = "\(name) is on their way!"
                                    self.secondaryLabel.text = "Plate Numer: \(plate)\n ETA: \(eta) mins"
                            }
                            
                        }
                    }
                    
                   
                }
                
            }
        }
    }
    
    
    func getNearestHospital(completion: (([String : AnyObject]) -> Void)){
        
        var key = "AIzaSyDp3lbh3B4McdPT-rgS8UYJb0w9UXN0Sj0"
        let lat = loc!.latitude
        let lon = loc!.longitude
        
        var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=\(key)&location=\(lat),\(lon)&radius=\(5000)&rankby=prominence&keyword=hospital&sensor=true"
        
        let url = NSURL(string: urlString)
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!){ data, response, error in
            if error != nil{
                print("Error -> \(error)")
                return
            }
            
            do {
                let result = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                let json = JSON(data: data!)
                let results = json["results"]
                
                var name = ""
                var lat = 0.0
                var lon = 0.0
                
                for (index,subJson):(String, JSON) in results {
                    
                    name = subJson["name"].stringValue
                    lat = subJson["geometry"]["location"]["lat"].doubleValue
                    lon = subJson["geometry"]["location"]["lng"].doubleValue
                    break
                }
                
                let hospitalData: [String: AnyObject] = [
                    "Name": name,
                    "Lat" : lat,
                    "Lon" : lon]
                
                completion(hospitalData)
                
            } catch {
                print("Error -> \(error)")
            }
        }
        
        task.resume()
    }
    
    
    
      
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        var accessToken = uberHandler.authorizeUser()
      //  uberHandler.getProducts()

        setupNavBar()
    }
    
    func setupNavBar(){
        let logoView = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        logoView.image = UIImage(named: "Logo")
        logoView.frame.origin.x = (self.view.frame.size.width - logoView.frame.size.width) / 2
        logoView.frame.origin.y = 25
        
        self.navigationController?.view.addSubview(logoView)
        
        self.navigationController?.view.bringSubviewToFront(logoView)
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.9451, green: 0.4196, blue: 0.4353, alpha: 1.0)

    }
    

    
    // MARK: - Location Manager
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArr = locations as NSArray
        let locationObj = locationArr.lastObject as! CLLocation
        let coordinate = locationObj.coordinate
        self.loc = coordinate
        
        
        self.mapView.camera = GMSCameraPosition(target: (coordinate), zoom: 12, bearing: 0, viewingAngle: 0)
        self.mapView.myLocationEnabled = true
        

    }
    
}
