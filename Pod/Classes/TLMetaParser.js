
//Returns a JSON string with the fields:
//- url. The url to open the native app
//- appId. The Apple id of the native app
//
//The information in the JSON corresponds to the first provider found. This means that if the page provides information for Twitter, Facebook and Apple Smart Banner.
//The first combination of 'url' and 'app id' found is the one returned. The format of the information vary from one provider to another.
//Twitter use several meta tags indentified by the 'name' attribute and with the 'content' attribute set to the corresponding value.
//Facebook (AppLink) use a similar approach but use the 'property' attribute instead of the 'name'.
//Apple Smart Banner use the 'name' attribute to indentify the meta tag and put all the information on the 'content' attribute instead of having multiple tags.

function parseMetaTags(isIPad) {
    
    var metaTags = document.getElementsByTagName('meta');
    var device = isIPad ? 'ipad' : 'iphone';
    
    var metaInfo = {};
    
    //iterate over all the 'meta' tags in the page
    for (var i = 0; i < metaTags.length; i++) {
        
        var url = null;
        var appId = null;
        var property = metaTags[i].getAttribute('property');
        
        //check if it is a Facebook meta tag (AppLink) reading the 'property' attribute
        if (property && property.substring(0, 'al:'.length) === 'al:') {
            
            if (!url && (property === 'al:ios:url' || property === 'al:' + device + ':url'))
                url = metaTags[i].getAttribute('content');
            if (!appId && (property === 'al:ios:app_store_id' || property === 'al:' + device + ':app_store_id'))
                appId = metaTags[i].getAttribute('content');
            
        } else {
            
            var meta_name = metaTags[i].getAttribute('name');
            
            //check if it is a Apple Smart Banner meta tag
            if (meta_name && meta_name === 'apple-itunes-app') {
                
                var content_string = metaTags[i].getAttribute('content');
                if (content_string) {
                    
                    //this tag has all the values encoded in the 'content' attribute so the parsing for this values is in other function.
                    var appleMetaInfo = parseAppleMetaTag(content_string);
                    if (appleMetaInfo.url && appleMetaInfo.appId)
                        metaInfo = appleMetaInfo;
                }
            
            //Check if it is a Twitter meta tag.
            } else if (!url && meta_name === 'twitter:app:url:' + device) {
                url = metaTags[i].getAttribute('content');
            } else if (!url && meta_name === 'twitter:app:id:' + device) {
                appId = metaTags[i].getAttribute('content');
            }
        }
        
        if (url && !metaInfo.url)
            metaInfo.url = url;
        if (appId && !metaInfo.appId)
            metaInfo.appId = appId;
        
        //Once we get a complete value, break the loop and return it
        if (metaInfo.url && metaInfo.appId)
            break;
    }
    
    return JSON.stringify(metaInfo);
}

function parseAppleMetaTag(metaTagContent) {
    
    var tokens = metaTagContent.split(',');
    var metaInfo = {};
    
    for (var i = 0; i < tokens.length; i++) {
        
        var token = tokens[i];
        if (token.indexOf('app-id') == 0) {
            metaInfo.appId = token.substring(token.indexOf('=') + 1);
        } else {
            if (token.indexOf('app-argument') == 0)
                metaInfo.url = token.substring(token.indexOf('=') + 1);
        }
    }
    
    return metaInfo;
}