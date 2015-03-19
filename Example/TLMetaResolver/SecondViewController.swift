//
//  ViewController.swift
//  TLMetaResolver
//
//  Created by Bruno Berisso on 2/12/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

import UIKit
import TLMetaResolver

class SecondViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    var pageUrl: NSURL!
    
    private var timer: NSTimer!
    private var resolvingMetaTags: Bool!
    private var nativeActivity: TLNativeAppActivy!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarHidden = false
        
        let spinner = UIActivityIndicatorView()
        spinner.startAnimating()
        spinner.activityIndicatorViewStyle = .Gray
        
        let spinnerBarItem = UIBarButtonItem(customView: spinner)
        navigationItem.rightBarButtonItem = spinnerBarItem
        
        resolvingMetaTags = false
        webView.loadRequest(NSURLRequest(URL: pageUrl))
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if (timer != nil) {
            timer.invalidate()
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("resolveMetaTags"), userInfo: nil, repeats: false)
    }
    
    func resolveMetaTags () {
        
        if !resolvingMetaTags {
            resolvingMetaTags = true
            
            webView.resolveMetaTags({ (activity: TLNativeAppActivity?) -> () in
                if activity != nil {
                    self.nativeActivity = activity!
                }
                
                let actionBarItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: Selector("didSelecteAction"))
                actionBarItem.enabled = activity != nil
                self.navigationItem.rightBarButtonItem = actionBarItem
            })
        }
    }
    
    func didSelecteAction () {
        
        let activityController = UIActivityViewController(activityItems: [self.pageUrl], applicationActivities: [nativeActivity])
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.presentViewController(activityController, animated: true, completion: nil)
        } else {
            let popover = UIPopoverController(contentViewController: activityController)
            popover.presentPopoverFromBarButtonItem(navigationItem.rightBarButtonItem!, permittedArrowDirections: .Any, animated: true)
        }
        
    }
}

