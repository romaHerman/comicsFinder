//
//  ComicsController.swift
//  ComicsFinder
//
//  Created by Roma on 11/10/14.
//  Copyright (c) 2014 Roma. All rights reserved.
//

import Foundation

protocol ComicsControllerDelegate {
  func comicsDataDidUpdated(comicsArray: Array<Comic>, favouritesArray:Array<Comic>)
}

class ComicsModel: NSObject {
  
  var comicsArray:[Comic] = [ ]
  var staredComicsArray:[Comic] = [ ]
  var currentPage = -1
  
  var comicsIDArray: Array<AnyObject> = []
  
  var delegate:ComicsControllerDelegate?
  
  func updateComicsData() {
    getFavouriteComicIds { (response) -> Void in
      self.comicsIDArray = response
      self.comicsIDArray.reverse()
      self.loadNextPage()
      self.loadFavouritesComics(self.comicsIDArray)
    }
  }
  
  func loadNextPage() {
    currentPage++
    loadComicsForPage(currentPage, completionHandler: { (response) -> Void in
      let unfilteredArray = response as [Comic]
      let filteredArray = self.getFilteredFromFavouritesArray(unfilteredArray)
      self.comicsArray += filteredArray
      self.delegate?.comicsDataDidUpdated(self.comicsArray, favouritesArray: self.staredComicsArray)
    })
  }
  
  func loadFavouritesComics(var favouriteIDArr: Array<AnyObject>) {
    if favouriteIDArr.count > 0 {
      let comicFetcher = ComicsRemoteFetcher()
      comicFetcher.getComicByID(favouriteIDArr.last as NSString, complitionHamdler: { (comic) -> Void in
        self.staredComicsArray.append(comic)
        if self.staredComicsArray.count % 5 == 0 {
          self.delegate?.comicsDataDidUpdated(self.comicsArray, favouritesArray: self.staredComicsArray)
        }
        if favouriteIDArr.count > 0 {
          favouriteIDArr.removeLast()
          self.loadFavouritesComics(favouriteIDArr)
        }
      })
    } else {
      self.delegate?.comicsDataDidUpdated(self.comicsArray, favouritesArray: self.staredComicsArray)
    }
  }
  
  func favouritesLoaded(starred: Array<Comic>) {
    self.staredComicsArray = starred
    self.delegate?.comicsDataDidUpdated(self.comicsArray, favouritesArray: self.staredComicsArray)
  }
  
  func getFilteredFromFavouritesArray(generalArray: Array<Comic>) -> Array<Comic> {
    var filteredArray: [Comic] = []
    for comic in generalArray {
      if isComicInFavourites(comic) == false {
        filteredArray.append(comic)
      }
    }
    
    return filteredArray
  }
  
  func isComicInFavourites(comic: Comic) -> Bool {
    for comicID in comicsIDArray {
      let comicIDInt = comicID.integerValue
      if  comicIDInt == comic.comicID {
        return true
      }
    }
    
    return false
  }
  
  func loadComicsForPage(page: Int, completionHandler handler: (response:AnyObject!) -> Void) {
    let comicFetcher = ComicsRemoteFetcher()
    comicFetcher.getComcis(page, completionHandler: { (response) -> Void in
      handler(response: response)
    })
  }
  
  func addComicToFavourite(staredComic:Comic) {
    CognitoComicsFinder.sharedInstance.addFavouriteComic(staredComic.title!, comicID: String(staredComic.comicID!))
  }
  
  func getFavouriteComicIds(completion handler: (response:Array<AnyObject>!) -> Void) {
    CognitoComicsFinder.sharedInstance.getFavouritesDictionary { (response) -> Void in
      let comicIDs = response.allKeys
      handler(response: comicIDs)
    }
  }
  
  func updatingFavourites() -> Bool {
    if comicsIDArray.count > 0 && staredComicsArray.count == 0 {
      return true
    }
    return false
  }
  
  func allFavouritesLoaded() -> Bool {
    if comicsIDArray.count == staredComicsArray.count {
      return true
    }
    return false
  }
  
}
