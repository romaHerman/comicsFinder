//
//  AmazonCognitoManager.swift
//  ComicsFinder
//
//  Created by Roma on 11/9/14.
//  Copyright (c) 2014 Roma. All rights reserved.
//

import Foundation

let CognitoAccountID = "806272694826"
let IdentityPoolID = "us-east-1:6afe4ace-6d03-49a0-9a04-56efe8e3c1b6"
let UnauthRoleArn = "arn:aws:iam::806272694826:role/Cognito_ComicsFeedUnauth_DefaultRole"
let AuthRoleArn = "arn:aws:iam::806272694826:role/Cognito_ComicsFeedAuth_DefaultRole"

let FavouritesComisDataSetName = "favouriteComicsDataset"

class CognitoComicsFinder: NSObject {
  
  class var sharedInstance: CognitoComicsFinder {
    struct Static {
      static var instance: CognitoComicsFinder?
      static var token: dispatch_once_t = 0
    }
    
    dispatch_once(&Static.token) {
      Static.instance = CognitoComicsFinder()
    }
    
    return Static.instance!
  }
  
  func createNewOrUpdateIdentityInPool() {
    // authorize in cognito with credentials
    let credentialsProvider = AWSCognitoCredentialsProvider.credentialsWithRegionType(
      AWSRegionType.USEast1,
      accountId: CognitoAccountID,
      identityPoolId: IdentityPoolID,
      unauthRoleArn: UnauthRoleArn,
      authRoleArn: AuthRoleArn)
    
    let defaultServiceConfiguration = AWSServiceConfiguration(
      region: AWSRegionType.USEast1,
      credentialsProvider: credentialsProvider)
    
    AWSServiceManager.defaultServiceManager().setDefaultServiceConfiguration(defaultServiceConfiguration)
    // register device in cognito pool and get it's id
    credentialsProvider.getIdentityId()
    NSLog("uniq for device identity id \(credentialsProvider.identityId)")
  }
  
  func addFavouriteComic(comicTitle: String, comicID: String) {
    // sync and open dataset for current identity(device)
    let syncClient = AWSCognito.defaultCognito()
    let dataset = syncClient.openOrCreateDataset(FavouritesComisDataSetName)
    // add new key-value
    dataset.setString(comicTitle, forKey: comicID)
    // syncronize dataset asyncronously with cognito
    dataset.synchronize()
  }
  
  func getFavouritesDictionary(completionHandler handler: (response:NSDictionary!) -> Void) {
    // sync and open dataset for current identity(device)
    let syncClient = AWSCognito.defaultCognito()
    var dataset = syncClient.openOrCreateDataset(FavouritesComisDataSetName)
    // asyncronously fetch key value pairs
    dataset.synchronize().continueWithBlock { (task: BFTask!) -> AnyObject! in
      let datasetDictionary:NSDictionary = dataset.getAll()
      handler(response: datasetDictionary)
      return nil
    }
  }
  
}
