//
//  FilterViewController.swift
//  pintu2
//
//  Created by Brett on 08/03/16.
//  Copyright © 2016 Brett. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var image: UIImage? = nil
    var iView: UIImageView!
    var zView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("image received: %@", image!)
        
        iView = UIImageView(image: image)
        iView.sizeToFit()
        zView = UIView()
        zView.frame = iView.frame

        self.scrollView.addSubview(zView)
        zView.addSubview(iView)

        let zw = zView.frame.size.width;
        let zh = zView.frame.size.height;
        let sw = self.scrollView.frame.size.width;
        let sh = self.scrollView.frame.size.height;
        
        self.scrollView.minimumZoomScale = min(sw/zw, sh/zh) // 1.0f;
        self.scrollView.zoomScale = max(sw/zw, sh/zh)
        self.scrollView.maximumZoomScale = 5.0;
        
        centreScrollView(self.scrollView)
        
        logViewFrames()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIScrollViewDelegate
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return zView;
        // return zoomView;
    }
    
    func centreScrollView(scrollView: UIScrollView) {
        scrollView.contentOffset = CGPointMake((scrollView.contentSize.width-scrollView.frame.size.width)/2, (scrollView.contentSize.height-scrollView.frame.size.height)/2)
    }
    
    func logViewFrames() {
        NSLog("image %@", NSStringFromCGSize(image!.size))
        NSLog("scrollview.zoomscale %2.3f", scrollView.zoomScale)
        NSLog("scrollView frame   x:%3.0f y:%3.0f w:%3.0f h:%3.0f", scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height);
        NSLog("scrollView frame   x:%3.0f y:%3.0f w:%3.0f h:%3.0f", scrollView.frame.origin.x, scrollView.frame.origin.y, scrollView.frame.size.width, scrollView.frame.size.height);
        NSLog("zView frame        x:%3.0f y:%3.0f w:%3.0f h:%3.0f", zView.frame.origin.x, zView.frame.origin.y, zView.frame.size.width, zView.frame.size.height);
        NSLog("contentOffset      x:%3.0f y:%3.0f", self.scrollView.contentOffset.x, self.scrollView.contentOffset.y)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let offsetX = max((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY = max((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0)
        NSLog("setting center to x:%3.0f y:%3.0f", offsetX, offsetY)
        
        let sv = scrollView.subviews.first
        sv!.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY)

        logViewFrames()
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
