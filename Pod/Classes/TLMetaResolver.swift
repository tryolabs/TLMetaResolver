//
//  TLMetaResolver.swift
//  TLMetaResolver
//
//  Created by Bruno Berisso on 2/13/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

import Foundation
import UIKit


typealias TLMetaResolverComplete = (([TLNativeAppActivity]) -> ())

typealias TLMetaResolverFetchURL = (NSURL) -> (NSData);


extension UIWebView {
    
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
    
    func resolveMetaTags (onComplete: TLMetaResolverComplete) {
        resolveMetaTags({ (url: NSURL) -> (NSData) in
            return NSData()
        }, onComplete: onComplete)
    }
    
    func resolveMetaTags (fetchUrl: TLMetaResolverFetchURL, onComplete: TLMetaResolverComplete) {
        
        if let parserJs = metaTagsParserJS() {
            
            if let metaInfoString = self.stringByEvaluatingJavaScriptFromString(parserJs) {
                
                if let metaInfoData = metaInfoString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) {
                    
                    var error: NSError?
                    let metaInfo: AnyObject? = NSJSONSerialization.JSONObjectWithData(metaInfoData, options: NSJSONReadingOptions.AllowFragments, error: &error)
                    
                    if (error == nil) {
                        
                        if let metaInfo = metaInfo as? NSDictionary {
                            println(metaInfo)
                        }
                        
                    } else {
                        NSLog("Can't parse meta info json: %@", error!.localizedDescription)
                        onComplete([])
                    }
                    
                } else {
                    NSLog("Can't parse meta info string")
                    onComplete([])
                }
                
            } else {
                onComplete([])
            }
        }
        
    }
}






