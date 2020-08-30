//
//  Photo.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 04.06.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation

// MARK: - Item
struct Photo {
    let likesStruct: PhotosLikes
    let id: Int
    let date: Int
    let sizes: [PhotosSizes]?
    let friendId: Int
    private(set) var reposts: Int? = 0
    var likes: Int? {
        return likesStruct.count
    }
    var isLiked: Bool? {
        return likesStruct.userLikes == 1 ? true : false
    }
    
    // Самое большое фото
    var biggestPhoto: PhotosSizes? {
        // Находим самую широкую из доступных фото
        return sizes?.sorted { (first, second) -> Bool in
            return first.width > second.width
        }.first
    }
    
    // Адрес самой большой фотографии среди размеров
    var photoUrlString: String? {
        return biggestPhoto?.url
    }
    
    var photoUrl: URL? {
        guard let urlString = self.photoUrlString else { return nil }
        return URL(string: urlString)
    }
    
    // Инициализация из словаря от парсинга JSON
    init (from photo: [String: Any]) {
        if let pLikes = photo["likes"] as? [String: Any],
            let count = pLikes["count"] as? Int,
            let user_likes = pLikes["user_likes"] as? Int
        {
            likesStruct = PhotosLikes(count: count, userLikes: user_likes)
        } else {
            likesStruct = PhotosLikes(count: 0, userLikes: 0)
        }
        
        if let pShare = photo["reposts"] as? [String: Any],
            let count = pShare["count"] as? Int
        {
            reposts = count
        }
        
        id = photo["id"] as? Int ?? 0
        date = photo["date"] as? Int ?? 0
        
        if let pSizes = photo["sizes"] as? [[String: Any]] {
            // Заполняем массив размеров
            self.sizes = pSizes.map {
                let size = $0
                
                if let height = size["height"] as? Int,
                    let width = size["width"] as? Int,
                    let type = size["type"] as? String,
                    let pType = PhotosSizesTypes(rawValue: type),
                    let url = size["url"] as? String
                {
                    return PhotosSizes(type: pType, url: url, width: width, height: height)
                } else {
                    return PhotosSizes(type: .s, url: "", width: 0, height: 0)
                }
            }
        } else {
            self.sizes = nil
        }
        
        self.friendId = photo["owner_id"] as? Int ?? 0
    }
}

// MARK: - Likes
struct PhotosLikes {
    let count, userLikes: Int
}

// MARK: - Size
struct PhotosSizes {
    let type: PhotosSizesTypes
    let url: String
    let width, height: Int
}

enum PhotosSizesTypes: String {
    case m = "m"
    case o = "o"
    case p = "p"
    case q = "q"
    case r = "r"
    case s = "s"
    case w = "w"
    case x = "x"
    case y = "y"
    case z = "z"
}
