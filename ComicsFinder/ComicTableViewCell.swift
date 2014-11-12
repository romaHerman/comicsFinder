//
//  ComicTableViewCell.swift
//  ComicsFinder
//
//  Created by Roma on 11/7/14.
//  Copyright (c) 2014 Roma. All rights reserved.
//

import UIKit

protocol ComicTableViewCellDelegate {
  func cellDidMarkedAsFavourites(cell: ComicTableViewCell)
  func cellDidTaped(cell: ComicTableViewCell)
}

class ComicTableViewCell: UITableViewCell, UIScrollViewDelegate {
  @IBOutlet var title: UILabel!
  @IBOutlet var starIndicatorLabel: UILabel!
  @IBOutlet var comicDescription: UILabel?
  @IBOutlet var cover: UIImageView!
  @IBOutlet var cellContentContainer: UIScrollView!
  
  var delegate:ComicTableViewCellDelegate?
  
  let StarOffsetEdge:CGFloat = -75.0
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func awakeFromNib() {
    starIndicatorLabel.alpha = 0.5
    let singleTap = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
    cellContentContainer.addGestureRecognizer(singleTap)
    super.awakeFromNib()
  }
  
  func handleTap(recognizer: UITapGestureRecognizer) {
    delegate?.cellDidTaped(self)
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    let shouldMarkAsStar = isContentOffsetInMarkAsStarArea(scrollView)
    
    if shouldMarkAsStar {
      starIndicatorLabel.alpha = 1.0
    } else {
      starIndicatorLabel.alpha = 0.5
    }
  }
  
  func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    let didMarkedAsStar = isContentOffsetInMarkAsStarArea(scrollView)
    if didMarkedAsStar {
      delegate?.cellDidMarkedAsFavourites(self)
    }
  }
  
  func isContentOffsetInMarkAsStarArea(scrollView:UIScrollView) -> Bool {
    let xOffset = scrollView.contentOffset.x
    var shouldMarkAsStar = false
    
    if xOffset <= StarOffsetEdge {
      shouldMarkAsStar = true
    }
    
    return shouldMarkAsStar
  }
  
}
