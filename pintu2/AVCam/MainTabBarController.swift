//
//  MainTabBarController.swift
//  pintu2
//
//  Created by Brett on 29/03/16.
//  Copyright © 2016 Brett. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        for tabBarItem in tabBar.items! {
            // NSLog("removing %@", tabBarItem.title!)
            tabBarItem.title = ""
            tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
