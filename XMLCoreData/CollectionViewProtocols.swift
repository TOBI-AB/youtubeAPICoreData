//
//  CollectionViewProtocols.swift
//  XMLCoreData
//
//  Created by Abdou on 13/03/2017.
//  Copyright © 2017 Abdou. All rights reserved.
//

import Cocoa

extension ViewController: NSCollectionViewDataSource {

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: "VideoCollectionViewItem", for: indexPath)
        item.representedObject = self.videos[indexPath.item]

        return item
    }
}

extension ViewController: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        let video = self.videos[indexPaths.first!.item]
        print("url: \(video.url ?? "")")
    }
}


extension ViewController: NSCollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {

         let itemWidth = collectionView.frame.size.width * 0.9
        return NSSize(width: itemWidth, height: itemWidth * 0.7)
    }

    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }

    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, insetForSectionAt section: Int) -> EdgeInsets {
        return EdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }

}



extension ViewController {
    // Setup subscriptions collectionView
    func setupCollectionView() {

        self.collectionView.backgroundColors = [NSColor.black]
        self.collectionView.isSelectable = true

        (collectionView.collectionViewLayout as? NSCollectionViewFlowLayout ?? NSCollectionViewFlowLayout()).scrollDirection = .vertical
    }
}


























