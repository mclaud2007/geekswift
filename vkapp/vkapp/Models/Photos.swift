//
//  Photos.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 08.12.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class Photos {
    var List = [Photo]()
    var FriendID: Int?
    
    init (_ friendID: Int) {
        self.FriendID = friendID
    }
    
    func load(complition: @escaping ((_ data: [Photo]) -> Void)){
        if let friendId = self.FriendID {
            let token = Session.shared.getToken()
            
            if !token.isEmpty {
                let param: Parameters = [
                    "access_token": token,
                    "owner_id": friendId,
                    "extended": 1,
                    "need_hidden": 0,
                    "skip_hidden": 1,
                    "count": 20,
                    "v": VK.shared.APIVersion
                ]
                
                VK.shared.setCommand("photos.getAll", param: param) { response in
                    switch response.result {
                    case let .success(data):
                        let json = JSON(data)
                        
                        if json["response"]["count"] > 0 {
                            for item in json["response"]["items"].arrayValue {
                                let date = item["date"].intValue
                                let id = item["id"].intValue
                                let likes = item["likes"]["count"].int ?? -1
                                let liked = item["likes"]["user_likes"] == 0 ? false : true
                                let sizes = item["sizes"].arrayValue
                                var photo:String = ""
                                
                                // Теперь надо найти фотографию типа r
                                if sizes.count > 0 {
                                    let photoArr = sizes.filter({ $0["type"].stringValue == "r" })
                                    
                                    if photoArr.count > 0 {
                                        photo = photoArr[0]["url"].stringValue
                                    } else {
                                        let photoArr = sizes.filter({ $0["type"].stringValue == "y" })
                                        
                                        if photoArr.count > 0 {
                                            photo = photoArr[0]["url"].stringValue
                                        }
                                    }
                                }
                                
                                // Все данные получены инициализируем класс фото
                                self.List.append(Photo(photoId: id, photo: photo, likes: likes, liked: liked, date: date))
                            }
                            
                            // Что-то нашли - запускаем замыкание
                            complition(self.List)
                        }
                    case .failure(_):
                        break
                    }
                }
            }
        }
    }
}

class Photo {
    var date: Int?
    var id: Int
    var likes: Int
    var photoURL: String?
    var photoImage: UIImage?
    var isLiked: Bool = false
    
    init(photoId id: Int, photo: String, likes: Int?, liked: Bool? = false, date: Int?) {
        self.id = id
        self.photoURL = photo
        self.photoImage = nil
        self.likes = likes ?? -1
        self.date = date
        self.isLiked = liked!
    }
    
    init(photoId id: Int, photo: UIImage, likes: Int?, liked: Bool? = false, date: Int?) {
        self.id = id
        self.photoURL = nil
        self.photoImage = photo
        self.likes = likes ?? -1
        self.date = date
        self.isLiked = liked!
    }
}
