//
//  TLBundleExtension.swift
//  TLMetaResolver
//
//  Created by Bruno Berisso on 3/19/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

import Foundation


extension NSBundle {
    
    //This class is used only to get the bundle for the framework, in the case that we are running in one.
    private class InnerClass {}
    
    class func metaResolverBundle () -> NSBundle? {
        
        if let useAppBundle = NSProcessInfo.processInfo().environment["use_app_bundle"] as? String where useAppBundle == "YES" {
            return NSBundle.mainBundle()
        } else {
            if let bundlePath = NSBundle(forClass: InnerClass.self).pathForResource("TLMetaResolver", ofType: "bundle") {
                return NSBundle(path: bundlePath)
            } else {
                return nil
            }
        }
    }
    
}
