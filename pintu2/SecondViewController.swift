//
//  SecondViewController.swift
//  pintu2
//
//  Created by Brett on 04/02/16.
//  Copyright © 2016 Brett. All rights reserved.
//

import UIKit
import AVFoundation

class SecondViewController: UIViewController {
    
    let capSess = AVCaptureSession()
    var capDev : AVCaptureDevice?
    @IBOutlet weak var pick: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // get avcapture devices
        capSess.sessionPreset = AVCaptureSessionPresetLow
        let devices = AVCaptureDevice.devices()
        NSLog("device liste %@", devices)
        
        for device in devices {
            if (device.hasMediaType(AVMediaTypeVideo)) {
                if (device.position == AVCaptureDevicePosition.Back) {
                    capDev = device as? AVCaptureDevice
                }
            }
        }
        if (capDev != nil) {
            beginSession()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func beginSession() {
        do {
            let input = try AVCaptureDeviceInput(device: capDev) as AVCaptureDeviceInput
            capSess.addInput(input)
        } catch let error as NSError {
            NSLog("error beginSession: %s", error.localizedDescription)
        }
        let previewLayer = AVCaptureVideoPreviewLayer(session: capSess)
        pick.layer.addSublayer(previewLayer)
        previewLayer?.frame = self.view.layer.frame
        capSess.startRunning()
    }

    func configureDevice() {
        if let device = capDev {
            do {
                try device.lockForConfiguration()
                device.focusMode = .Locked
                device.unlockForConfiguration()
            } catch let error as NSError {
                NSLog("error configureDevice/ device.lockForConfiguration: %s", error.localizedDescription)
            }
        }
    }
    func focusTo(value : Float) {
        if let device = capDev {
            do {
                try device.lockForConfiguration()
                device.setFocusModeLockedWithLensPosition(value, completionHandler: { (time) -> Void in
                    //
                })
                device.unlockForConfiguration()
                
            }
            catch let error as NSError {
                NSLog("error configureDevice/ device.lockForConfiguration: %s", error.localizedDescription)
            }
        }
    }
}

