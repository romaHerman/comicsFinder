//
//  UIImageAsyncLoadExtension.swift
//  ComicsFinder
//
//  Created by Roma on 11/7/14.
//  Copyright (c) 2014 Roma. All rights reserved.
//
import Foundation
import UIKit

extension UIImageView {
    func asyncSetImageFromURL(imageURL: NSURL) {
        //self.currentImage = currentImage
        var dataImage:NSData?
        var request: NSURLRequest = NSURLRequest(URL: imageURL,
            cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad,
            timeoutInterval: 30)
        var urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)!
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
            if !(error? != nil) {
                self.image = UIImage(data: data)
            }
            else {
                println("Error: \(error.localizedDescription)")
            }
        })
    }
}
