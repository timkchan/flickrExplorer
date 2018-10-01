//
//  FlickrPhotosCollectionViewCell.swift
//  FlickrExplorer
//
//  Created by Tim K Chan on 25/09/2018.
//  Copyright © 2018 Tim K Chan. All rights reserved.
//

import UIKit

class FlickrPhotosCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var imageView: UIImageView!

  override var isSelected: Bool {
    didSet {
      imageView.layer.borderWidth = isSelected ? 5 : 0
    }
  }
  
}
