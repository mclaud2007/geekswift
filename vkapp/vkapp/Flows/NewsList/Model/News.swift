//
//  News.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 06.06.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation
import UIKit

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

    init (from news: [String: Any], groups: [Group], profiles: [Friend]) {
        var sourceId = news["source_id"] as? Int ?? 0
        unixDateTime = news["date"] as? Double
        content = news["text"] as? String ?? ""
        
        // Название новости - это паблик или профиль. По-умолчанию будет "Без названия" - дальше переопределим в случае успеха
        title = "Без названия"
        
        // если источник < 0 - это группа
        if sourceId < 0 {
            sourceId = sourceId * -1
            let source = groups.filter({ $0.groupId == sourceId })

            title = source.first?.name
            avatar = source.first?.imageString
            
        }
        // Если источник больше нуля то это профиль
        else {
            let source = profiles.filter { $0.userId == sourceId }

            title = source.first?.name
            avatar = source.first?.photo
        }
        
        // Разбираем вложения
        if let attachements = news["attachments"] as? [[String: Any]] {
            for attach in attachements {
                let type = attach["type"] as? String
                
                switch type {
                case "photo":
                    if let photoArray = attach["photo"] as? [String: Any] {
                        let photo = Photo(from: photoArray)
                        
                        picture = photo.photoUrlString
                        picWidth = photo.biggestPhoto?.width
                        picHeight = photo.biggestPhoto?.height
                    }
                    break
                case "link":
                    if let linkArray = attach["link"] as? [String: Any],
                        let photoArray = linkArray["photo"] as? [String: Any]
                    {
                        let photo = Photo(from: photoArray)
                        
                        picture = photo.photoUrlString
                        picWidth = photo.biggestPhoto?.width
                        picHeight = photo.biggestPhoto?.height
                    }
                    break
                case "video":
                    if let videoArray = attach["video"] as? [String: Any],
                        let imageSizes = videoArray["image"] as? [[String: Any]]
                    {
                        // Преобразуем ответ в структуру размеров с фотографиями
                        let photoSizes:[PhotosSizes] = imageSizes.compactMap {
                            if let height = $0["height"] as? Int,
                                let width = $0["width"] as? Int,
                                let url = $0["url"] as? String
                            {
                                return PhotosSizes(type: .x, url: url, width: width, height: height)
                            } else {
                                return nil
                            }
                        }
                        
                        // Ищем самую большую фотографию если что - то нашли
                        let mostBigSizes = photoSizes.sorted { (first, second) -> Bool in
                            return first.width > second.width
                        }.first
                        
                        // Запишем найденную фотографию
                        if let mostBigSizes = mostBigSizes {
                            picture = mostBigSizes.url
                            picWidth = mostBigSizes.width
                            picHeight = mostBigSizes.height
                        }
                    }
                case "poll":
                    if let pollArray = attach["poll"] as? [String: Any],
                        let photo = pollArray["photo"] as? [String: Any],
                        let imageSizes = photo["image"] as? [[String: Any]]
                    {
                        // Преобразуем ответ в структуру размеров с фотографиями
                        let photoSizes:[PhotosSizes] = imageSizes.compactMap {
                            if let height = $0["height"] as? Int,
                                let width = $0["width"] as? Int,
                                let url = $0["url"] as? String
                            {
                                return PhotosSizes(type: .x, url: url, width: width, height: height)
                            } else {
                                return nil
                            }
                        }
                        
                        // Ищем самую большую фотографию если что - то нашли
                        let mostBigSizes = photoSizes.sorted { (first, second) -> Bool in
                            return first.width > second.width
                        }.first
                        
                        // Запишем найденную фотографию
                        if let mostBigSizes = mostBigSizes {
                            picture = mostBigSizes.url
                            picWidth = mostBigSizes.width
                            picHeight = mostBigSizes.height
                        }
                    }
                    
                    break
                default:
                    break
                }
            }
        }

        let humanDate = Date(timeIntervalSince1970: unixDateTime ?? 0)
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = .current

        // Дата отформатированная дата размещения новости
        date = dateFormatter.string(from: humanDate)
        
        // Счетчик лайков
        if let likesArray = news["likes"] as? [String: Any] {
            likes = likesArray["count"] as? Int
            isLiked = false
            
            if let userLikes = likesArray["user_likes"] as? Int {
                isLiked = (userLikes == 1 ? true : false)
            }
        }

        // Лайки просмотры комментарии
        if let commentsArray = news["comments"] as? [String: Any] {
            comments = commentsArray["count"] as? Int
        }
        
        if let viewsArray = news["views"] as? [String: Any] {
            views = viewsArray["count"] as? Int
        }
        
        if let sharedArray = news["reposts"] as? [String: Any] {
            shared = sharedArray["count"] as? Int
        }
    }
}
