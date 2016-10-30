//
//  CurateTabViewC.swift
//  pintu3
//
//  Created by Brett on 03/10/16.
//  Copyright © 2016 Brett. All rights reserved.
//

import UIKit
import MapKit
import CoreData

var myStruct:[String] = ["Commentary", "Rating", "Album", "Map", "Preview"]

class CurateTabViewC: UITableViewController, MKMapViewDelegate, UITextViewDelegate, CLLocationManagerDelegate, JourneySelectorDelegate {

    @IBOutlet var inPicture: UIImage!
    @IBOutlet var inMetadata: NSDictionary!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var textView: UITextView!
    var myPins: MKAnnotationView!
    var manager: CLLocationManager!
    let authLoc = CLLocationManager.authorizationStatus()
    var pin: MKPointAnnotation!
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    let pinTxt = "This Pin"
    let journeySelectorSegue = "journeySelectorSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillShow:",name:UIKeyboardWillShowNotification, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillHide:",name:UIKeyboardWillHideNotification, object:nil)
        
        mapView.delegate = self
        textView.delegate = self

        imageView.image = inPicture
        let gps = inMetadata["{GPS}"]
        var lat: Double = 0
        var lon: Double = 0
        if (gps != nil) {
            lat = gps!["Latitude"] as! Double
            lon = gps!["Longitude"] as! Double
            print("exif: ", lat, " ", lon)
            let c = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            putPin(c)
            mapView.setCenterCoordinate(c, animated: true)
        } else {
            print("getting user location")
            manager = CLLocationManager() //instantiate
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest // required accurancy
            print("gps auth status", authLoc.rawValue)
            
            if #available(iOS 8.0, *) {
                if (authLoc == .NotDetermined) {
                    print("01: requesting authorisation for gps (ios8+)")
                    manager.requestWhenInUseAuthorization()
                } else if (authLoc == .Restricted || authLoc == .Denied) {
                    let c = CLLocationCoordinate2D(latitude: 0, longitude: 0)
                    putPin(c)
                    mapView.setCenterCoordinate(c, animated: true)
                } else if (authLoc == .AuthorizedAlways || authLoc == .AuthorizedWhenInUse) {
                    manager.startUpdatingLocation()
                    // mapView.showsUserLocation = true
                }
            } else {
                print("02: starting location updates (ios7)")
                manager.startUpdatingLocation() //update location
                // mapView.showsUserLocation = true
            }
        }
        self.textViewDidChange(self.textView)

//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedContext = appDelegate.managedObjectContext
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func putPin(coordinate: CLLocationCoordinate2D) {
        if (pin == nil) {
            pin = MKPointAnnotation()
            mapView.addAnnotation(pin)
        }
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationCurve(UIViewAnimationCurve.Linear)
        pin.coordinate = coordinate
        pin.title = pinTxt
        UIView.commitAnimations()
    }
    
    /* Location Manager Delegate */

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didupdatelocations")
        print("locations: ", locations)
        putPin((locations.first?.coordinate)!)
        mapView.setCenterCoordinate((locations.first?.coordinate)!, animated: true)
        print("stop updating location")
        manager.stopUpdatingLocation()
    }
    
    internal func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            print("03: authorisation status", status.hashValue)
            switch status {
            case CLAuthorizationStatus.AuthorizedWhenInUse:
                print("03: starting location updates (AuthorizedWhenInUse)")
                manager.startUpdatingLocation()
            case CLAuthorizationStatus.AuthorizedAlways:
                print("03: starting location updates (AuthorizedAlways)")
                manager.startUpdatingLocation()
            case CLAuthorizationStatus.NotDetermined:
                // After first request status may be not autorized, do request access again
                if #available(iOS 8.0, *) {
                    print("03: requesting authorisation for gps (ios8+)")
                    manager.requestWhenInUseAuthorization()
                }
            default: break
            }
    }
    
    /* Text View Delegate */
    
    var defTxtViewTxt: String!
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        textView.textColor = UIColor.blackColor()
        defTxtViewTxt = textView.text
        textView.text = ""
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        if (textView.text == "") {
            textView.text = defTxtViewTxt
            textView.textColor = UIColor.lightGrayColor()
        }
        /*
        var frame = textView.frame
        frame.size.height = textView.contentSize.height
        // frame.size.width = textView.contentSize.width
        textView.frame = frame
        print("textview changed to \(frame.width)x\(frame.height)")
        
        // var cframe = frame
        // cframe.size.height = frame.height + 8 + 21 + 8
        // cframe.origin = (textView.superview?.superview?.frame.origin)!
        
        // var nframe = cframe
        // nframe.origin = (textView.superview?.frame.origin)!
        // nframe.size.height = cframe.height - 0.5

        // textView.superview?.frame = nframe
        // textView.superview?.superview?.frame = cframe
        
        // tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
        tableView.reloadData()
        */
        tableView.beginUpdates()
        tableView.endUpdates()
        self.scrollToCursorForTextView(textView)
    }
    
    func textViewHeight() -> CGFloat {
        var textViewWidth = textView.frame.size.width
        if (textView.attributedText == nil) {
            // This will be needed on load, when the text view is not inited yet
            
            // textView = UITextView!
            // textView.attributedText = ""
            textViewWidth = screenSize.width - 8.0 - 8.0
        }
        let size = textView.sizeThatFits(CGSizeMake(textViewWidth, CGFloat.max))
        return size.height;
    }
    
    func scrollToCursorForTextView(textView: UITextView) {
        var cursorRect = textView.caretRectForPosition(textView.selectedTextRange!.start)
        cursorRect = self.tableView.convertRect(cursorRect, fromView: textView)
        if (!self.rectVisible(cursorRect)) {
            cursorRect.size.height += 8.0
            self.tableView.scrollRectToVisible(cursorRect, animated: true)
        }
    }
    
    func rectVisible(rect: CGRect) -> Bool {
        var visibleRect = CGRect()
        visibleRect.origin = self.tableView.contentOffset
        visibleRect.origin.y += self.tableView.contentInset.top
        visibleRect.size = self.tableView.bounds.size
        visibleRect.size.height -= self.tableView.contentInset.top + self.tableView.contentInset.bottom
        return CGRectContainsRect(visibleRect, rect)
    }
    
    func keyboardWillShow(aNotification: NSNotification) {
        let info = aNotification.userInfo!
        let kbSize = info[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        let contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0.0, kbSize.height, 0.0)
        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets
    }
    
    func keyboardWillHide(aNotification: NSNotification) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.35)
        let contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0.0, 0.0, 0.0)
        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets
        UIView.commitAnimations()
    }
    
    /* Map View Delegate */
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        putPin(mapView.centerCoordinate)
        print("mapView updated to: ", mapView.centerCoordinate)
        // pin.coordinate = mapView.centerCoordinate;
    }
    
    func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        print("regionWillChangeAnimated")
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "annotation"
        
        if let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
            
            return annotationView
        } else {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            return annotationView
        }
    }
    
    /* Table View Delegate */
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if (indexPath.row == 3) {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        var rv: CGFloat = 200.0
        if (indexPath.row == 0) {
            // rv = textView.frame.size.height + 8.0 + 21.0 + 8.0
            rv = textViewHeight() + 0.0 + 21.0 + 8.0 + 0.0
        }
        else if (indexPath.row == 5) {
            let asp = (imageView.image?.size.height)! / (imageView.image?.size.width)!
            rv = (screenSize.width-8.0-8.0) * asp + 8.0 + 8.0
            // print("image size: ", imageView.image?.size)
            // print("imageview frame: ", imageView.frame.size)
            // print("contentview frame: ", imageView.superview?.frame.size)
            // print("image aspect: ", asp)
            // print("indexrow: ", indexPath.row, " height: ", rv)

        }
        else {
            rv = super.tableView(tableView, heightForRowAtIndexPath: indexPath)
            // print("indexrow: ", indexPath.row, " height: ", rv)
        }
        
        // print("rowheight \(indexPath) :: \(rv)")
        return rv
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("selected: ", indexPath)
        print("image size: ", imageView.image?.size)
        print("imageview frame: ", imageView.frame.size)
        print("contentview frame: ", imageView.superview?.frame.size)
        print("textview frame: ", textView.frame.size)
    }
    
    // MARK: - Table view data source
/*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return myStruct.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("myCommentaryCell", forIndexPath: indexPath)

        return cell
    }
*/
    // MARK: - Navigation
    
    func dismiss() {
        navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == journeySelectorSegue) {
            if let nc = segue.destinationViewController as? UINavigationController {
                print("nc.topviewcontroller: ", nc.topViewController)
                print("nc: ", nc)
                print("nc.childviewcontrollers: ", nc.childViewControllers)
                if let jsel = nc.topViewController as? JourneySelector {
                    let bbi = UIBarButtonItem(title: "← Back", style: UIBarButtonItemStyle.Done, target: self, action: Selector("dismiss"))
                    jsel.navigationItem.leftBarButtonItem = bbi
                    // nc.popoverPresentationController!.delegate = self;
                    jsel.delegate = self;
                }
            }
        }
//        UINavigationController *nc = [segue destinationViewController];
//        nc.topViewController.navigationItem.leftBarButtonItem = bbi;
//        
//        NSLog(@"sending %@", selected);
//        CurateTabViewC *curate = (CurateTabViewC*)[nc topViewController];

        
    }
    
    // MARK: - JourneySelectorDelegate
    @IBOutlet weak var journeyCell: UITableViewCell!
    var journey: NSManagedObject!
    
    func selectedJourney(journey: NSManagedObject) {
        journeyCell.detailTextLabel!.text = journey.valueForKey("name") as? String
        self.journey = journey
    }
    
    // var station: PStationMO!
    
    @IBAction func saveStation(sender: UIBarButtonItem) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let moc = appDelegate.managedObjectContext

        let staEntity =  NSEntityDescription.entityForName("Station", inManagedObjectContext:moc)
        let station = PStationMO(entity: staEntity!, insertIntoManagedObjectContext:moc)

        let locEntity =  NSEntityDescription.entityForName("Location", inManagedObjectContext:moc)
        let location = NSManagedObject(entity: locEntity!, insertIntoManagedObjectContext:moc)
        print("setting coordinates...")
        location.setValue(pin.coordinate.latitude, forKey: "lat")
        location.setValue(pin.coordinate.longitude, forKey: "lon")
        print("done setting coordinates...")

        station.text = textView.text
        let p: Int16 = 1
        let r: Int16 = 1
        station.price = NSNumber(short: p)
        station.rating = NSNumber(short: r)
        station.addedBy = "Anonymous"
        station.addedByID = "c57a998f-e9f2-4d39-9b9e-54ed5e9d825c"
        station.addedDate = NSDate()
        station.image = UIImageJPEGRepresentation(inPicture, 1.0)!
        print("date: ", station.addedDate)
        station.location = location
        print("added location: ", location)
        // station.journeys = NSSet(array: [journey])
        station.mutableSetValueForKey("journeys").addObject(journey)
        // print("done setting shit right: ", station)
        
        appDelegate.saveContext()
        
        print("saved: ", station)
    }
    
}
