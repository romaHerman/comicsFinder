//
//  Comic.swift
//  ComicsFinder
//
//  Created by Roma on 11/6/14.
//  Copyright (c) 2014 Roma. All rights reserved.
//

/*

standard_small	65x45px
standard_medium	100x100px
standard_large	140x140px
standard_xlarge	200x200px
standard_fantastic	250x250px
standard_amazing	180x180px

*/

enum CoverSize: String {
    case CoverSizeSmall = "standard_small"
    case CoverSizeMedium = "standard_medium"
    case CoverSizeLarge = "standard_large"
    case CoverSizeXlarge = "standard_xlarge"
    case CoverSizeFantastic = "standard_fantastic"
    case CoverSizeAmazing = "standard_amazing"
    case CoverSizeLandscape = "landscape_incredible"
}

import Foundation

class Comic {
    
    let comicID: Int?
    let title: String?
    let detailsURLString: String?
    let onSaleDate: String?
    let description: String?
    let price: Float?
    let coverImageURLString: String?
    let imageExtention: String?
    
    init(rawDicitonary:Dictionary<String, AnyObject>) {
        let t: AnyObject? = rawDicitonary["id"]
        self.comicID = rawDicitonary["id"] as? Int
        self.title = rawDicitonary["title"] as? String
        self.description = rawDicitonary["description"] as? String 
       
        let urls = rawDicitonary["urls"] as? Array<Dictionary<String, String>>
        let urlItem = urls?.first
        self.detailsURLString = urlItem?["url"]
        
        let dates = rawDicitonary["dates"] as? Array<Dictionary<String, String>>
        let onSaleDatDictionary = dates?.first
        self.onSaleDate = onSaleDatDictionary?["date"]
        
        let prices = rawDicitonary["prices"] as? Array<Dictionary<String, AnyObject>>
        let priceDictionary = prices?.first
        self.price = priceDictionary?["price"] as? Float
        
        let thumbNails = rawDicitonary["thumbnail"] as? Dictionary<String, String>
        self.coverImageURLString = thumbNails?["path"]
        self.imageExtention = thumbNails?["extension"]
    }
    
    func getCoverUrlForSize(size:CoverSize) -> String {
        let sizeString:String = size.rawValue
        let urlString = "\(coverImageURLString!)/\(sizeString).\(imageExtention!)"
        return urlString
    }
    
}
