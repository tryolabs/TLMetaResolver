//
//  FirstViewController.swift
//  TLMetaResolver
//
//  Created by Bruno Berisso on 2/18/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

import UIKit

class FirstViewController: UITableViewController {
    
    private var urlList: [NSURL]!
    private var selectedRow: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBarHidden = true
        
        urlList = [
            "http://swaggy-life.tumblr.com/",
            "http://www.nachorater.com/",
            "http://mrk.tv/",
            "https://medium.com",
            "https://www.kickstarter.com"
        ].map { NSURL(string: $0)! }
        
        let alert = UIAlertController(title: "How it works",
            message: "Select one row to load the given page on a web view in the next screen. Each row has a particular set of meta tags for you to test", preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (a: UIAlertAction!) -> Void in
            alert.dismissViewControllerAnimated(true, completion: .None)
        }))
        
        dispatch_after(1, dispatch_get_main_queue()) { () -> Void in
            self.presentViewController(alert, animated: true, completion: .None)
        }
    }
}


extension FirstViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = indexPath.row
        performSegueWithIdentifier("ShowPageUrl", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let secondController = segue.destinationViewController as! SecondViewController
        secondController.pageUrl = urlList[selectedRow]
    }
}