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
    var session: URLSession
    
    override init() {
        session = URLSession.shared
        super.init()
    }
    
    // MARK: - GET
    
    func taskForGETMethod(_ method: String, parameters: [String : String]? = nil, headerParameters: [String:String]? = nil, completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        //Build the URL and configure the request
        
        let baseMethod = Constants.FoursquareURL
        
        
        var urlString = baseMethod + method
        
        // Add parameters
        
        urlString = parameters != nil ? urlString + Client.escapedParameters(parameters!) : urlString
        let url = URL(string: urlString)!
        let request = NSMutableURLRequest(url: url)
        
        // Make the request
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, downloadError in
            
            // Set up the error (if any)
            
            if let error = downloadError {
                let newError = Client.errorForNetworkConnection(error as NSError)
                completionHandler(nil, newError)
                
            } else {
                
                // Parse data
                if data != nil {
                    Client.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
                }
            }
        }) 
        
        // Start request
        task.resume()
        
        return task
    }
    
    
    func loadImage(_ method: String, parameters: [String : String]? = nil, completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDownloadTask {
        
        //Build the URL and configure the request
        
        let baseMethod = Constants.FoursquareURL
        
        
        var urlString = baseMethod + method
        
        // Add parameters
        
        urlString = parameters != nil ? urlString + Client.escapedParameters(parameters!) : urlString
        
         let imageurl = URL(string: urlString)!

        let downloadtask = session.downloadTask(with: imageurl, completionHandler: {
            url, response, error in
            
            if error == nil && url != nil {
                if let data = try? Data(contentsOf: url!) {
                    completionHandler(data as AnyObject?, nil)
                }
            }
            
        })
        
        return downloadtask
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    
    class func parseJSONWithCompletionHandler(_ data: Data, completionHandler: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var newData: Data = data
        
        var parsingError: NSError? = nil
        do {

       let parsedResult = try JSONSerialization.jsonObject(with: newData, options: JSONSerialization.ReadingOptions.allowFragments)
            completionHandler(parsedResult as AnyObject?, nil)

        }catch {
            let userInfo = [NSLocalizedDescriptionKey : "Internal Error getting data. Please try again later."]
            let newError = NSError(domain: "LetsMeet ParsingError", code: 30, userInfo: userInfo)
            
            completionHandler(nil, newError)
        }
        
//        let parsedResult: AnyObject? = JSONSerialization.JSONObjectWithData(newData, options: JSONSerialization.ReadingOptions.AllowFragments, error: &parsingError)
//        
//        if let error = parsingError {
//            
//            // Set up the domain and code for the error
//            let userInfo = [NSLocalizedDescriptionKey : "Internal Error getting data. Please try again later."]
//            let newError = NSError(domain: "LetsMeet ParsingError", code: 30, userInfo: userInfo)
//            
//            completionHandler(nil, error)
//        } else {
//            completionHandler(parsedResult, nil)
//        }
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(_ parameters: [String : String]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
            //join("&", urlVars)
    }
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    
    class func subtituteKeyInMethod(_ method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        } else {
            return nil
        }
    }
    
    /* Helper: method to return Network error */
    
    class func errorForNetworkConnection(_ error:NSError) -> NSError {
        
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
