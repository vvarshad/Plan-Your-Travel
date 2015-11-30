

import UIKit
import CoreLocation
import SwiftyJSON

class MapViewController: UIViewController{
    
    
    @IBOutlet weak var mapView: GMSMapView!
    var source:String!
    var destination: String!
    var reachingTime: Int!
    let locationManager = CLLocationManager()
    lazy var data = NSMutableData()
    var mylocationCoordinates:String!
  //  var overviewPolyline: Dictionary<NSObject, AnyObject>
    var routePolyline: GMSPolyline!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        startConnection()
        
    }
    func generateURL()-> String{
        print(source)
        var url:String
        if(source == "myL"){
            url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(mylocationCoordinates)&destination=\(destination)&arrival_time=\(reachingTime)&mode=transit&traffic_model=optimistic&transit_routing_preference=less_walking&key=AIzaSyDQ131YZE9jSdwT5cLu6CTLW9ol0W1YxNM"
        }
        else{
            url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(source)&destination=\(destination)&arrival_time=\(reachingTime)&mode=transit&traffic_model=optimistic&transit_routing_preference=less_walking&key=AIzaSyDQ131YZE9jSdwT5cLu6CTLW9ol0W1YxNM"
        }
        return url
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func startConnection(){
        let urlPath: String = generateURL()
        let url: NSURL = NSURL(string: urlPath.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!
        let request: NSURLRequest = NSURLRequest(URL: url)
        let connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: false)!
        connection.start()
    }
    
    
    func processJSON(data1: NSDictionary!){
        let json = JSON(data1)
        //print("\(json) json from swifty")
        let legs = json["routes"][0]["legs"][0]
        let steps = json["routes"][0]["legs"][0]["steps"].array
        let overviewPolyline = json["routes"][0]["overview_polyline"]
        
               for item in steps! {
            let startLat = item["start_location"]["lat"].doubleValue
            print(" \(startLat) is Starting Latitude from JSON")
            let startLng = item["start_location"]["lng"].doubleValue
            let  position = CLLocationCoordinate2DMake(startLat, startLng)
            let marker = GMSMarker(position: position)
            //marker.title = item["html_instructions"].string
            //print("\(marker.title) is the title")
            marker.map = mapView
            
            
                            let route = item["polyline"]["points"].string
                            let path: GMSPath = GMSPath(fromEncodedPath: route)
                            routePolyline = GMSPolyline(path: path)
                            routePolyline.strokeWidth = 5
                            let tMode: String = item["travel_mode"].string!
            print(tMode)
                            if (tMode == "WALKING") {
                                routePolyline.strokeColor = UIColor.greenColor()
                            }
                            if (tMode == "TRANSIT"){
                                 routePolyline.strokeColor = UIColor.blueColor()
                            }
            
            
            
            
                            routePolyline.map = mapView
            
            
        }
        
        let endLat = steps?.last!["end_location"]["lat"].doubleValue
        print(" \(endLat) is ending Latitude from JSON")
        let ebdLng = steps?.last!["end_location"]["lng"].doubleValue
        let  position = CLLocationCoordinate2DMake(endLat!, ebdLng!)
        let marker = GMSMarker(position: position)
        //marker.title = item["html_instructions"].string
        //print("\(marker.title) is the title")
        marker.map = mapView
        
        
    
        
        
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier=="goRoute"){
            //segue.destinationViewController as? RouteViewController
            let routeViewController = segue.destinationViewController as? RouteViewController
            routeViewController?.source = source
            routeViewController?.destination = destination
            routeViewController?.reachingTime = reachingTime
            routeViewController?.mylocationCoordinates = self.mylocationCoordinates

        }
        
    }

    
 
}
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
            mapView.accessibilityElementsHidden = false
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
        }
        
    }
}

extension MapViewController: NSURLConnectionDelegate{
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!){
        self.data.appendData(data)
    }
    
    func buttonAction(sender: UIButton!){
        startConnection()
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        // throwing an error on the line below (can't figure out where the error message is)
        do{
            let jsonResult: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary as NSDictionary!;
            //print(jsonResult)
            processJSON(jsonResult)
        }catch let error as NSError {
            print("json error: \(error.localizedDescription)")
        }
        
    }
}

