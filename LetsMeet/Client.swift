//
//  Client.swift
//  LetsMeet
//
//  Created by Shruti  on 22/08/15.
//  Copyright (c) 2015 Shrutic. All rights reserved.
//

import Foundation

class Client : NSObject {
    
    /* Shared session */
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: - GET
    
    func taskForGETMethod(method: String, parameters: [String : AnyObject]? = nil, headerParameters: [String:String]? = nil, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        //Build the URL and configure the request
        
        let baseMethod = Constants.FoursquareURL
        
        
        var urlString = baseMethod + method
        
        // Add parameters
        
        urlString = parameters != nil ? urlString + Client.escapedParameters(parameters!) : urlString
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        // Make the request
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            // Set up the error (if any)
            
            if let error = downloadError {
                let newError = Client.errorForNetworkConnection(error)
                completionHandler(result: nil, error: newError)
                
            } else {
                
                // Parse data
                if data != nil {
                    Client.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
                }
            }
        }
        
        // Start request
        task.resume()
        
        return task
    }
    
    
    func loadImage(method: String, parameters: [String : AnyObject]? = nil, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDownloadTask {
        
        //Build the URL and configure the request
        
        let baseMethod = Constants.FoursquareURL
        
        
        var urlString = baseMethod + method
        
        // Add parameters
        
        urlString = parameters != nil ? urlString + Client.escapedParameters(parameters!) : urlString
        
         let imageurl = NSURL(string: urlString)!

        let downloadtask = session.downloadTaskWithURL(imageurl, completionHandler: {
            url, response, error in
            
            if error == nil && url != nil {
                if let data = NSData(contentsOfURL: url!) {
                    completionHandler(result: data, error: nil)
                }
            }
            
        })
        
        return downloadtask
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var newData: NSData = data
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
        if let error = parsingError {
            
            // Set up the domain and code for the error
            let userInfo = [NSLocalizedDescriptionKey : "Internal Error getting data. Please try again later."]
            let newError = NSError(domain: "LetsMeet ParsingError", code: 30, userInfo: userInfo)
            
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    /* Helper: method to return Network error */
    
    class func errorForNetworkConnection(error:NSError) -> NSError {
        
        let userInfo = [NSLocalizedDescriptionKey : error.localizedDescription]
        // Set the domain and code for the errro
        return  NSError(domain: "LetsMeet NetworkError", code: 10, userInfo: userInfo)
    }
    
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> Client {
        
        struct Singleton {
            static var sharedInstance = Client()
            
        }
        
        return Singleton.sharedInstance
    }
    

}
