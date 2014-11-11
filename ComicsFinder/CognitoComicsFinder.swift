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
        
        credentialsProvider.getIdentityId()
    }

    func addFavouriteComic(comicTitle: String, comicID: String) {
        
        let syncClient = AWSCognito.defaultCognito()
        let dataset = syncClient.openOrCreateDataset(FavouritesComisDataSetName)
        
        dataset.setString(comicTitle, forKey: comicID)
        
        dataset.synchronize()
    }
    
    func getFavouritesDictionary(completionHandler handler: (response:NSDictionary!) -> Void) {
        
        let syncClient = AWSCognito.defaultCognito()
        var dataset = syncClient.openOrCreateDataset(FavouritesComisDataSetName)
       
        dataset.synchronize().continueWithBlock { (task: BFTask!) -> AnyObject! in
            let datasetDictionary:NSDictionary = dataset.getAll()
            handler(response: datasetDictionary)
            return nil
        }
    }

}
