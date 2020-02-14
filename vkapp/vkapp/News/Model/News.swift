//
//  News.swift
//  weather
//
//  Created by Григорий Мартюшин on 09.11.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit
import SwiftyJSON

class News {
    var title: String?
    var content: String
    var date: String
    var unixDateTime: Double?
    
    var picture: String?
    var picHeight: Int?
    var picWidth: Int?
    var aspectRatio: CGFloat? {
        if let picHeight = picHeight,
            let picWidth = picWidth,
            picWidth != 0
        {
            return CGFloat(picHeight) / CGFloat(picWidth)
        } else {
            return nil
        }
    }
    
    var likes: Int? = 0
    var comments: Int? = 0
    var views: Int? = 0
    var shared: Int? = 0
    var isLiked: Bool? = false
    var avatar: String?
    
    // Инициализируем новость от массива полученного
    // непосредственно в сетевом сервисе
    init (json news: JSON, groups: [Group], profiles: [Friend]) {
        var sourceId = news["source_id"].intValue
        unixDateTime = news["date"].doubleValue
        content = news["text"].stringValue
    
        // Название новости - это паблик или профиль. По-умолчанию будет "Без названия" - дальше переопределим в случае успеха
        title = "Без названия"
        
        // если источник < 0 - это группа
        if sourceId < 0 {
            sourceId = sourceId * -1
            
            let source = groups.filter({ $0.groupId == sourceId })
            
            if source.count > 0 {
                title = source[0].name
                avatar = source[0].imageString
            }
        }
        // Если источник больше нуля то это профиль
        else {
            let source = profiles.filter { $0.userId == sourceId }
            
            if source.count > 0 {
                title = source[0].name
                avatar = source[0].photo
            }
        }
        
        // Ищем фото для новости
        if let attachments = news["attachments"].array,
            let photoMaxSize = VKService.shared.getPhotoMaxSizeFrom(attachments: attachments)
        {
            self.picWidth = photoMaxSize["width"].int
            self.picHeight = photoMaxSize["height"].int
            
            // У doc фотография хранится в src
            if let srcString = photoMaxSize["src"].string {
                self.picture = srcString
            } else if let urlString = photoMaxSize["url"].string {
                self.picture = urlString
            }
        }
        
        let humanDate = Date(timeIntervalSince1970: unixDateTime ?? 0)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = .current
        
        self.date = dateFormatter.string(from: humanDate)
        
        // Лайки просмотры комментарии
        self.likes = news["likes"]["count"].int ?? 0
        self.isLiked = (news["likes"]["user_likes"].intValue == 0 ? false : true)
        self.comments = news["comments"]["count"].int ?? 0
        self.views = news["views"]["count"].int ?? 0
        self.shared = news["reposts"]["count"].int ?? 0
    }
    
    init (title: String, content: String, date: String, picture: String) {
        self.title = title
        self.content = content
        self.date = date
        self.picture = picture
        self.unixDateTime = nil
    }
    
    init (title: String, content: String, date: String, picture: String, likes: Int) {
        self.title = title
        self.content = content
        self.date = date
        self.picture = picture
        self.likes = likes
        self.unixDateTime = nil
    }
    
    init (title: String, content: String, date: String, picture: String, likes: Int, views: Int) {
        self.title = title
        self.content = content
        self.date = date
        self.picture = picture
        self.likes = likes
        self.views = views
        self.unixDateTime = nil
    }
    
    init (title: String, content: String, date: String, picture: String, likes: Int, views: Int, comments: Int) {
        self.title = title
        self.content = content
        self.date = date
        self.picture = picture
        self.likes = likes
        self.comments = comments
        self.views = views
        self.unixDateTime = nil
    }
    
    init (title: String, content: String, date: String, picture: String, likes: Int, views: Int, comments: Int, shared: Int) {
        self.title = title
        self.content = content
        self.date = date
        self.picture = picture
        self.likes = likes
        self.comments = comments
        self.views = views
        self.shared = shared
        self.unixDateTime = nil
    }
    
    init (title: String, content: String, date: String, picture: String, likes: Int, views: Int, comments: Int, shared: Int, isLiked: Bool) {
        self.title = title
        self.content = content
        self.date = date
        self.picture = picture
        self.likes = likes
        self.comments = comments
        self.views = views
        self.shared = shared
        self.isLiked = isLiked
        self.unixDateTime = nil
    }
    
    init (title: String, content: String, date: String, picture: String?, likes: Int, views: Int, comments: Int, shared: Int, isLiked: Bool, avatar: String?) {
        self.title = title
        self.content = content
        self.date = date
        self.picture = picture
        self.likes = likes
        self.comments = comments
        self.views = views
        self.shared = shared
        self.isLiked = isLiked
        self.avatar = avatar
        self.unixDateTime = nil
    }
}
