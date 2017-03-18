//
//  ViewController.swift
//  XMLCoreData
//
//  Created by Abdou on 11/03/2017.
//  Copyright © 2017 Abdou. All rights reserved.
//

import Cocoa
import Alamofire
import SWXMLHash


class ViewController: NSViewController {

    @IBOutlet weak var collectionView: NSCollectionView!

    let group = DispatchGroup()
    var channelsNumber = 0

    let appDelegate = NSApplication.shared().delegate as! AppDelegate
    let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.utility)
    let mainQueue = DispatchQueue.main

    // MARK: - Managed Object Context
    lazy var context: NSManagedObjectContext = { [unowned self] in
        return self.appDelegate.getMainQueueContext()
        }()

    // MARK: - Fetch Youtubes Channels from Local XML File
    lazy var channelsArrayFromLocalXMLFile: [String] = {
        var temp = [String]()
        guard let xmlFilePath = Bundle.main.path(forResource: "subscription", ofType: "xml") else {
            print("no such file")
            return [String]()
        }

        let xmlFileUrl = URL(fileURLWithPath: xmlFilePath)
        do {
            let xmlData = try Data(contentsOf: xmlFileUrl)
            let xml = SWXMLHash.parse(xmlData)

            temp = xml["opml"]["body"]["outline"]["outline"].map {
                $0.element?.attribute(by: "xmlUrl")?.text}.flatMap { $0 }
        } catch {}

        return temp
    }()


    // MARK: - Channels Urls
    var channelsArray: [String]? {

        didSet {
            if let arr = self.channelsArray {
                if videoDatabaseisEmpty() {

                    self.collectionView.dataSource =  nil
                    self.collectionView.delegate =  nil
                    _ = arr.forEach {
                        self.parseRemoteXML(xmlUrl: $0, requestNewContent: false)
                    }
                } else {
                    defer {
                        _ = arr.forEach {
                            self.parseRemoteXML(xmlUrl: $0, requestNewContent: true)
                        }
                    }
                    self.videos = self.fetchVideos(context: self.context)
                }
            }
        }
    }

    // MARK: - Videos
    var videos: [Video]! = nil {
        didSet {

            self.collectionView.dataSource =  self
            self.collectionView.delegate =  self
            self.setupCollectionView()
            self.collectionView.reloadData()
        }
    }


    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

     //  self.deletVideos()

       // print(self.videos.count)
        self.channelsArray = channelsArrayFromLocalXMLFile
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handleNotification(notification:)), name: nil, object: nil)
    }
}














































































