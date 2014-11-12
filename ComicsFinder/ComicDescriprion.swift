//
//  ComicDescriprion.swift
//  ComicsFinder
//
//  Created by Roma on 11/11/14.
//  Copyright (c) 2014 Roma. All rights reserved.
//

import UIKit

class ComicDescriprion: UITableViewController {
  
  @IBOutlet var coverImageView:UIImageView?
  @IBOutlet var comicDescriprion: UITextView?
  
  var comic: Comic?
  
  override func viewDidLoad() {
    
    self.title = comic?.title!
    if let description = comic?.description {
      comicDescriprion?.text = description
    }
    
    let comicCoverStringURL = comic?.getCoverUrlForSize(CoverSize.CoverSizeLandscape)
    coverImageView?.asyncSetImageFromURL(NSURL(string: comicCoverStringURL!)!)
    
  }
  
}
