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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.loadRequest(NSURLRequest(URL: NSURL(string:"http://swaggy-life.tumblr.com/")!))
//        webView.loadRequest(NSURLRequest(URL: NSURL(string:"http://www.ted.com/talks/nadine_burke_harris_how_childhood_trauma_affects_health_across_a_lifetime")!))
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        if (timer != nil) {
            timer.invalidate()
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: webView, selector: Selector("resolveMetaTags"), userInfo: nil, repeats: false)
    }
}

