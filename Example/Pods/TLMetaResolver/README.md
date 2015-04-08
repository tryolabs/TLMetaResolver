# TLMetaResolver

[![Version](https://img.shields.io/cocoapods/v/TLMetaResolver.svg?style=flat)](http://cocoadocs.org/docsets/TLMetaResolver)
[![License](https://img.shields.io/cocoapods/l/TLMetaResolver.svg?style=flat)](http://cocoadocs.org/docsets/TLMetaResolver)
[![Platform](https://img.shields.io/cocoapods/p/TLMetaResolver.svg?style=flat)](http://cocoadocs.org/docsets/TLMetaResolver)
[![Laguage](https://img.shields.io/badge/language-Swift-orange.svg)](https://developer.apple.com/swift/)

TLMetaResolver is an extension to UIWebView writen in Swift that adds the ability to parse the meta tags in the loaded web page and extract information about a native app that can be deep linked from that page. This method is used for Twitter and Facebook to deep link to a native app from a posted web page. The meta tags definitions handled for TLMetaResolver are:

- [Twitter App Cards](https://dev.twitter.com/cards/types/app)
- [Facebook App Link](http://applinks.org/documentation/)
- [Apple Smart Banner](https://developer.apple.com/library/ios/documentation/AppleApplications/Reference/SafariWebContent/PromotingAppswithAppBanners/PromotingAppswithAppBanners.html)

## How it works

TLMetaResolver adds a funtion to UIWebView that evaluate a JavaScript script in the context of the loaded web page. This script returns an _app id_ and _url_. The _app id_ is the id of the native app on iTunes, the _url_ is a special url used to fire the native app.

With the _app id_ the extension perform a search on iTunes calling the [iTunes Search API](https://www.apple.com/itunes/affiliates/resources/documentation/itunes-store-web-service-search-api.html) to get the app name and icon url. Then the icon image is downloaded and a TLNativeAppActivity is created and returned to be presented in a UIActivityViewController. When the activity is performed a call to ``UIApplication.sharedApplication().openURL()`` is made with the url pointing to the native app.

## Usage

To use this code you should call one of the ``resolveMetaTags()`` functions once your page is loaded and provide a closure conforming the ``TLMetaResolverComplete`` type. Check the example project for a possible implementation, you can ``pod try TLMetaResolver``.

One key point to remember is that ``webViewDidFinishLoad`` function of UIWebViewDelegate can be called many times so you should handle that case to avoid unnecesary calls to ``resolveMetaTags()``. The extension don't have any check at this level

There are two version of ``resolveMetaTags()`` that have slightly different parameters:

```swift
func resolveMetaTags (onComplete: TLMetaResolverComplete)
```

Both versions has a parameter of type ``TLMetaResolvercomplete`` that is a callback that is fired when the process finish.

```swift
func resolveMetaTags (fetchUrl: TLMetaResolverFetchURL?, _ fetchImage: TLMetaResolverFetchURL?, _ onComplete: TLMetaResolverComplete)
```

The long version has two extra parameters that are closures used to issue the requests to iTunes Search API  (``fetchUrl``)  and the app icon download (``fetchImage``). You can provide the implementation for one of this, both or none (that is the case of the short version of ``resolverMetaTags()``). For the closures you don't provide a default implementation is provided using ``NSURLSession.sharedSession()``.

## Installation

TLMetaResolver is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "TLMetaResolver"

You can also do a quick check with:

    pod try TLMetaResolver

You can always opt to clone the repo and integrate the code and assets under the Pod/ directory to your project as you like.

## Requirements

iOS >= 8.0

## Author

BrunoBerisso, bruno@tryolabs.com

## License

TLMetaResolver is available under the MIT license. See the LICENSE file for more info.

