//
//  FlickrPhotosCollectionViewController.swift
//  FlickrExplorer
//
//  Created by Tim K Chan on 25/09/2018.
//  Copyright © 2018 Tim K Chan. All rights reserved.
//

import UIKit

final class FlickrPhotosCollectionViewController : UICollectionViewController {

  // MARK: - Properties
  fileprivate let reuseIdentifier = "FlickrCell"
  fileprivate let sectionInsets = UIEdgeInsets(top: 25.0, left: 10.0, bottom: 25.0, right: 10.0)
  fileprivate let itemsPerRow: CGFloat = 3

  var largePhotoIndexPath: NSIndexPath? {
    didSet {

      var indexPaths = [IndexPath]()
      if let largePhotoIndexPath = largePhotoIndexPath {
        indexPaths.append(largePhotoIndexPath as IndexPath)
      }
      if let oldValue = oldValue {
        indexPaths.append(oldValue as IndexPath)
      }

      collectionView?.performBatchUpdates({
        self.collectionView?.reloadItems(at: indexPaths)
      }) { completed in

        if let largePhotoIndexPath = self.largePhotoIndexPath {
          self.collectionView?.scrollToItem(
            at: largePhotoIndexPath as IndexPath,
            at: .centeredVertically,
            animated: true)
        }
      }
    }
  }

  fileprivate var searches = [FlickrSearchResults]()
  fileprivate let flickr = Flickr()
}

// MARK: - UICollectionViewDataSource
extension FlickrPhotosCollectionViewController {

  // Number of sections in the Colelction View
  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return searches.count
  }

  // Number of cells in each section
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return searches[section].searchResults.count
  }

  // Populate HEader View
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

    switch kind {

    case UICollectionView.elementKindSectionHeader:
      let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                       withReuseIdentifier: "FlickrPhotosCollectionHeaderView",
                                                                       for: indexPath) as! FlickrPhotosCollectionHeaderView
      headerView.label.text = searches[(indexPath as NSIndexPath).section].searchTerm
      return headerView

    default:
      assert(false, "Unexpected element kind")
    }
  }

  // Populate Cell
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FlickrPhotosCollectionViewCell

    let flickrPhoto = photoForIndexPath(indexPath: indexPath)
    cell.imageView.image = flickrPhoto.thumbnail
    return cell
  }
}

// MARK: - UICollectionViewDelegate
extension FlickrPhotosCollectionViewController {

  override func collectionView(_ collectionView: UICollectionView,
                               shouldSelectItemAt indexPath: IndexPath) -> Bool {

    largePhotoIndexPath = largePhotoIndexPath == (indexPath as NSIndexPath) ? nil : indexPath as NSIndexPath
    print("Tapped at \(indexPath)")
    return true
  }

  override func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
    return true
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FlickrPhotosCollectionViewController : UICollectionViewDelegateFlowLayout {
  //1
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    //2
    let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
    let availableWidth = view.frame.width - paddingSpace
    let widthPerItem = floor(availableWidth / itemsPerRow)
    return CGSize(width: widthPerItem, height: widthPerItem)
  }

  //3
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return sectionInsets
  }

  // 4
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return sectionInsets.left
  }
}

// Text Box Action
extension FlickrPhotosCollectionViewController : UITextFieldDelegate {

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {

    let activityIndicator = UIActivityIndicatorView(style: .gray)
    self.view.addSubview(activityIndicator)
    activityIndicator.frame = self.view.bounds
    activityIndicator.startAnimating()

    flickr.searchFlickrForTerm(textField.text!) {
      results, error in

      activityIndicator.removeFromSuperview()

      if let error = error {
        // 2
        print("Error searching : \(error)")
        return
      }

      if let results = results {

        print("Found \(results.searchResults.count) matching \(results.searchTerm)")
        self.searches.insert(results, at: 0)

        self.collectionView?.reloadData()
      }
    }

    textField.text = nil
    textField.resignFirstResponder()
    return true
  }
}

// Mark: - Private
private extension FlickrPhotosCollectionViewController {
  func photoForIndexPath(indexPath: IndexPath) -> FlickrPhoto {
    return searches[(indexPath as IndexPath).section].searchResults[(indexPath as IndexPath).row]
  }
}
