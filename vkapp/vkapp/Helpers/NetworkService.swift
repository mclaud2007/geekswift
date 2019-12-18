//
//  VKApiClass.swift
//  weather
//
//  Created by Григорий Мартюшин on 07.12.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class VK {
    private let APIUrl = "api.vk.com"
    private let APIUriSuffix = "/method"
    let APIVersion = "5.103"
    
    private let OAuthURL = "oauth.vk.com"
    private let OAuthUriSuffix = "/authorize"
    private let OAuthBackLink = "https://oauth.vk.com/blank.html"
    
    private let APISchema = "https"
    private let ClientID = "7238798"
    
    // Сделаем синглом
    static let shared = VK()
    
    public func getOAuthRequest () -> URLRequest {
        // Готовим запрос
        var urlComponents = URLComponents()
        urlComponents.scheme = self.APISchema
        urlComponents.host = self.OAuthURL
        urlComponents.path = self.OAuthUriSuffix
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: self.ClientID),
            URLQueryItem(name: "display", value: "mobile"),
            URLQueryItem(name: "redirect_url", value: OAuthBackLink),
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "scope", value: "262150")
        ]
        
        return URLRequest(url: urlComponents.url!)
    }
    
    public func setCommand (_ apiMethod: String, param: Parameters?, completion: ((AFDataResponse<Any>) -> Void)? ) {
        let url = self.APISchema + "://" + self.APIUrl + self.APIUriSuffix + "/" + apiMethod
                
        AF.request(url, method: .get, parameters: param).responseJSON { response in
            completion?(response)
        }
    }
    
    // MARK: Поиск по группам
    public func getGroupSearch(query: String, complition: @escaping (Result<[Group], Error>) -> Void) {
        let token = Session.shared.getToken()
        var List = [Group]()
        
        if !token.isEmpty {
            let param: Parameters = [
                "access_token": token,
                "user_id": Session.shared.getUserId(),
                "type": "group",
                "q": query,
                "count": 10,
                "v": VK.shared.APIVersion
            ]
        
            VK.shared.setCommand("groups.search", param: param) { response in
                switch response.result {
                    case let .success(data):
                        let json = JSON(data)
                        
                        // что-то нашли
                        if (json["response"]["count"].intValue > 0){
                            for group in json["response"]["items"].arrayValue {
                                if let id = group["id"].int,
                                    let name = group["name"].string,
                                    let photo = group["photo_50"].string {
                                    
                                    List.append(Group(groupId: id, name: name, image: photo))
                                }
                            }

                            complition(.success(List))
                        }
                    case let .failure(error):
                        complition(.failure(error))
                    break
                }
            }
        }
    }
    
    // MARK: Загрузка групп
    public func getGroupsList(complition: @escaping (Result<[Group], Error>) -> Void) {
        let token = Session.shared.getToken()
        var List = [Group]()
        
        if !token.isEmpty {
            let param: Parameters = [
                "access_token": token,
                "user_id": Session.shared.getUserId(),
                "extended": 1,
                "fields": "photo_50,name",
                "v": VK.shared.APIVersion
            ]
        
            VK.shared.setCommand("groups.get", param: param) { response in
                switch response.result {
                    case let .success(data):
                        let json = JSON(data)
                        
                        // что-то нашли
                        if (json["response"]["count"].intValue > 0){
                            for group in json["response"]["items"].arrayValue {
                                if let id = group["id"].int,
                                    let name = group["name"].string,
                                    let photo = group["photo_50"].string {
                                    
                                    List.append(Group(groupId: id, name: name, image: photo))
                                }
                            }

                            complition(.success(List))
                        }
                    case let .failure(error):
                        complition(.failure(error))
                    break
                }
            }
        }
    }
    
    // MARK: Загрузка фото
    func getPhotosByFriendId(friendId: Int, complition: @escaping ((_ data: [Photo]) -> Void)){
        let token = Session.shared.getToken()
        var List = [Photo]()
        
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
                            List.append(Photo(photoId: id, photo: photo, likes: likes, liked: liked, date: date))
                        }
                        
                        // Что-то нашли - запускаем замыкание
                        complition(List)
                    }
                case .failure(_):
                    break
                }
            }
        }
        
    }
    
    // MARK: Парсинг JSON друзей
    private func parseFriend(from json: JSON) -> [Friend]? {
        var List = [Friend]()
        
        if json["response"]["count"].int != nil {
            guard let friendItem = json["response"]["items"].array else { return nil }
            
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
        }
        
        return List
    }
    
    // MARK: Загрузка друзей
    public func getFriendsList(completion: @escaping ([Friend]?, Error?) -> Void ) {
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
                case let .success(data):
                    let json = JSON(data)
                    let friendList = VK.shared.parseFriend(from: json)
                        completion(friendList, nil)
                    
                case let .failure(error):
                    completion(nil, error)
                }
                
            }
        }
    }
}
