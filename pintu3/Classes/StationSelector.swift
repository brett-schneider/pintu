//
//  pintuAlbumSelectorTableViewController.swift
//  pintu3
//
//  Created by Brett on 26/10/16.
//  Copyright © 2016 Brett. All rights reserved.
//

import UIKit
import CoreData

protocol StationSelectorDelegate: class {
    func selectedStation(station: PStationMO)
}

class StationSelector: UITableViewController, NSFetchedResultsControllerDelegate {

    var delegate: StationSelectorDelegate?
    @IBOutlet var tvtitle: NSString!
    @IBOutlet var journey: PJourneyMO?
    private var stationEditorSegue = "stationEditorSegue"

    override func viewDidLoad() {
        super.viewDidLoad()
        if (tvtitle != nil) {
            self.navigationItem.title = tvtitle as String
        } else {
            self.navigationItem.title = "Select a Station"
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (journey != nil) {
            print("nontrivial journey received: \(journey)")
            /*
            let predicate = NSPredicate(format:"ANY journeys.name = [cd] %s", (journey?.name)!)
            fetchRequest.predicate = predicate
            */
            stations = journey?.stations?.allObjects as! [PStationMO]
        } else {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let moc = appDelegate.managedObjectContext
            
            let fetchRequest = NSFetchRequest(entityName: "Station")
            let predicate = NSPredicate(format:"journeys.@count = 0")
            fetchRequest.predicate = predicate
            
            do {
                let results = try moc.executeFetchRequest(fetchRequest)
                stations = results as! [PStationMO]
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
        }
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stations.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("stationCell")
        
        let station = stations[indexPath.row]
        if (station.valueForKey("name") as? String != nil) {
            // cell!.textLabel!.text = "name: \(station.valueForKey("name") as? String)"
            cell!.textLabel!.text = station.valueForKey("name") as? String
        } else if (station.valueForKey("text") as? String != nil) {
            cell!.textLabel!.text = station.valueForKey("text") as? String
        } else {
            cell!.textLabel!.text = "#no name"
        }
        return cell!
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    /*
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let nc = segue.destinationViewController as? UINavigationController {
            if let cur = nc.topViewController as? CurateTabViewC {
                let bbi = UIBarButtonItem(title: "← Back", style: UIBarButtonItemStyle.Done, target: self, action: Selector("dismiss"))
                cur.navigationItem.leftBarButtonItem = bbi
                let path = self.tableView.indexPathForSelectedRow!
                cur.inStation = stations[path.row]
                print("curator view: \(cur)")
                print("transmitting station: \(cur.inStation)")
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    func dismiss() {
        navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addName(sender: UIBarButtonItem) {
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: "New Name",  message: "Add a new name", preferredStyle: .Alert)
            let saveAction = UIAlertAction(title: "Save", style: .Default, handler: { (action:UIAlertAction) -> Void in
                let textField = alert.textFields!.first
                self.saveName(textField!.text!)
                self.tableView.reloadData()
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action: UIAlertAction) -> Void in }
            
            alert.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in }
            
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            
            presentViewController(alert, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    // var fetchedResultsController: NSFetchedResultsController!
    var stations = [PStationMO]()
    // let dataController = DataController()
    
    /*
    func initializeFetchedResultsController() {
        let request = NSFetchRequest(entityName: "Title")
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [nameSort]
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let moc = appDelegate.managedObjectContext
        // let moc = dataController.managedObjectContext
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: "department.name", cacheName: "rootCache")
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    */
    
    func saveName(name: String) {
        //1
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let moc = appDelegate.managedObjectContext
        // let moc = dataController.managedObjectContext
        
        //2
        // let entity =  NSEntityDescription.entityForName("Journey", inManagedObjectContext:moc)
        // let station = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:moc)
        let station = NSEntityDescription.insertNewObjectForEntityForName("Station", inManagedObjectContext: moc) as! PStationMO

        //3
        print("saving: ", name)
        station.setValue(name, forKey: "name")
        
        //4
        appDelegate.saveContext()
        stations.append(station)
        /*
        do {
            try moc.save()
            //5
            titles.append(title)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        */
    }

}
