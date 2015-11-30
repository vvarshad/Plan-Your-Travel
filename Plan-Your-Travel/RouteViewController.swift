

import UIKit
//import CoreLocation
import SwiftyJSON

class RouteViewController: UIViewController{
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var labelFromto:UILabel!
    @IBOutlet weak var labelJourneySteps:UILabel!
    @IBOutlet weak var labelTimeTaken:UILabel!
    @IBOutlet weak var labelDistance:UILabel!
    @IBOutlet weak var labelStartBy:UILabel!
    var source:String!
    var destination: String!
    var reachingTime: Int!
    let locationManager = CLLocationManager()
    lazy var data = NSMutableData()
    var mylocationCoordinates:String!
    var items: [String]! = []
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
        labelFromto.text="Route to \(destination)"
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        startConnection()
        
    }
    func generateURL()-> String{
        
        print(source)
        var url:String
        if(source == "myL"){
            url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(mylocationCoordinates)&destination=\(destination)&arrival_time=\(reachingTime)&mode=transit&traffic_model=optimistic&transit_routing_preference=less_walking&key=YOUR_DIRECTION_SERVER_KEY"
        }
        else{
            url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(source)&destination=\(destination)&arrival_time=\(reachingTime)&mode=transit&traffic_model=optimistic&transit_routing_preference=less_walking&key=YOUR_DIRECTION_SERVER_KEY"
        }
        
        print(url)
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
       
        let legs = json["routes"][0]["legs"][0]
       
        
        labelDistance.text = "Distance :\(legs["distance"]["text"].stringValue)"
        labelTimeTaken.text = "Travel Time:\(legs["duration"]["text"].stringValue)"
        let stTimestamp = reachingTime - legs["duration"]["value"].intValue
        let date = NSDate(timeIntervalSince1970: Double(stTimestamp))
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = NSDateFormatterStyle.MediumStyle //Set time style
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle //Set date style
        dateFormatter.timeZone = NSTimeZone()
        dateFormatter.dateFormat = "hh:mm a"
        let localDate = dateFormatter.stringFromDate(date)
        labelStartBy.text = "Start latest by\(localDate)"
      
        let steps = legs["steps"].array
      
        for step in steps!{
            let htmlIns = step["html_instructions"].stringValue
            items.append(htmlIns.html2String)
            //print(htmlIns.html2String)
            let tMode: String = step["travel_mode"].string!
          
            if (step["transit_details"]["line"]["short_name"].string != nil ){
                
            
     labelJourneySteps.text?.appendContentsOf("> \(step["transit_details"]["line"]["short_name"].stringValue)")
           
            }
            
            
        }
        
        tableView.reloadData()
        
        
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier=="goHome"){
            segue.destinationViewController as? ViewController
        }
        if segue.identifier == "showMap" {
            let mapViewController = segue.destinationViewController as? MapViewController
            mapViewController?.source = self.source
            mapViewController?.destination = self.destination
            mapViewController?.reachingTime = self.reachingTime
            mapViewController?.mylocationCoordinates = self.mylocationCoordinates
        }

    }

    
    
    
}


extension RouteViewController: NSURLConnectionDelegate{
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

extension RouteViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        cell.textLabel?.text = self.items[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }

}
extension String {
    
    var html2AttributedString: NSAttributedString? {
        guard
            let data = dataUsingEncoding(NSUTF8StringEncoding)
            else { return nil }
        do {
            return try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:NSUTF8StringEncoding], documentAttributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

