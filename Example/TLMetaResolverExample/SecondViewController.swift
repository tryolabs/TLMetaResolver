//
//  ViewController.swift
//  TLMetaResolver
//
//  Created by Bruno Berisso on 2/12/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

import UIKit



class NativeAppActivity: TLNativeAppActivity {
    
    var onPerform: (()->()) -> ()
    
    init(nativeAppInfo: TLNativeAppInfo, onPerform: (didFinish: ()->()) -> ()) {
        self.onPerform = onPerform
        super.init(nativeAppInfo: nativeAppInfo)
    }
    
    override func performActivity() {
        onPerform {
            self.activityDidFinish(true)
        }
    }
}


class SecondViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    var pageUrl: NSURL!
    
    private var timer: NSTimer!
    private var resolvingMetaTags: Bool!
    private var appInfo: TLNativeAppInfo!
    
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
            
            webView.resolveMetaTags({ (appInfo: TLNativeAppInfo?) -> () in
                if appInfo != nil {
                    self.appInfo = appInfo!
                }
                
                let actionBarItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: Selector("didSelecteAction"))
                actionBarItem.enabled = appInfo != nil
                self.navigationItem.rightBarButtonItem = actionBarItem
            })
        }
    }
    
    func didSelecteAction () {
        
        let nativeActivity = NativeAppActivity(nativeAppInfo: self.appInfo) { (didFinish) -> () in
            
            #if arch(i386) || arch(x86_64)
                
                let alertController = UIAlertController(title: "Open \(self.appInfo.name)", message: "Url: \(self.appInfo.url)", preferredStyle: .Alert)
                
                alertController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (_) -> Void in
                    didFinish()
                }))
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
            #else
                
                if (UIApplication.sharedApplication().canOpenURL(self.appInfo.url)) {
                    UIApplication.sharedApplication().openURL(self.appInfo.url)
                    didFinish()
                } else {
                    
                    let alertController = UIAlertController(title: "Oops!", message: "You don't have this app installed. Do you want to install it now?", preferredStyle: .Alert)
                    
                    alertController.addAction(UIAlertAction(title: "Yes", style: .Cancel, handler: { (action) -> Void in
                        let itunesUrl = NSURL(string: "http://itunes.apple.com/app/id\(self.appInfo.appId)")!;
                        UIApplication.sharedApplication().openURL(itunesUrl)
                        didFinish()
                    }))
                    
                    alertController.addAction(UIAlertAction(title: "No", style: .Default, handler: { (_) -> Void in
                        didFinish()
                    }))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            #endif
        }
        
        let activityController = UIActivityViewController(activityItems: [self.pageUrl], applicationActivities: [nativeActivity])
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.presentViewController(activityController, animated: true, completion: nil)
        } else {
            let popover = UIPopoverController(contentViewController: activityController)
            popover.presentPopoverFromBarButtonItem(navigationItem.rightBarButtonItem!, permittedArrowDirections: .Any, animated: true)
        }
        
    }
}

