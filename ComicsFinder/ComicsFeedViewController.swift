//
//  ViewController.swift
//  ComicsFinder
//
//  Created by Roma on 11/5/14.
//  Copyright (c) 2014 Roma. All rights reserved.
//

import UIKit
import QuartzCore

let ActivityIndicatorHeight: CGFloat = 50.0
let UITableViewCellHeight: CGFloat = 68.0
let CoverImageCornerRadius: CGFloat = 10.0

class ComicsFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ComicTableViewCellDelegate, ComicsControllerDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  
  var comicsArray:[Comic] = [ ]
  var staredComicsArray:[Comic] = [ ]
  var comicsSourceArray:[Comic] = [ ]
  var isShowStaredModeOn = false
  
  let comicsModel = ComicsModel()
  
  var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    activityIndicator.startAnimating()
    
    comicsModel.delegate = self
    comicsModel.updateComicsData()
  }
  
  // MARK: TableViewMethods
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return comicsSourceArray.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("ComicTableViewCell") as ComicTableViewCell
    let comic = comicsSourceArray[indexPath.row]
    
    cell.title.text="\(comic.title!)"
    cell.comicDescription?.text = "\(comic.price!)$"
    let comicCoverStringURL = comic.getCoverUrlForSize(CoverSize.CoverSizeMedium)
    cell.cover.asyncSetImageFromURL(NSURL(string: comicCoverStringURL)!)
    cell.cover.layer.cornerRadius = CoverImageCornerRadius
    cell.cover.layer.masksToBounds = true
    cell.cellContentContainer.scrollEnabled = !isShowStaredModeOn
    cell.delegate = self
    
    return cell
  }
  
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return UITableViewCellHeight
  }
  
  func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let footer = UIView(frame: CGRect(x: 0,y: 0, width: tableView.bounds.size.width, height: ActivityIndicatorHeight))
    
    activityIndicator.hidesWhenStopped = true
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
    activityIndicator.color = UIColor.redColor()
    footer.addSubview(activityIndicator)
    activityIndicator.center = footer.center
    
    return footer
  }
  
  func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return ActivityIndicatorHeight
  }
  
  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
    if bottomEdge >= scrollView.contentSize.height && isShowStaredModeOn == false {
      activityIndicator.startAnimating()
      comicsModel.loadNextPage()
    }
  }
  
  // MARK: ComicCellDelegate
  func cellDidMarkedAsFavourites(cell: ComicTableViewCell) {
    let indexPath: NSIndexPath = tableView.indexPathForCell(cell)!
    
    let staredComic = comicsSourceArray[indexPath.row]
    comicsModel.addComicToFavourite(staredComic)
    
    staredComicsArray.insert(comicsArray[indexPath.row], atIndex: 0)
    comicsArray.removeAtIndex(indexPath.row)
    comicsSourceArray = comicsArray
    
    tableView.beginUpdates()
    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Right)
    tableView.endUpdates()
  }
  
  func cellDidTaped(cell: ComicTableViewCell) {
    let indexPath: NSIndexPath = tableView.indexPathForCell(cell)!
    let comic = comicsSourceArray[indexPath.row]
    self.performSegueWithIdentifier("ComicDescriptionSegue", sender: comic)
  }
  // MARK: SwitchMethods
  @IBAction func allStarredSwitchChanged(sender: UISegmentedControl) {
    if sender.selectedSegmentIndex == 0 {
      isShowStaredModeOn = false
      comicsSourceArray = comicsArray
    } else {
      isShowStaredModeOn = true
      comicsSourceArray = staredComicsArray
      if comicsModel.updatingFavourites() == true {
        activityIndicator.startAnimating()
      }
    }
    tableView.reloadData()
  }
  
  // MARK: ComicsController delegate
  func comicsDataDidUpdated(comicsArray: Array<Comic>, favouritesArray: Array<Comic>) {
    self.comicsArray = comicsArray
    self.staredComicsArray = favouritesArray
    if isShowStaredModeOn {
      self.comicsSourceArray = self.staredComicsArray
    } else {
      self.comicsSourceArray = self.comicsArray
    }
    
    if self.comicsSourceArray.count > 0 {
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.activityIndicator.stopAnimating()
        self.tableView.reloadData()
      })
      
      if self.comicsArray.count < 10 {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          self.activityIndicator.startAnimating()
        })
        
        comicsModel.loadNextPage()
      }
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ComicDescriptionSegue" {
      let comic = sender as Comic
      let comicDescriptionVC = segue.destinationViewController as ComicDescriprion
      comicDescriptionVC.comic = comic
    }
  }
}

