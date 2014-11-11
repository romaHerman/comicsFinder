//
//  ComicsRemoteFetcher.swift
//  ComicsFinder
//
//  Created by Roma on 11/5/14.
//  Copyright (c) 2014 Roma. All rights reserved.
//

import Foundation

let MarvelPrivateKey = "510c07af1ac25128911add425f90cd917238e9c7"
let MarvelPublicKey = "6ef899b66a9b8530c5fa481f3e013131"
let ComicsPerPage = 20
let BaseUrl = "http://gateway.marvel.com/v1/public/comics"

class ComicsRemoteFetcher: NSObject {
    let queue = NSOperationQueue()
//MARK: RequestOperations
    func getComcis(page: Int, completionHandler handler: (response:AnyObject!) -> Void) {
        
        let offset = ComicsPerPage * page
        
        let timeStampString = getTimeStamp()
        let hash = getHash(timeStampString)
        let urlString = "\(BaseUrl)?format=comic&formatType=comic&limit=\(ComicsPerPage)&offset=\(offset)&apikey=\(MarvelPublicKey)&ts=\(timeStampString)&hash=\(hash)"

        let urlReq = NSURLRequest(URL: NSURL(string: urlString)!)
       
        NSURLConnection.sendAsynchronousRequest(urlReq, queue: queue, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if !(error != nil)  {
                let jsonResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
                let jsonDict = jsonResult as? NSDictionary
                let rawData: AnyObject? = jsonDict?.objectForKey("data")
                let rawComicsData:Array<Dictionary<String,AnyObject>> = rawData?.objectForKey("results") as Array<Dictionary<String, AnyObject>>
                var comicsArray: [Comic] = [ ]
                for rawComic in rawComicsData {
                    let comic = Comic(rawDicitonary: rawComic)
                    comicsArray.append(comic)
                }
                
                handler(response: comicsArray)
            } else {
                println("error = \(error)")
            }
        })
    }
    
    func getComicByID(comicID: String, complitionHamdler handler: (comic: Comic!) -> Void) {
        let timeStampString = getTimeStamp()
        let hash = getHash(timeStampString)
        let urlString = "\(BaseUrl)/\(comicID)?apikey=\(MarvelPublicKey)&ts=\(timeStampString)&hash=\(hash)"
        
        let urlReq = NSURLRequest(URL: NSURL(string: urlString)!)
        
        NSURLConnection.sendAsynchronousRequest(urlReq, queue: queue, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if !(error != nil)  {
                let jsonResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil)
                let jsonDict = jsonResult as? NSDictionary
                let rawData: AnyObject? = jsonDict?.objectForKey("data")
                let rawComicsData:Array<Dictionary<String,AnyObject>> = rawData?.objectForKey("results") as Array<Dictionary<String, AnyObject>>
                
                let rawComic = rawComicsData.first
                let comic = Comic(rawDicitonary: rawComic!)
                handler(comic: comic)
            } else {
                println("error = \(error)")
            }
        })
    }
    
//MARK: Helper functions
    func getTimeStamp() -> String {
        return "\(Int(NSDate().timeIntervalSince1970))"
    }
    
    func getHash(timestampString:String) -> String {
        //hash origin formula = md5(ts+privateKey+publicKey)
        let formula = timestampString + MarvelPrivateKey + MarvelPublicKey
        return "\(formula.md5)"
    }
}
