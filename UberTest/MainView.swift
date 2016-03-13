
import UIKit
import p2_OAuth2
import CoreLocation
import GoogleMaps
import MessageUI

class MainView: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate{
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var access_token:String?
    let locationManager = CLLocationManager()
    var loc:CLLocationCoordinate2D?
    var uberHandler = UberHandler()
    let coreDataHandler = CoreDataHandler()
    var contactNumber:String?
    
    @IBOutlet weak var orderButtonCenter: NSLayoutConstraint!
    
    @IBOutlet weak var orderButton: UIButton!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var secondaryLabel: UILabel!
 
    var simulator:NSTimer?
    var uberOrdered = false
    
    @IBAction func onOrderUber(sender: UIButton) {
        locationManager.stopUpdatingLocation()
        
        if !uberOrdered{
            guard let currLoc = self.loc else { return }

            // Step 1: Get the product ID's of nearby Uber's
            uberHandler.getProducts(atLat: currLoc.latitude, atLon: currLoc.longitude) { (response) in
                if response != ""{
                    let productID = response

                    // Step 2: Get nearest hospitals
                    self.getNearestHospital() { (result) in
                        if let hospitalDic = result as? [String:AnyObject] {
                            let hospitalName:String = hospitalDic["Name"] as! String
                            let destinationLat:Double = hospitalDic["Lat"] as! Double
                            let destinationLon:Double = hospitalDic["Lon"] as!  Double
                            
                            let marker = GMSMarker()
                            marker.title = hospitalName
                            marker.position = CLLocationCoordinate2D(latitude: destinationLat, longitude: destinationLon)
                            marker.map = self.mapView
                            

                            // Step 3: Order Uber
                            self.uberHandler.makeRequest(productID, startLat: currLoc.latitude, startLng: currLoc.longitude, endLat: destinationLat, endLng: destinationLon) { _ in
                                
                                self.sendMessage(hospitalName)
                                
                                let driver: [String: AnyObject] = self.uberHandler.createRandomDriver()
                                let name = driver["Name"] as! String
                                let plate = driver["Plate"] as! String
                                let eta = driver["ETA"] as! Int
                                
                                dispatch_async(dispatch_get_main_queue()){
                                    self.mainLabel.text = "\(name) is on their way!"
                                    self.secondaryLabel.text = "\(hospitalName)\n Plate Numer: \(plate)\n ETA: \(eta) mins"
                                    
                                    self.uberLat = self.loc!.latitude + 0.1
                                    self.uberLon = self.loc!.longitude + 0.1
                                    
                                    NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "enlargeMapView", userInfo: nil, repeats: false)
                                    
                                    self.simulator = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "simulateUberOnMap", userInfo: nil, repeats: true)


                                }
                                self.uberOrdered = true
                                
                            }
                        }
                    }
                    
                }
            }

        }
        else{
            
            if orderButton.selected{
                // Button is at bottom. Bring it back up.
                self.resetMapView()
            }
            else{
                self.enlargeMapView()
            }
            
            
        }
        
    }
    
    
  
    
    override func viewDidAppear(animated: Bool) {
        let contact = coreDataHandler.retrieveSingleObject(forEntityName: "Contact")
        if contact != nil{
            contactNumber = contact!.valueForKey("number") as! String
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        var accessToken = uberHandler.authorizeUser()

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
        

        // Setup mic button
        let micButton = UIButton()
        micButton.setImage(UIImage(named: "Mic"), forState: .Normal)
        micButton.frame = CGRectMake(0, 0, 30, 30)
        micButton.addTarget(self, action: "onMicPress", forControlEvents: .TouchUpInside)
        
        let micBarButton = UIBarButtonItem()
        micBarButton.customView = micButton
        self.navigationItem.rightBarButtonItem = micBarButton
        
        // Setup contact button
        let contactButton = UIButton()
        contactButton.setImage(UIImage(named: "Contact"), forState: .Normal)
        contactButton.frame = CGRectMake(0, 0, 30, 30)
        contactButton.addTarget(self, action: "onContactPress", forControlEvents: .TouchUpInside)
        
        let contactBarButton = UIBarButtonItem()
        contactBarButton.customView = contactButton
        self.navigationItem.leftBarButtonItem = contactBarButton
        
    }
    
    func onMicPress(){
        self.performSegueWithIdentifier("ShowInfoPage", sender: self)
    }
    
    func onContactPress(){
        self.performSegueWithIdentifier("EContact", sender: self)
    }

    var cameraSet = false
    
    // MARK: - Location Manager
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArr = locations as NSArray
        let locationObj = locationArr.lastObject as! CLLocation
        let coordinate = locationObj.coordinate
        self.loc = coordinate
        
        if cameraSet == false{
            self.mapView.camera = GMSCameraPosition(target: (coordinate), zoom: 12, bearing: 0, viewingAngle: 0)
            cameraSet = true
        }
        self.mapView.myLocationEnabled = true
        

    }
    
    var uberLat = 0.0
    var uberLon = 0.0
    var driver = GMSMarker()
    
    func simulateUberOnMap(){
       
        if uberLat > loc!.latitude && uberLon > loc!.longitude{
            driver.map = nil
            driver.icon = UIImage(named: "Logo")
            
            driver.position = CLLocationCoordinate2D(latitude: uberLat, longitude: uberLon)
            driver.map = self.mapView
            
            let southWest = CLLocationCoordinate2DMake(loc!.latitude - 0.02,loc!.longitude - 0.02)
            let northEast = CLLocationCoordinate2DMake(uberLat + 0.02,uberLon + 0.02)
            let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
            let camera = mapView.cameraForBounds(bounds, insets:UIEdgeInsetsZero)
            self.mapView.camera = camera!
            
            uberLat -= 0.001
            uberLon -= 0.001

        }
        else{
            self.simulator?.invalidate()
            displayDriverArrived()
        }
        
    }
    
    func enlargeMapView(){

        self.orderButton.selected = true
        self.orderButton.setImage(UIImage(named: "Up"), forState: .Selected)
        self.mainLabel.alpha = 0
        self.secondaryLabel.alpha = 0
        UIView.animateWithDuration(3.0, animations: {
           
            self.orderButtonCenter.constant += self.view.frame.height / 2
            self.view.layoutIfNeeded()

        })
    }
    
    func resetMapView(){
        self.orderButton.selected = false
        self.orderButton.setImage(UIImage(named: "Down"), forState: .Normal)
        
        UIView.animateWithDuration(1.5, animations: {
            self.mainLabel.alpha = 1
            self.secondaryLabel.alpha = 1
            self.orderButtonCenter.constant = 0
            self.view.layoutIfNeeded()
            
        })
    }
    
    func getNearestHospital(completion: (([String : AnyObject]) -> Void)){
        
        let key = "AIzaSyDp3lbh3B4McdPT-rgS8UYJb0w9UXN0Sj0"
        let lat = loc!.latitude
        let lon = loc!.longitude
        
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=\(key)&location=\(lat),\(lon)&radius=\(5000)&rankby=prominence&keyword=hospital&sensor=true"
        
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
    
    func displayDriverArrived(){
        self.performSegueWithIdentifier("DriverArrived", sender: self)
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue){
    
    }
    
    
}
