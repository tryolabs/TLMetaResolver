//
//  TLNativeAppActivity.swift
//  TLMetaResolver
//
//  Created by Bruno Berisso on 2/13/15.
//  Copyright (c) 2015 Bruno Berisso. All rights reserved.
//

import Foundation
import UIKit


class TLNativeAppActivity: UIActivity {
    
    var url: NSURL
    var name: String
    var icon: UIImage
    
    init(appUrl: NSURL, applicationName appName: String, andIcon appIcon: UIImage) {
        url = appUrl
        name = appName
        
        let scale: CGFloat = UIDevice.currentDevice().userInterfaceIdiom == .Phone ? 60 : 76
        let scaledGrayImage = appIcon.imageByScaleToSize(CGSizeMake(scale, scale)).convertToGrayscale()
        let iconMask = UIImage(named: "iconMask")!
        icon = scaledGrayImage.imageByApplyingMask(iconMask)
    }
    
    func _activityImage() -> UIImage? {
        return icon
    }
    
    override func activityType() -> String? {
        return "open.\(name)"
    }
    
    override func activityTitle() -> String? {
        return "Open in \(name)"
    }
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        return true
    }
    
    override func performActivity() {
        UIApplication.sharedApplication().openURL(url)
        activityDidFinish(true)
    }
}

extension UIImage {
    
    func imageByApplyingMask (maskImage: UIImage) -> (UIImage) {
        
        let maskRef = maskImage.CGImage
        let mask = CGImageMaskCreate(
            CGImageGetWidth(maskRef),
            CGImageGetHeight(maskRef),
            CGImageGetBitsPerComponent(maskRef),
            CGImageGetBitsPerPixel(maskRef),
            CGImageGetBytesPerRow(maskRef),
            CGImageGetDataProvider(maskRef), nil, false)
        
        let maskedImageRef = CGImageCreateWithMask(CGImage, mask)
        let scale = UIScreen.mainScreen().scale
        let maskedImage = UIImage(CGImage: maskedImageRef, scale: scale, orientation: .Up)!
        
        return maskedImage
    }
    
    func imageByScaleToSize (newSize: CGSize) -> (UIImage) {
        //UIGraphicsBeginImageContext(newSize);
        // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
        // Pass 1.0 to force exact pixel size.
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
    
    func convertToGrayscale () -> (UIImage) {
        UIGraphicsBeginImageContextWithOptions(size, false, scale);
        let imageRect = CGRectMake(0, 0, size.width, size.height);
        
        let ctx = UIGraphicsGetCurrentContext();
        
        // Draw a white background
        CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
        CGContextFillRect(ctx, imageRect);
        
        // Draw the luminosity on top of the white background to get grayscale
        drawInRect(imageRect, blendMode: kCGBlendModeLuminosity, alpha: 1.0)
        
        // Apply the source image's alpha
        drawInRect(imageRect, blendMode: kCGBlendModeDestinationIn, alpha: 1.0)
        
        let grayscaleImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return grayscaleImage;
    }
    
}