//
//  TLMetaResolver.swift
//  TLMetaResolver
//
//  Created by Bruno Berisso on 2/13/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

import Foundation
import UIKit


typealias TLMetaResolverComplete = ((TLNativeAppActivity?) -> ())

typealias TLMetaResolverFetchError = (NSError) -> ()
typealias TLMetaResolverFetchSuccess = (NSData) -> ()
typealias TLMetaResolverFetchURL = (NSURL, TLMetaResolverFetchSuccess, TLMetaResolverFetchError) -> ()


//Direct access to the meta tag info JSON returned from the parser and iTunes lookup
private extension NSDictionary {
    
    var url: NSURL {
        let key = "url"
        return NSURL(string:self[key] as String)!
    }
    
    var appId: String {
        let key = "appId"
        return self[key] as String
    }
    
    var appName: String {
        let key = "trackName"
        return self[key] as String
    }
    
    var iconUrl: NSURL {
        let key = "artworkUrl60"
        return NSURL(string: self[key] as String)!
    }
    
    var firstResult: NSDictionary {
        let key = "results"
        let resultsList = self[key] as Array<AnyObject>
        return resultsList[0] as NSDictionary
    }
}


extension UIWebView {
    
    func resolveMetaTags () {
        resolveMetaTags { (activity: TLNativeAppActivity?) -> () in
            print("Resolve complete: ")
            println(activity)
        }
    }
    
    func resolveMetaTags (onComplete: TLMetaResolverComplete) {
        
        let fetchUrl = defatulFetchUrl()
        let fetchImage = defaultFetchImage()
        
        resolveMetaTags(fetchUrl, fetchImage, onComplete)
    }
    
    func resolveMetaTags (fetchUrl: TLMetaResolverFetchURL?, _ fetchImage: TLMetaResolverFetchURL?, _ onComplete: TLMetaResolverComplete) {
        
        //Get the js parser
        if let parserJs = metaTagsParserJS() {
            
            //run it
            if let metaInfoString = self.stringByEvaluatingJavaScriptFromString(parserJs) {
                
                //transform the string result to raw data
                if let metaInfoData = metaInfoString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) {
                    
                    //get a JSON out of that data
                    var error: NSError?
                    let metaInfoJSON: AnyObject? = NSJSONSerialization.JSONObjectWithData(metaInfoData, options: NSJSONReadingOptions.AllowFragments, error: &error)
                    
                    if (error == nil) {
                        
                        //Try to fit it in a dictionary
                        if let metaInfo = metaInfoJSON as? NSDictionary {
                            
                            //Try to create the activity
                            var fetchUrlImp: TLMetaResolverFetchURL
                            var fetchImageImp: TLMetaResolverFetchURL
                            
                            if (fetchUrl == nil) {
                                fetchUrlImp = defatulFetchUrl()
                            } else {
                                fetchUrlImp = fetchUrl!
                            }
                            
                            if (fetchImage == nil) {
                                fetchImageImp = defaultFetchImage()
                            } else {
                                fetchImageImp = fetchImage!
                            }
                            
                            createActivityWithInfo(metaInfo, fetchUrlImp, fetchImageImp, onComplete)
                            
                        } else {
                            NSLog("Malformed JSON, can't read it as a Dictionary")
                            onComplete(nil)
                        }
                        
                    } else {
                        NSLog("Can't parse meta info json: %@", error!.localizedDescription)
                        onComplete(nil)
                    }
                    
                } else {
                    NSLog("Can't parse meta info string")
                    onComplete(nil)
                }
                
            } else {
                onComplete(nil)
            }
        } else {
            onComplete(nil)
        }
    }
    
    private func metaTagsParserJS () -> String? {
        let isIPad = UIDevice.currentDevice().userInterfaceIdiom == .Phone ? "false" : "true"
        
        if let parserPath = NSBundle.mainBundle().pathForResource("TLMetaParser", ofType: "js") {
            
            var error: NSError?
            let parserJs = String(contentsOfFile: parserPath, encoding: NSUTF8StringEncoding, error: &error)
            
            if (error != nil || parserJs == nil) {
                NSLog("Can't get parser content: %@", error!.localizedDescription)
                return nil
            } else {
                return parserJs! + ";parseMetaTags(\(isIPad))"
            }
            
        } else {
            return nil
        }
    }
    
    private func defatulFetchUrl () -> (TLMetaResolverFetchURL) {
        return {
            (url: NSURL, successHandler: TLMetaResolverFetchSuccess, errorHandler: TLMetaResolverFetchError) -> () in
            
            NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: {
                (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
                
                if (error == nil) {
                    successHandler(data)
                } else {
                    errorHandler(error)
                }
            }).resume()
            
        }
    }
    
    private func defaultFetchImage () -> (TLMetaResolverFetchURL) {
        return {
            (url: NSURL, successHandler: TLMetaResolverFetchSuccess, errorHandler: TLMetaResolverFetchError) -> () in
            
            NSURLSession.sharedSession().downloadTaskWithURL(url, completionHandler: {
                (location: NSURL!, response: NSURLResponse!, error: NSError!) -> Void in
                
                if (error == nil) {
                    if let data = NSData(contentsOfURL: location) {
                        successHandler(data)
                    } else {
                        let error = NSError(domain: "TLMetaResolver", code: 1, userInfo: [NSLocalizedDescriptionKey: "Can't read temp file at url: \(location)"])
                        errorHandler(error)
                    }
                    
                } else {
                    errorHandler(error)
                }
            }).resume()
        }
    }
    
    private func createActivityWithInfo(appInfo: NSDictionary, _ fetchUrl: TLMetaResolverFetchURL, _ fetchImage: TLMetaResolverFetchURL, _ onComplete: TLMetaResolverComplete) {
        
        //If the app is installed
        if (true || UIApplication.sharedApplication().canOpenURL(appInfo.url)) {
            
            let itunesUrl = NSURL(string: "https://itunes.apple.com/lookup?id=\(appInfo.appId)")!
            fetchUrl(itunesUrl, {
                (data: NSData) -> () in
                
                //get a JSON out of that data
                var error: NSError?
                let itunesInfoJSON: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &error)
                
                if (error == nil) {
                    
                    if let itunesResults = itunesInfoJSON as? NSDictionary {
                        
                        let itunesAppInfo = itunesResults.firstResult
                        
                        fetchImage(itunesAppInfo.iconUrl, {
                            (data: NSData) -> () in
                            
                            let image = UIImage(data: data)
                            let activity = TLNativeAppActivity()
                            onComplete(activity)
                            
                        }, {
                            (error: NSError) -> () in
                            NSLog("Can't fetch image: %@", error.description)
                            onComplete(nil)
                        })
                        
                    } else {
                        NSLog("Bad response form iTunes, object is not a dictionary")
                        onComplete(nil)
                    }
                    
                } else {
                    NSLog("Can't parse iTunes response: %@", error!.description)
                    onComplete(nil)
                }
                
            }, {
                (error: NSError) -> () in
                
                NSLog("Can't get info from iTunes: %@", error.description)
                onComplete(nil)
            })
            
        } else {
            onComplete(nil)
        }
    }
}






