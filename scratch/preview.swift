//
//  preview.swift
//  pintu2
//
//  Created by Brett on 26/02/16.
//  Copyright © 2016 Brett. All rights reserved.
//

import UIKit
import AVFoundation

class preview: UIView {
    override class func layerClass() -> AnyClass
    {
        return AVCaptureVideoPreviewLayer.self
    }

    func session() -> AVCaptureSession
    {
        let previewLayer = self.layer as! AVCaptureVideoPreviewLayer
        return previewLayer.session;
    }
    
    func setSession(session: AVCaptureSession) {
        let previewLayer: AVCaptureVideoPreviewLayer = (self.layer as! AVCaptureVideoPreviewLayer)
        previewLayer.session = session
    }
}


