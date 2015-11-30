

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var txtReachingTime: UITextField!
    @IBOutlet weak var txtDestination: UITextField!
    @IBOutlet weak var txtStartingFrom: UITextField!
    var flagMyLocation:String = "myL"
    var timeStamp:Int!
    var placeholderLabel : UILabel!
    let locationManager = CLLocationManager()
    var mylocationCoordinates:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let timePicker: UIDatePicker = UIDatePicker()
        timePicker.datePickerMode=UIDatePickerMode.Time
        timePicker.timeZone=NSTimeZone.localTimeZone();
        txtReachingTime.inputView = timePicker
        timePicker.addTarget(self, action: Selector("handleDatePicker:"), forControlEvents: UIControlEvents.ValueChanged)
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        txtStartingFrom.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "My Location"
       // placeholderLabel.font = UIFont.italicSystemFontOfSize(txtStartingFrom.font!.pointSize)
        placeholderLabel.sizeToFit()
        txtStartingFrom.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPointMake(5, txtStartingFrom.font!.pointSize / 2)
        placeholderLabel.textColor = UIColor(white: 0, alpha: 0.3)
        placeholderLabel.hidden = !txtStartingFrom.text!.isEmpty
        txtStartingFrom.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
    }

    func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        timeStamp = Int(sender.date.timeIntervalSince1970)
        print(timeStamp)
        txtReachingTime.text = dateFormatter.stringFromDate(sender.date)
    }
    func validateControls()->Bool{
        if(txtReachingTime.text==""){
            displayAlert("Error", message: "Kindly enter reaching time for us to suggest best routes to you")
            return false
        }
        if(txtDestination.text==""){
            displayAlert("Error", message: "Kindly enter Destination for us to suggest best routes to you")
            return false
        }
        return true
    }
    
    func displayAlert(title:String, message:String){
        let myAlert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        myAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(myAlert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       
        if (validateControls()){
        if segue.identifier == "showRoute" {
            let routeViewController = segue.destinationViewController as? RouteViewController
            routeViewController?.source = flagMyLocation
            routeViewController?.destination = txtDestination!.text
            routeViewController?.reachingTime = timeStamp
            routeViewController?.mylocationCoordinates = self.mylocationCoordinates
        }
        }
    }
    
 
}

extension ViewController: UITextFieldDelegate{
    func textFieldDidChange(textField: UITextField) {
        if(textField.text!.isEmpty){
        placeholderLabel.hidden = false
        flagMyLocation="myL"
        }
        else{
            flagMyLocation=txtStartingFrom.text!
        }
    }
}
extension ViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
           
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let locValue:CLLocationCoordinate2D = manager.location!.coordinate
            mylocationCoordinates = "\(locValue.latitude),\(locValue.longitude)"
            print(mylocationCoordinates)
            locationManager.stopUpdatingLocation()
        }
        
    }
}



