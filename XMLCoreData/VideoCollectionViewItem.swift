//
//  VideoCollectionViewItem.swift
//  XMLCoreData
//
//  Created by Abdou on 13/03/2017.
//  Copyright © 2017 Abdou. All rights reserved.
//

import Cocoa
import Alamofire
import AlamofireImage

class VideoCollectionViewItem: NSCollectionViewItem {

    dynamic var videoTitle:String?
    dynamic var videoThumbnail: NSImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    override var representedObject: Any? {
        didSet {
            if let video = self.representedObject as? Video {
                self.videoTitle = video.title
                self.fetchVideoThumbnail(thumbnailUrl: video.thumbnail)
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    func fetchVideoThumbnail(thumbnailUrl: String?) {


        Alamofire.request(thumbnailUrl ?? "").validate().responseImage(completionHandler: { (dataResponse: DataResponse<Image>) in
            guard (dataResponse.result.isSuccess) else {
              //  print("Error fetching image: \(dataResponse.response ?? HTTPURLResponse())","\n","-->:\(String(describing: dataResponse.result.error?.localizedDescription))")
                self.videoThumbnail = nil
                return
            }

            guard let image = dataResponse.value else {
                fatalError("No data returned")
            }

            _ = image.representations.map {
                self.videoThumbnail = image.resize(toSize: $0.size)
            }

        })

    }
}

































