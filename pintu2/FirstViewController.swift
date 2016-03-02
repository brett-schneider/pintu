//
//  FirstViewController.swift
//  pintu2
//
//  Created by Brett on 04/02/16.
//  Copyright © 2016 Brett. All rights reserved.
//

import UIKit
import MobileCoreServices

class FirstViewController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var imagePicker : UIImagePickerController!

    @IBOutlet var mainView: UIView!
    @IBAction func snapButton(sender: UIButton) {
        imagePicker = UIImagePickerController()
        imagePicker.mediaTypes = [kUTTypeImage as String]
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            let actionSheetImageGetter = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Camera Roll", "Camera")
            actionSheetImageGetter.tag = 0
            actionSheetImageGetter.showInView(self.mainView)
        } else {
            let actionSheetImageGetter = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Camera Roll")
            actionSheetImageGetter.tag = 0
            actionSheetImageGetter.showInView(self.mainView)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if (actionSheet.tag == 0) {
            NSLog("Action Sheet Button Index %d, Action Sheet %d", buttonIndex, actionSheet.tag);
            if (buttonIndex != 0) {
                imagePicker.delegate = self
                imagePicker.allowsEditing = false
                if (buttonIndex == 1) {
                    // camera roll
                    imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                } else if (buttonIndex == 2) {
                    imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                }
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
        }
            
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        //
    }

}

