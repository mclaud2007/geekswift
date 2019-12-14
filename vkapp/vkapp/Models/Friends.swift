//
//  Friends.swift
//  weather
//
//  Created by Григорий Мартюшин on 25.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol FriendsModelProto {
    // Данные загружены
    func dataLoaded(data: [Friend]) -> Void
    
    // Данные начали загружать (можно включить анимацию или удалить старые данные например)
    func dataStartLoading() -> Void
    
    // Данные не загружены - произошла ошибка, дальше можно доработать и определять какая именно
    func dataNotLoaded() -> Void
}

// Сюда загружаем список друзей
class Friends {
    var List: [Friend] = []
    var loaded: Bool = false
    var delegate: FriendsModelProto!
    
    // Парсим данные и загружаем их в модель
    func parseJsonData(from json: JSON){
        if json["response"]["count"].int != nil {
            guard let friendItem = json["response"]["items"].array else { return }
            
            // Перебираем друзей и инициализируем массив
            for friend in friendItem {
                // Все данные есть - можно заполнять
                if let firstName = friend["first_name"].string,
                    let lastName = friend["last_name"].string,
                    let id = friend["id"].int,
                    let avatar = friend["photo_50"].string
                {
                    let friendToAdd = Friend(userId: id, photo: avatar, name: firstName + " " + lastName)
                    List.append(friendToAdd)
                }
            }
            
            // Говорим делегату что данные загружены
            self.delegate?.dataLoaded(data: self.List)
        }
    }
    
    // Загружаем информацию из сети
    func loadFromNetwork() {
        let token = Session.shared.getToken()
        
        if !token.isEmpty {
            let param: Parameters = [
                "access_token": token,
                "order": "hints",
                "v": VK.shared.APIVersion,
                "fields":"nickname,photo_50"
            ]
            
            // Получаем данные
            VK.shared.setCommand("friends.get", param: param) { response in
                switch response.result {
                    case .success(_):
                        // Сбрасываем флаг о том что данные загружены
                        self.delegate?.dataStartLoading()
                        
                        if let data = response.data {
                            let json = JSON(data)
                            self.parseJsonData(from: json)
                        }
                    case .failure(_):
                        self.delegate?.dataNotLoaded()
                }
                
            }
        }
    }
}

class Friend {
    let userId: Int
    let name: String
    // Аватарка пользовтеля
    let photo: String?
    // Массив с фотографиями пользователя
    let photos: [UIImage]?
    // Массив с лайками под фото (ключ в массиве - номер фотографии)
    // в дальнейшем это все должно приходить через АПИ по сети
    let likes: [Int]?
    // Массив ЗНАЧЕНИЯ в котором - номера (ключи) фото, к которым
    // уже поставил отметку нравится текущий пользователь
    let liked: [Int]?

    init (userId: Int, photo: String, name: String, photos: Array<UIImage>, likes: [Int], liked: [Int]){
        self.userId = userId
        self.name = name
        self.photo = photo
        self.photos = photos
        self.likes = likes
        self.liked = liked
    }
    
    init (userId: Int, photo: String, name: String, photos: Array<UIImage>, likes: [Int]){
        self.userId = userId
        self.name = name
        self.photo = photo
        self.photos = photos
        self.likes = likes
        self.liked = [-1]
    }
    
    init (userId: Int, photo: String, name: String){
        self.userId = userId
        self.name = name
        self.photo = photo
        self.photos = nil
        self.likes = [0]
        self.liked = [-1]
    }
    
    init (userId: Int, name: String){
        self.userId = userId
        self.name = name
        self.photo = nil
        self.photos = nil
        self.likes = [0]
        self.liked = [-1]
    }
}
