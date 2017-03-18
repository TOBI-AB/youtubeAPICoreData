//
//  NetworkManager.swift
//  XMLCoreData
//
//  Created by Abdou on 12/03/2017.
//  Copyright © 2017 Abdou. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol NetworkManagerDelegate {
    func didGetInactiveChannel(channelID: String)
}

class NetworkManager: NSObject {

    var delegate: NetworkManagerDelegate?
    var channelId = String()
    var urlsArray = [String]()

    lazy var accessToken: String = {
        return "ya29.GlwMBKB473FmYfrxw8hD5VC77OzTL4WIpyz34GiA6iXyYlmWMvS1pV91_oNjBMum66sgAbm5DHfR7TfqqZWckYd7TOc0mQkuqd0_RrjXtTfhFSJZEIpHSPO5_v2jcQ"
    }()

    lazy var channelUrl: String = {[unowned self] in
        let host = Youtube.baseURL.appending(Path.searchPath.rawValue)
        let parameters = ["part" : "snippet","channelId": self.channelId,"order" : "date", "access_token" : self.accessToken] as [String: Any]
        return addingParameters(parameters: parameters, to: host)
    }()

    override init() {
        super.init()
    }
    convenience init(channelId: String) {
        self.init()
        self.channelId = channelId
    }

    convenience init(urlsArray: [String]) {
        self.init()
        self.urlsArray = urlsArray
    }
}


extension NetworkManager {

    func deleteInactiveChannels(channelsArray:[String], completion:@escaping (([String])->Swift.Void)) {
        var temp = channelsArray
        Alamofire.request(self.channelUrl).validate().responseData { (dataResponse: DataResponse<Data>) in

            guard (dataResponse.result.isSuccess) else {
                print(dataResponse.result.error?.localizedDescription ?? "ERROR SERVER")
                return
            }

            guard let returnedData = dataResponse.value else {
                return
            }

            let json = JSON(data: returnedData)

            if json["items"].arrayValue.count == 0 {

                let host = "https://www.youtube.com/feeds/videos.xml"
                let parameters = ["channel_id":self.channelId] as [String: Any]
                let url = addingParameters(parameters: parameters, to: host)

                if temp.contains(url), let index = temp.index(of: url) {
                    temp.remove(at: index)
                }
            }

            completion(temp)
        }

    }

    func checkChannelActivity() {

        var channels = [String]()

        Alamofire.request(self.channelUrl).validate().responseData { (dataResponse: DataResponse<Data>) in

            guard (dataResponse.result.isSuccess) else {
                print(dataResponse.result.error?.localizedDescription ?? "ERROR SERVER")
                return
            }

            guard let returnedData = dataResponse.value else {
                return
            }

            let json = JSON(data: returnedData)

            if json["items"].arrayValue.count == 0 {
                channels.append(self.channelId)
                self.delegate?.didGetInactiveChannel(channelID: self.channelId)
                print(channels)
            }
        }
    }
}





























