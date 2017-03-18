//
//  File.swift
//  XMLCoreData
//
//  Created by Abdou on 11/03/2017.
//  Copyright © 2017 Abdou. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SWXMLHash

extension ViewController {

    func handleNotification(notification: Notification) {

        switch notification.name.rawValue {

        case NotificationName.requestDidFoundVideos.rawValue:
            self.videos = self.fetchVideos(context: context)

        case NotificationName.requestDidntFoundVideos.rawValue:
            print(#function,"no video founded")
            self.fetchNewVideos()
        default:
            break
            
        }
    }

    func channelIsActive(channelId: String, requestResponse: @escaping ((Bool)->Swift.Void)) {

        let accessToken = "ya29.GlsMBEVjqrUmubnTsIKy2Qio02lRgDtKnK-mF6V2Lm3VHew5e89tiTZrluSUx0QvuPaoiaEMXGaLItEnTDYaDh9GSR-OKMAjnSyOz7-oNtPDoZDh6cxYsLxp_F8X"

        let host = Youtube.baseURL.appending(Path.searchPath.rawValue)
        let parameters = ["part" : "snippet","channelId": channelId,"order" : "date", "access_token" : accessToken] as [String: Any]
        let channelVideosURLString = addingParameters(parameters: parameters, to: host)

        print(channelVideosURLString)
        Alamofire.request(channelVideosURLString).validate().responseData { (dataResponse: DataResponse<Data>) in
            guard (dataResponse.result.isSuccess) else {
                print("Request error:\(String(describing: dataResponse.result.error?.localizedDescription))")
                return
            }

            guard let returnedData = dataResponse.value else {
                return
            }
            let json = JSON(data: returnedData)
            if json["items"].arrayValue.count > 0 {
                requestResponse(true)
            } else {
                requestResponse(false)
            }
        }
    }

    // MARK: - Parse local XML (channel feeds Urls)
    func parseLocalXMLFile() {
        self.parseLocalXMLFile { (inactiveChannelsId:[String]) in
            if inactiveChannelsId.count == 0 {
                self.channelsArray = self.channelsArrayFromLocalXMLFile
            } else {
                _ = inactiveChannelsId.map {
                    let host = "https://www.youtube.com/feeds/videos.xml"
                    let parameters = ["channel_id":$0] as [String: Any]
                    let url = addingParameters(parameters: parameters, to: host)

                    if let index = self.channelsArrayFromLocalXMLFile.index(of: url) {
                        self.channelsArrayFromLocalXMLFile.remove(at: index)
                    }
                }

                self.channelsArray = self.channelsArrayFromLocalXMLFile
            }
        }
    }



    // MARK: - Fetch XML feed Url
    func parseRemoteXML(xmlUrl: String, requestNewContent: Bool) {

        Alamofire.request(xmlUrl).validate().responseData(queue: backgroundQueue) {[unowned self] (dataResponse: DataResponse<Data>) in

            guard (dataResponse.result.isSuccess) else {
                print("Error parsing Remotre XML: \(dataResponse.response ?? HTTPURLResponse())","\n","-->:\(String(describing: dataResponse.result.error?.localizedDescription))")
                /*self.mainQueue.async {
                 NSApplication.shared().presentError(dataResponse.result.error!)
                 return
                 }*/
                return
            }

            guard let channelXmlData = dataResponse.value else {
                fatalError("No data returned")
            }

            let channelXml = SWXMLHash.parse(channelXmlData)
            (requestNewContent == true) ? self.fetchNewVideos(channelXMLIndexer: channelXml) : self.fetchSubscriptions(channelXMLIndexer: channelXml)
        }
    }

    // Fetch new videos
    func fetchNewVideos(channelXMLIndexer: XMLIndexer) {

        guard let lastVideo = self.videos.first else { return }
        let moc = appDelegate.getPrivateQueueContext()
        let videosCount = self.videos.count

        _ = channelXMLIndexer["feed"]["entry"].map {

            if let videoID = $0["yt:videoId"].element?.text, let title = $0["title"].element?.text, let publishedDate = NSDate.fromString($0["published"].element?.text ?? ""), let thumbnail = $0["media:group"]["media:thumbnail"].element?.attribute(by: "url")?.text, let link = $0["link"].element?.attribute(by: "href")?.text {

                let comp = publishedDate.compare(lastVideo.published! as Date) == .orderedSame || publishedDate.compare(lastVideo.published! as Date) == .orderedDescending

                guard (videoID != lastVideo.id && (comp == true)) else { return }

                let newVideo = Video(context: moc)

                newVideo.id = videoID
                newVideo.title = title
                newVideo.url = link
                newVideo.published = publishedDate
                newVideo.thumbnail = thumbnail

                moc.perform({
                    do {
                        try moc.save()
                    } catch {
                        print(#function,#line, "can't save new video")
                    }
                })

            }
        }

        channelsNumber += 1
        if channelsNumber == self.channelsArray?.count {
            var userInfo = [String: Any?]()

            let newVideos = self.fetchVideos(context: moc)

            if newVideos.count > videosCount {
                userInfo = ["notificationObject":newVideos]
                self.finishOperationsNotify(userInfo: userInfo)

            } else {
                userInfo = ["notificationObject":nil]
                self.finishOperationsNotify(userInfo: userInfo)
            }

        } else {
            print(channelsNumber)
        }
    }


    // Fech full subscriptions videos
    func fetchSubscriptions(channelXMLIndexer: XMLIndexer) {

        let moc = appDelegate.getPrivateQueueContext()

        let _ = channelXMLIndexer["feed"]["entry"].map {

            if let videoID = $0["yt:videoId"].element?.text, let title = $0["title"].element?.text, let publishedDate = NSDate.fromString($0["published"].element?.text ?? ""), let thumbnail = $0["media:group"]["media:thumbnail"].element?.attribute(by: "url")?.text, let link = $0["link"].element?.attribute(by: "href")?.text {

                let video = Video(context: moc)
                video.id = videoID
                video.title = title
                video.url = link
                video.published = publishedDate
                video.thumbnail = thumbnail

                moc.perform({
                    do {
                        try moc.save()
                    } catch {
                        fatalError("Faillure to save context: \(error.localizedDescription)")
                    }
                })
            }
        }

        channelsNumber += 1
        if channelsNumber == self.channelsArray?.count {
            let videos = self.fetchVideos(context: moc)
            let userInfo = ["notificationObject":videos]
            self.finishOperationsNotify(userInfo: userInfo)

        } else {
            print(channelsNumber)
        }
    }

    func finishOperationsNotify(userInfo: [String: Any?]) {

        mainQueue.async {

            switch userInfo["notificationObject"] {
            case let object as [Video]:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.requestDidFoundVideos.rawValue), object: object)
            default:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationName.requestDidntFoundVideos.rawValue), object: nil)
            }
        }

    }


    // MARK: - Parse local XML File to find inactive channels
    func parseLocalXMLFile(completion:@escaping ([String])->Void) {

        var inactiveChannels = [String]()
        _ = self.channelsArrayFromLocalXMLFile.enumerated().map({ (offset: Int, element: String) in

            guard let inactiveChannelId = element.components(separatedBy: "=").last else { return }

            self.group.enter()
            self.channelIsActive(channelId: inactiveChannelId, requestResponse: {[unowned self] (result: Bool) in
                if result == false {
                    inactiveChannels.append(inactiveChannelId)
                }
                self.group.leave()
            })
        })

        group.notify(queue: DispatchQueue.main, execute: {
            completion(inactiveChannels)
        })
    }


    func fetchVideos(context: NSManagedObjectContext) -> [Video] {

        let request = Video.fetchRequest() as NSFetchRequest<Video>
        request.sortDescriptors = [NSSortDescriptor(key: "published", ascending: false)]

        do {
            return try context.fetch(request)

        } catch {
            print("Error fetching videos:\(error.localizedDescription)")
        }
        return []
    }

    func videoDatabaseisEmpty() -> Bool {

        let request = Video.fetchRequest() as NSFetchRequest<Video>

        do {
            let videos = try context.fetch(request)

            if videos.count > 0 {
                return false
            } else {
                return true
            }

        } catch {
            print("Error fetching videos:\(error.localizedDescription)")
        }
        return false
    }

    func videoExistInDatabase(videoId: String) -> Bool {
        let fetch = Video.fetchRequest() as NSFetchRequest<Video>
        fetch.predicate = NSPredicate(format: "id == %@", videoId)

        do {
            let matchingVideos = try context.fetch(fetch)
            if matchingVideos.count >= 1 {
                return true
            } else {
                return false
            }
        } catch {}

        return false
    }

    func isNewVideo(videoId: String, publishedDate: NSDate) -> Bool {
        let request = Video.fetchRequest() as NSFetchRequest<Video>
        request.predicate = NSPredicate(format: "(id != %@) AND (published >= %@)", videoId, publishedDate)
        do {
            let matchingVideos = try context.fetch(request)
            if matchingVideos.count >= 1 {
                return true
            } else {
                return false
            }
        } catch {}

        return false
    }

    func deletVideos() {
        self.collectionView.dataSource =  nil
        self.collectionView.delegate =  nil

        defer {
            print("finished")
        }
        let fetch = Video.fetchRequest() as NSFetchRequest<Video>
        do {
            let videos = try context.fetch(fetch)
            _ = videos.map { vid in
                context.delete(vid)

            }
            try? self.context.save()

        } catch {
            print("Error fetching videos:\(error.localizedDescription)")
        }
    }

    func fetchNewVideos() {
        channelsNumber = 0

        let dispatchTime = DispatchTime.now() + .seconds(20)
        mainQueue.asyncAfter(deadline: dispatchTime) { 
            self.channelsArray = self.channelsArrayFromLocalXMLFile
        }
    }

    func excuteInBackground(bloc:@escaping (() -> Swift.Void)) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            bloc()
        }
    }


    // MARK: - Progress view
    func getProgressView() -> ProgressViewController {
        guard let progressView = storyboard?.instantiateController(withIdentifier: "FetchinChannelProgressView") as? ProgressViewController
            else {
                return ProgressViewController()
        }
        
        return progressView
    }
    
}
















