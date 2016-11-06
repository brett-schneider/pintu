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
import Foundation
import AVKit
import AVFoundation

var myStruct:[String] = ["Commentary", "Rating", "Album", "Map", "Preview"]

class CurateTabViewC: UITableViewController, MKMapViewDelegate, UITextViewDelegate, CLLocationManagerDelegate, JourneySelectorDelegate, DLStarRatingDelegate {

    @IBOutlet var inPicture: UIImage!
    @IBOutlet var inMetadata: NSDictionary!
    @IBOutlet var inStation: PStationMO?
    @IBOutlet var inVideoURL: NSURL?
    var videoData: NSData?
    var station: PStationMO!
    
    @IBOutlet weak var previewContentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var textView: UITextView!
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer?
    var myPins: MKAnnotationView!
    var manager: CLLocationManager!
    let authLoc = CLLocationManager.authorizationStatus()
    var pin: MKPointAnnotation!
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    let pinTxt = "This Pin"

    let journeySelectorSegue = "journeySelectorSegue"
    
    private var rating: DLStarRatingControl!
    private var price: DLStarRatingControl!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var stationName: UITextField!
    
    private var myDescriptionCellIndex = 1
    private var myJourneyCellIndex = 4
    private var myImageCellIndex = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillShow:",name:UIKeyboardWillShowNotification, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillHide:",name:UIKeyboardWillHideNotification, object:nil)
        
        mapView.delegate = self
        textView.delegate = self
        
        rating = setupRatingCell(ratingView.frame)
        price = setupRatingCell(ratingView.frame)
        ratingView.addSubview(rating)
        priceView.addSubview(price)
        
        print ("yo")
        
        if (inStation != nil) {
            print("got station: \(inStation)")
            populateView(inStation!)
        } else if (inPicture != nil) {
            imageView.image = inPicture
            var lat: Double = 0
            var lon: Double = 0
            if (inMetadata != nil) {
                let gps = inMetadata["{GPS}"]
                if (gps != nil) {
                    lat = gps!["Latitude"] as! Double
                    lon = gps!["Longitude"] as! Double
                    print("exif: ", lat, " ", lon)
                    let c = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    putPin(c)
                    mapView.setCenterCoordinate(c, animated: true)
                }
            }
        } else if (inVideoURL != nil) {
            print("it's a video")
            print("got video at: \(inVideoURL)")
            do {
                videoData = try NSData(contentsOfURL: self.inVideoURL!, options: NSDataReadingOptions.DataReadingMappedIfSafe)
            } catch {
                print ("unable to read video file \(error)")
            }
            self.initAVPlayer(inVideoURL!)
        }
        
        if (pin == nil) {
            // keine location data also muss user daten her
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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func initAVPlayer(url: NSURL) {
        player = AVPlayer(URL: url)
        // TODO: Video Layer korrekt positionieren (bounds kommt mit 600er Breite zurück und so :-(
        self.playerLayer = AVPlayerLayer(player: player)
        self.playerLayer!.frame = CGRectMake(0.0, 0.0, self.tableView.bounds.width-16.0, self.imageView.bounds.height)
        self.imageView.layer.addSublayer(self.playerLayer!)
        player.play()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerItemDidReachEnd:", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.player.currentItem)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        print("viewWillTransitionToSize \(size)")
        self.playerLayer?.frame = CGRectMake(0.0, 0.0, size.width-16.0, self.imageView.bounds.height)
    }
    
    override func layoutSublayersOfLayer(layer: CALayer) {
        print("layoutSublayersOfLayer \(layer)")
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
        let newloc = locations.first
        print("newloc accuracy \(newloc?.horizontalAccuracy) / \(newloc?.verticalAccuracy)")
        // TODO: Timeout?
        if (newloc?.horizontalAccuracy < 100.0 && newloc?.verticalAccuracy < 100.0) {
            putPin((newloc?.coordinate)!)
            mapView.setCenterCoordinate((newloc?.coordinate)!, animated: true)
            print("stop updating location")
            manager.stopUpdatingLocation()
        }
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
    
    /* AVPlayer */
    
    func playerItemDidReachEnd(notification: NSNotification) {
        self.player.seekToTime(kCMTimeZero)
        self.player.play()
        // print("self.previewContentView.frame.width \(self.previewContentView.frame.width)")
        // print("self.tableView.frame.width \(self.tableView.frame.width)")
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
        if (indexPath.row == myJourneyCellIndex) {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        var rv: CGFloat = 200.0
        if (indexPath.row == myDescriptionCellIndex) {
            // rv = textView.frame.size.height + 8.0 + 21.0 + 8.0
            rv = textViewHeight() + 0.0 + 21.0 + 8.0 + 0.0
        }
        else if (indexPath.row == myImageCellIndex) {
            if (imageView.image == nil) {
                rv = super.tableView(tableView, heightForRowAtIndexPath: indexPath)
            } else {
                let asp = (imageView.image?.size.height)! / (imageView.image?.size.width)!
                rv = (screenSize.width-8.0-8.0) * asp + 8.0 + 8.0
            }
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
    }
    
    // MARK: - JourneySelectorDelegate
    @IBOutlet weak var journeyCell: UITableViewCell!
    var journey: PJourneyMO!
    
    func selectedJourney(journey: PJourneyMO) {
        journeyCell.detailTextLabel!.text = journey.valueForKey("name") as? String
        self.journey = journey
        self.tableView.beginUpdates()
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: myJourneyCellIndex, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
        self.tableView.endUpdates()
    }
    
    // MARK: - DLStarRatingDelegate
    func newRating(control: DLStarRatingControl!, _ rating: Float) {
        print("new rating: ", rating)
    }
    
    // MARK: - Handling the Data
    
    @IBAction func saveStation(sender: UIBarButtonItem) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let moc = appDelegate.managedObjectContext
        
        var location: PLocationMO
        
        if (station == nil) {
            let staEntity =  NSEntityDescription.entityForName("Station", inManagedObjectContext:moc)
            station = PStationMO(entity: staEntity!, insertIntoManagedObjectContext:moc)
            station.addedBy = "Anonymous"
            station.addedByID = "c57a998f-e9f2-4d39-9b9e-54ed5e9d825c"
            station.addedDate = NSDate()
            location = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: moc) as! PLocationMO
        } else {
            location = station.location!
        }

        print("setting coordinates...")
        location.setValue(pin.coordinate.latitude, forKey: "lat")
        location.setValue(pin.coordinate.longitude, forKey: "lon")
        print("done setting coordinates...")
        station.location = location
        print("added location: ", location)

        station.name = stationName.text
        station.text = textView.text
        station.price = Int(price.rating)
        station.rating = Int(rating.rating)
        if (imageView.image != nil) {
            station.image = UIImageJPEGRepresentation(imageView.image!, 1.0)!
        } else if (inVideoURL != nil) {
            print("saving video at \(self.inVideoURL)")
            station.image = videoData
        }
        if (journey != nil) {
            // station.mutableSetValueForKey("journeys").addObject(journey)
            // journey.valueForKey("stations")?.addObject(station)
            station.addJourney(journey)
            journey.addStation(station)
        }
        
        appDelegate.saveContext()
        
        print("saved: ", station)
    }
    
    func populateView(station: PStationMO) {
        stationName.text = station.name
        
        var c = UInt64()
        station.image!.getBytes(&c, length: 8)
        switch (c<<40) {
        case 0xffd8ff00_00000000:
            print ("image/jpeg")
            let img = UIImage(data: station.image!)
            imageView.image = img
            print("imitch loaded: \(img)")
            break
        case UInt64(0):
            // 0x7079746614000000
            if (c == 0x70797466_14000000) {
                print ("movie")
                videoData = station.image
                let tmp = NSURL.fileURLWithPath(NSTemporaryDirectory(), isDirectory: true)
                let fna = NSProcessInfo.processInfo().globallyUniqueString
                let url = tmp.URLByAppendingPathComponent("\(fna).mov")
                videoData?.writeToURL(url, atomically: true)
                self.initAVPlayer(url)
            }
            break
        default:
            print("unknown mime type: ", String(c, radix:16))
            print("unknown mime type: ", String(c<<40, radix:16))
            break
        }

        // imageView.image = UIImage(data: station.image!)
        price.rating = station.price!.floatValue
        rating.rating = station.rating!.floatValue
        textView.text = station.text
        let gotLoc = station.location
        if (gotLoc != nil) {
            // print("gotLoc: \(gotLoc), lat: \(gotLoc?.lat), lon: \(gotLoc?.lon)")
            // print("doubles! lat: \(NSNumber(float: (gotLoc?.lat)!).doubleValue), lon: \(NSNumber(float: (gotLoc?.lon)!).doubleValue)")
            let lat = NSNumber(float: (gotLoc?.lat)!).doubleValue
            let lon = NSNumber(float: (gotLoc?.lon)!).doubleValue
            putPin(CLLocationCoordinate2DMake(lat, lon))
        }
        // TODO: More than one Journey!
        let gotJourney = station.journeys!.allObjects.first as? PJourneyMO
        if (gotJourney != nil) {
            selectedJourney(gotJourney!)
            print("got journey: \(journey)")
        }
        self.station = station
    }
    
    func setupRatingCell(frame: CGRect) -> DLStarRatingControl {
        print("initialising 5-star rating yo...")

        // Custom Number of Stars
        let rater = DLStarRatingControl(frame:CGRectMake(0.0, 0.0, frame.width, frame.height))
        rater.delegate = self
        rater.backgroundColor = UIColor.clearColor()
        rater.autoresizingMask = [.FlexibleLeftMargin, .FlexibleWidth, .FlexibleHeight, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleBottomMargin]
        rater.rating = 0.0
        
        print ("rater aufgesetzt: ", rater)
        
        /*
        // Custom Images
        rater.setStar(UIImage(named: "n_star.png"), highlightedStar:UIImage(named: "n_star_highlighted.png"), atIndex:0)
        rater.setStar(UIImage(named: "n_star.png"), highlightedStar:UIImage(named: "n_star_highlighted.png"), atIndex:1)
        rater.setStar(UIImage(named: "n_star.png"), highlightedStar:UIImage(named: "n_star_highlighted.png"), atIndex:2)
        rater.setStar(UIImage(named: "n_star.png"), highlightedStar:UIImage(named: "n_star_highlighted.png"), atIndex:3)
        rater.setStar(UIImage(named: "n_star.png"), highlightedStar:UIImage(named: "n_star_highlighted.png"), atIndex:4)
        */

        return rater
    }
    
}
