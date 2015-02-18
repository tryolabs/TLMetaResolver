//
//  ViewController.swift
//  TLMetaResolver
//
//  Created by Bruno Berisso on 2/12/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    var timer: NSTimer!
    var resolvingMetaTags: Bool!
    var pageUrl: NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resolvingMetaTags = false
        pageUrl = NSURL(string:"http://www.google.com")!
//        pageUrl = NSURL(string:"http://swaggy-life.tumblr.com/")!
//        pageUrl = NSURL(string:"http://www.ted.com/talks/nadine_burke_harris_how_childhood_trauma_affects_health_across_a_lifetime")!
        
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
                    let activityController = UIActivityViewController(activityItems: [self.pageUrl], applicationActivities: [activity!])
                    self.presentViewController(activityController, animated: true, completion: nil)
                }
            })
        }
        
    }
}

