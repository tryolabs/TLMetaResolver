//
//  TLMetaResolver.swift
//  TLMetaResolver
//
//  Created by Bruno Berisso on 2/13/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

import UIKit


/**
    This class is the result of the parsing of the meta tags. It contains the basic info to handle the content on the loaded page:

    - name The name of the app as is in iTunes

    - url The url to open the app on the devices

    - icon The small version of the icon available in iTunes

    This object can be used to create a TLNativeAppActivity that handle the presentation and basic interaction to fire the native app.
*/
public class TLNativeAppInfo: NSObject {
    
    public private(set) var name: String
    public private(set) var appId: String
    public private(set) var url: NSURL
    public private(set) var icon: UIImage
    
    private init(name: String, appId: String, url: NSURL, icon: UIImage) {
        self.name = name
        self.appId = appId
        self.url = url
        self.icon = icon
    }
}


/**
    The closure called when the resolve process complete

    :param: activity An activity instance of TLNativeAppActivity representing the native app declared in the page as able to handle this content
*/
public typealias TLMetaResolverComplete = (TLNativeAppInfo?) -> ()

/**
    The closure called when a fetch operation fail

    :param: error The error object that cause the fetch to fail
*/
public typealias TLMetaResolverFetchError = (NSError?) -> ()

/**
    The closure called when the fetch succeed

    :param: responseData The data resulting of a fetch operation
*/
public typealias TLMetaResolverFetchSuccess = (NSData?) -> ()

/**
    A closure representing a fetch operation.

    :param: url The url to fetch
    :param: successHandler A closure called when the fetch succeed
    :param: errorHandler A closure called when the fetch fail
*/
public typealias TLMetaResolverFetchURL = (NSURL, TLMetaResolverFetchSuccess, TLMetaResolverFetchError) -> ()


//Direct access to the meta tag info JSON returned from the parser and iTunes lookup
private extension NSDictionary {
    
    var url: NSURL {
        let key = "url"
        return NSURL(string:self[key] as! String)!
    }
    
    var appId: String {
        let key = "appId"
        return self[key] as! String
    }
    
    var appName: String {
        let key = "trackName"
        return self[key] as! String
    }
    
    var iconUrl: NSURL {
        let key = "artworkUrl60"
        return NSURL(string: self[key] as! String)!
    }
    
    var firstResult: NSDictionary? {
        let key = "results"
        let resultsList = self[key] as! Array<AnyObject>
        return resultsList.count > 0 ? resultsList[0] as? NSDictionary : nil
    }
}


/**
    This extension add two functions to the UIWebView class that start the process of parsing the information on the meta tags of the loaded html document and return an instance of TLNativeAppActivity or nil.

    The tags are parsed by a JavaScript script loaded from a file and evaluated in the context of the document. This script return an iTunes app id that is used to get the app name and icon from iTunes and an url to open the native app.

    The functions are really one function and one homonymous with less parameters that make the use simpler.

    On every case all the possible error cases are handled. A message is loged to the system with NSLog() and the callback is called with nil.

    Note: this is the documentation for the iTunes Search API https://www.apple.com/itunes/affiliates/resources/documentation/itunes-store-web-service-search-api.html
*/
extension UIWebView {
    
    /**
        Try to resolve the meta tags that follow the "Twitter - App Card", "Facebook - AppLink" or "Apple - Smart Banner" convention on the loaded html document to a TLNativeAppActivity that represent an installed native app capable of handle the current content. To get the native app information (name and icon) a request to iTunes Search API is made using the shared NSURLSession instance.
    
        :param: onComplete A complete handler of type TLMetaResolverComplete that receive as argument an objet of type TLNativeAppActivity?
    */
    @objc public func resolveMetaTags (onComplete: TLMetaResolverComplete) {
        resolveMetaTags(nil, nil, onComplete)
    }
    
    /**
        Try to resolve the meta tags that follow the "Twitter - App Card", "Facebook - AppLink" or "Apple - Smart Banner" convention on the loaded html document to a TLNativeAppActivity that represent an installed native app capable of handle the current content.
    
        :param: fetchUrl An optional closuere that will be called to fetch the native app information from iTunes Search API, if nil is passed the shared NSURLSeesion is used.
        :param: fetchImage An optional closure that will be called to fetch the native app icon from iTunes, if nil is passed the shared NSURLSeesion is used.
        :param: onComplete A complete handler of type TLMetaResolverComplete that receive as argument an objet of type TLNativeAppActivity?
    */
    @objc public func resolveMetaTags (fetchUrl: TLMetaResolverFetchURL?, _ fetchImage: TLMetaResolverFetchURL?, _ onComplete: TLMetaResolverComplete) {
        
        //Get the js parser
        if let parserJs = metaTagsParserJS() {
            
            //run it
            if let metaInfoString = self.stringByEvaluatingJavaScriptFromString(parserJs) {
                
                if metaInfoString == "" {
                    //No meta tags to parse so, silently, return nil
                    onComplete(nil)
                } else {
                    
                    //transform the string result to raw data
                    if let metaInfoData = metaInfoString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) {
                        
                        //get a JSON out of that data
                        do {
                            let metaInfoJSON = try NSJSONSerialization.JSONObjectWithData(metaInfoData, options: NSJSONReadingOptions.AllowFragments)

                            //Try to fit it in a dictionary
                            if let metaInfo = metaInfoJSON as? NSDictionary {
                                var fetchUrlImp: TLMetaResolverFetchURL
                                var fetchImageImp: TLMetaResolverFetchURL

                                //Check if a custom implementation of the 'fetch' closures was provide, if not set the default one
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

                                //Try to create the activity
                                createActivityWithInfo(metaInfo, fetchUrlImp, fetchImageImp, onComplete)

                            } else {
                                NSLog("Malformed JSON, can't read it as a Dictionary")
                                onComplete(nil)
                            }
                        } catch let error as NSError {
                            NSLog("Can't parse meta info json: %@", error.localizedDescription)
                            onComplete(nil)
                        }
                        
                    } else {
                        NSLog("Can't parse meta info string")
                        onComplete(nil)
                    }
                }
                
            } else {
                NSLog("Parser script crash for some reason")
                onComplete(nil)
            }
        } else {
            //Don't log anything because it is handled on the 'metaTagsParserJS' function
            onComplete(nil)
        }
    }
    
    /**
        Return the JavaScript script to be evaluated on the context of the loaded document to parse the meta tags. On success the script return a JSON dictionary with two keys:
    
        - appId: The Apple app id with the native app is registered in iTunes
        - url: The url to open the native app
    
        :returns: A optional string containing the script or nil if somthing go wrong
    */
    private func metaTagsParserJS () -> String? {
        
        if let parserPath = NSBundle.metaResolverBundle()?.pathForResource("TLMetaParser", ofType: "js") {
            do {
                let parserJs = try String(contentsOfFile: parserPath, encoding: NSUTF8StringEncoding)
                //The script 'main' function receives as argument wether we are running on an iPad or iPhone to choose the correct meta tags
                let isIPad = UIDevice.currentDevice().userInterfaceIdiom == .Phone ? "false" : "true"
                return parserJs + ";parseMetaTags(\(isIPad))"
            } catch let error as NSError {
                NSLog("Can't get parser content: %@", error.localizedDescription)
                return nil
            }
        } else {
            NSLog("Can't find the JavaScript file")
            return nil
        }
    }
    
    /**
        Return the default implementation for fething any URL.
    */
    private func defatulFetchUrl () -> (TLMetaResolverFetchURL) {
        return {
            (url: NSURL, successHandler: TLMetaResolverFetchSuccess, errorHandler: TLMetaResolverFetchError) -> () in
            
            NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: {
                (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                
                if (error == nil) {
                    successHandler(data)
                } else {
                    errorHandler(error)
                }
            }).resume()
            
        }
    }
    
    /**
        Return the default implementation for fetching any image. If the resulting data can't be parsed to a valid UIImage create a NSError object and pass it to the errorHandler closure
    */
    private func defaultFetchImage () -> (TLMetaResolverFetchURL) {
        return {
            (url: NSURL, successHandler: TLMetaResolverFetchSuccess, errorHandler: TLMetaResolverFetchError) -> () in
            
            NSURLSession.sharedSession().downloadTaskWithURL(url, completionHandler: {
                (location: NSURL?, response: NSURLResponse?, error: NSError?) -> Void in

                guard error == nil else {
                    errorHandler(error!)
                    return
                }

                guard let location = location else {
                    let error = NSError(domain: "TLMetaResolver", code: 1, userInfo: [NSLocalizedDescriptionKey: "No temp file to read from."])
                    errorHandler(error)
                    return
                }

                guard let data = NSData(contentsOfURL: location) else {
                    let error = NSError(domain: "TLMetaResolver", code: 1, userInfo: [NSLocalizedDescriptionKey: "Can't read temp file at url: \(location)"])
                    errorHandler(error)
                    return
                }

                successHandler(data)

            }).resume()
        }
    }
    
    /**
        Create the TLNativeAppActivity with the information extracted form the meta tags. This function perform the calls to iTunes Search API and download the image to be used. On success the 'onComplete' closure is called with the created TLNativeAppActivity or nil if it fail.
    */
    private func createActivityWithInfo(appInfo: NSDictionary, _ fetchUrl: TLMetaResolverFetchURL, _ fetchImage: TLMetaResolverFetchURL, _ onComplete: TLMetaResolverComplete) {
        
        let itunesUrl = NSURL(string: "https://itunes.apple.com/lookup?id=\(appInfo.appId)")!
        
        fetchUrl(itunesUrl, {
            //Fetch success handler
            (data: NSData?) -> () in

            guard let data = data else {
                NSLog("No data provided.")
                return
            }

            //get a JSON out of that data
            do {
                let itunesInfoJSON: AnyObject? = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)

                if let itunesResults = itunesInfoJSON as? NSDictionary {
                    //The response from iTunes is a list of matching records, because we search for app id is safe to pick the first one in the list if ther are any results.
                    if let itunesAppInfo = itunesResults.firstResult {
                        fetchImage(itunesAppInfo.iconUrl, {
                            //Fetch image success handler
                            (data: NSData?) -> () in

                            if let data = data, let image = UIImage(data: data) {
                                let nativeAppInfo = TLNativeAppInfo(name: itunesAppInfo.appName, appId: appInfo.appId, url: appInfo.url, icon: image)
                                self.performOnMain { onComplete(nativeAppInfo) }
                            } else {
                                NSLog("Can't parse image data or it's not a valid image")
                                self.performOnMain { onComplete(nil) }
                            }

                        }, {
                            //Fetch image error hanlder
                            (error: NSError?) -> () in

                            NSLog("Can't fetch image" + (error.map { ": " + $0.description } ?? "") + ".")
                            self.performOnMain { onComplete(nil) }
                        })
                    } else {
                        NSLog("Can't find the provided app id on iTunes: %@", appInfo.appId)
                        self.performOnMain { onComplete(nil) }
                    }

                } else {
                    NSLog("Bad response form iTunes, object is not a dictionary")
                    self.performOnMain { onComplete(nil) }
                }
            } catch let error as NSError {
                NSLog("Can't parse iTunes response: %@", error.description)
                self.performOnMain { onComplete(nil) }
            }
        }, {
            //Fetch error handler
            (error: NSError?) -> () in

            NSLog("Can't get info from iTunes" + (error.map { ": " + $0.description } ?? "") + ".")
            self.performOnMain { onComplete(nil) }
        })
    }
    
    func performOnMain (closure: () -> ()) {
        dispatch_async(dispatch_get_main_queue(), closure)
    }
}
