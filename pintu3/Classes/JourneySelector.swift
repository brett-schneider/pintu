//
//  pintuAlbumSelectorTableViewController.swift
//  pintu3
//
//  Created by Brett on 26/10/16.
//  Copyright © 2016 Brett. All rights reserved.
//

import UIKit
import CoreData

protocol JourneySelectorDelegate: class {
    func selectedJourney(journeyName: PJourneyMO)
}

class JourneySelector: UITableViewController, NSFetchedResultsControllerDelegate, UIAlertViewDelegate {

    var delegate: JourneySelectorDelegate?
    @IBOutlet weak var tvtitle: NSString!
    private let stationSelectorSegue = "stationSelectorSegue"

    override func viewDidLoad() {
        super.viewDidLoad()
        if (tvtitle != nil) {
            self.navigationItem.title = tvtitle as String
        } else {
            self.navigationItem.title = "Select a Journey"
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Journey")
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            journeys = results as! [PJourneyMO]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return section == 0 ? 1 : journeys.count
        if (self.delegate != nil) {
            return section == 0 ? 0 : journeys.count
        } else {
            return section == 0 ? 1 : journeys.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("journeyCell")
        if (indexPath.section == 0) {
            cell!.textLabel!.text = "# unspecified"
        } else {
            let journey = journeys[indexPath.row]
            cell!.textLabel!.text = journey.valueForKey("name") as? String
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (self.delegate != nil) {
            if (indexPath.section == 1) {
                self.dismissViewControllerAnimated(true, completion: {
                    self.delegate?.selectedJourney(self.journeys[indexPath.row])
                })
            }
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addName(sender: UIBarButtonItem) {
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: "New Name",  message: "Add a new Journey", preferredStyle: .Alert)
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
            let alert = UIAlertView(title: "New Name", message: "Add a new Journey", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Save")
            alert.alertViewStyle = .PlainTextInput
            alert.show()
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        print("clicked button: \(buttonIndex)")
        self.saveName(alertView.textFieldAtIndex(0)!.text!)
        self.tableView.reloadData()
    }
    
    // var fetchedResultsController: NSFetchedResultsController!
    var journeys = [PJourneyMO]()
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
        // let journey = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:moc)
        let journey = NSEntityDescription.insertNewObjectForEntityForName("Journey", inManagedObjectContext: moc) as! PJourneyMO
        
        //3
        print("saving: ", name)
        journey.setValue(name, forKey: "name")
        
        //4
        appDelegate.saveContext()
        journeys.append(journey)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == stationSelectorSegue) {
            if let nc = segue.destinationViewController as? UINavigationController {
                if let ssel = nc.topViewController as? StationSelector {
                    print("got stationselector: ", ssel)
                    let bbi = UIBarButtonItem(title: "← Back", style: UIBarButtonItemStyle.Done, target: self, action: Selector("dismiss"))
                    ssel.navigationItem.leftBarButtonItem = bbi
                    let path = self.tableView.indexPathForSelectedRow!
                    if (path.section == 1){
                        ssel.journey = journeys[path.row]
                        print("sending \(journeys[path.row])")
                    } else {
                        ssel.journey = nil
                        print("sending nil aka journey #unspecified")
                    }
                }
            }
        }
    }
    
    func dismiss() {
        navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }
}
