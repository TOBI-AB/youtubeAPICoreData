//
//  Common.swift
//  XMLCoreData
//
//  Created by Abdou on 11/03/2017.
//  Copyright © 2017 Abdou. All rights reserved.
//

import Cocoa

enum NotificationName: String {
    case requestDidFoundVideos = "finishSavingVideo"
    case requestDidntFoundVideos = "requestDontReturnVides"
}

struct Youtube {
    static let clientID = "242373373621-o1lau8utkj8quoj0c0db60ri9a2etbf3.apps.googleusercontent.com"
    static let redirectURIScheme = "com.googleusercontent.apps.242373373621-o1lau8utkj8quoj0c0db60ri9a2etbf3"
    static let baseURL  = "https://www.googleapis.com/youtube/v3"
}

enum Path: String {
    case videosGetRatingPath = "/videos/getRating"
    case videosRatingPath    = "/videos/rate"
    case playListsPath       = "/playlists"
    case commentThreads      = "/commentThreads"
    case channelsPath        = "/channels"
    case videosPath          = "/videos"
    case searchPath          = "/search"
    case subscriptionsPath   = "/subscriptions"
    case redirctURIPath      = ":/oauth2redirect"
    case googleOAuthPath     = "https://accounts.google.com/o/oauth2/auth"
    case tokenPath           = "https://accounts.google.com/o/oauth2/token"
    case refreshTokenPath    = "https://www.googleapis.com/oauth2/v4/token"
}

extension NSDate {
    static func fromString(_ string: String) -> NSDate? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss+ss:ss"
        guard let date = dateFormatter.date(from: string) else { return nil }
        return date as NSDate
    }
}

extension NSImage {

    func resize(toSize size: NSSize) -> NSImage! {
        let destSize = size
        let newImage = NSImage(size: destSize)

        newImage.lockFocus()
        self.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height), from: NSMakeRect(0, 0, self.size.width, self.size.height), operation: NSCompositingOperation.sourceOver, fraction: CGFloat(1), respectFlipped: true, hints: nil)

        newImage.unlockFocus()
        newImage.size = destSize

        guard let data = newImage.tiffRepresentation else {
            return nil
        }

        return NSImage(data: data)
    }
}

func addingParameters(parameters: [String: Any], to string: String) -> String {

    guard var components = URLComponents(string: string) else { return "" }
    components.queryItems = parameters.map {  URLQueryItem(name: $0.key, value: "\($0.value)") }
    guard let url = components.url else { return ""}

    return url.absoluteString
}




















