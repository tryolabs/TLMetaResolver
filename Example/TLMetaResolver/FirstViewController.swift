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
            "http://www.google.com",
            "http://swaggy-life.tumblr.com/",
            "https://vimeo.com/channels/staffpicks/117770305",
            "http://www.nachorater.com/",
            "https://www.flickr.com/photos/godo70/16557550262/in/explore-2015-02-17"
        ].map { NSURL(string: $0)! }
        
        let alert = UIAlertController(title: "How it works",
            message: "Select one row to load the given page on a web view in the next screen. Each row has a particular set of meta tags for you to test", preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (a: UIAlertAction!) -> Void in
            alert.dismissViewControllerAnimated(true, completion: .None)
        }))
        
        dispatch_after(1, dispatch_get_main_queue()) { () -> Void in
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
}


extension FirstViewController: UITableViewDelegate {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = indexPath.row
        performSegueWithIdentifier("ShowPageUrl", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let secondController = segue.destinationViewController as SecondViewController
        secondController.pageUrl = urlList[selectedRow]
    }
}