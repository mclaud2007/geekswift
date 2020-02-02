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
    var picture: String?
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
        let date = news["date"].doubleValue
        let text = news["text"].stringValue
    
        // Название новости - это паблик или профиль. По-умолчанию будет "Без названия" - дальше переопределим в случае успеха
        var title = "Без названия"
        var avatar: String?
        var picture: String?
        
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
        if let attachments = news["attachments"].array {
            let photos = attachments.filter({ $0["type"].stringValue == "photo" })
            var pSizeArray = [JSON]()
            
            // Фотографии могут быть в ссылках
            if photos.count == 0 {
                let pLink = attachments.filter({ $0["type"].stringValue == "link" })
                
                if pLink.count > 0 {
                    pSizeArray = pLink[0]["link"]["photo"]["sizes"].arrayValue
                }
            } else {
                pSizeArray = photos[0]["photo"]["sizes"].arrayValue
            }
            
            if pSizeArray.count > 0 {
                // Теперь найдем фотографии нужных размеров
                let pArr = pSizeArray.filter({ $0["type"].stringValue == "y" || $0["type"].stringValue == "l" || $0["type"].stringValue == "m" || $0["type"].stringValue == "r" })
                let pSizeCount = pArr.count
                
                // Что-то нашли
                if pSizeCount == 1 {
                    picture = pArr[0]["url"].stringValue
                } else if pSizeCount > 1 {
                    // Ищем размер y
                    for i in 0..<pSizeCount {
                        picture = pArr[i]["url"].stringValue
                        
                        // Если нашли размер y - дальше ничего не потребуется
                        if pArr[i]["type"].stringValue == "y" {
                            break
                        }
                    }
                }
            }
        }
        
        let humanDate = Date(timeIntervalSince1970: date)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = .current
        
        self.title = title
        self.content = text
        self.picture = picture
        self.avatar = avatar
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
    }
    
    init (title: String, content: String, date: String, picture: String, likes: Int) {
        self.title = title
        self.content = content
        self.date = date
        self.picture = picture
        self.likes = likes
    }
    
    init (title: String, content: String, date: String, picture: String, likes: Int, views: Int) {
        self.title = title
        self.content = content
        self.date = date
        self.picture = picture
        self.likes = likes
        self.views = views
    }
    
    init (title: String, content: String, date: String, picture: String, likes: Int, views: Int, comments: Int) {
        self.title = title
        self.content = content
        self.date = date
        self.picture = picture
        self.likes = likes
        self.comments = comments
        self.views = views
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
    }
}
