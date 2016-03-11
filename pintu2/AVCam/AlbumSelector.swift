//
//  TableViewController.swift
//  pintu2
//
//  Created by Brett on 06/03/16.
//  Copyright © 2016 Brett. All rights reserved.
//

import UIKit
import AssetsLibrary

@objc protocol AlbumSelectorDelegate {
    func selectedAlbum(selectedAlbum: ALAssetsGroup)
}

class AlbumSelector: UITableViewController {
    
    var delegate: AlbumSelectorDelegate?
    var groups: NSMutableArray!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Select Album"

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
/*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
*/
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.groups.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("albumCell", forIndexPath: indexPath)
        
        let groupForCell: ALAssetsGroup = self.groups[indexPath.row] as! ALAssetsGroup
        // when using the posterimages, there is a problem with zombie cgimages
        // let posterImage = UIImage(CGImage: groupForCell.posterImage().takeRetainedValue())
        // cell.imageView!.image = posterImage
        cell.textLabel!.text = groupForCell.valueForProperty(ALAssetsGroupPropertyName) as? String
        cell.detailTextLabel?.text = String(groupForCell.numberOfAssets())

        return cell
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    /*
    func close() {
        if (NSThread.isMainThread()) {
            self.dismissViewControllerAnimated(true, completion: nil);
        } else {
            dispatch_async(dispatch_get_main_queue(), { self.close() })
        }
    }
    */
        
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let groupForCell: ALAssetsGroup = self.groups[indexPath.row] as! ALAssetsGroup
        NSLog("go back to lib with ALAssetsGroup %@", groupForCell)
        self.dismissViewControllerAnimated(true, completion: {
            self.delegate?.selectedAlbum(groupForCell)
            NSLog("dismiss completed. groupforcell is %@", groupForCell)
        })
        
    }

/*
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let groupForCell: ALAssetsGroup = self.groups[indexPath.row] as! ALAssetsGroup
        NSLog("go back to lib with ALAssetsGroup %@", groupForCell)
        self.delegate?.dismissAlbumSelector(groupForCell)
        
        self.dismissViewControllerAnimated(true, completion: nil)
        // self.close();
    }
*/
}
