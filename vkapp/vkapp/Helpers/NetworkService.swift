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
import RealmSwift

class VK {
    private let APIUrl = "api.vk.com"
    private let APIUriSuffix = "/method"
    let APIVersion = "5.103"
    
    private let OAuthURL = "oauth.vk.com"
    private let OAuthUriSuffix = "/authorize"
    private let OAuthBackLink = "https://oauth.vk.com/blank.html"
    
    private let APISchema = "https"
    private let ClientID = "7238798"
    private let ClientSecret = "FkU2VoEQb7vVr5esriPQ"
    
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
            URLQueryItem(name: "scope", value: "wall,photos,offline,friends,stories,status,groups")
        ]
        
        return URLRequest(url: urlComponents.url!)
    }
    
    public func setCommand (_ apiMethod: String, param: Parameters?, completion: ((AFDataResponse<Any>) -> Void)? ) {
        let url = self.APISchema + "://" + self.APIUrl + self.APIUriSuffix + "/" + apiMethod
                
        AF.request(url, method: .get, parameters: param).responseJSON { response in
            completion?(response)
        }
    }
    
    // MARK: Проверка токена на валидность
    public func checkToken (token: String, complition: @escaping (Bool) -> Void) {
        if !token.isEmpty {
            let param: Parameters = [
                "client_id": self.ClientID,
                "client_secret": self.ClientSecret,
                "token": token,
                "v": self.APIVersion
            ]
            
            VK.shared.setCommand("secure.checkToken", param: param) { response in
                switch response.result {
                case let .success(data):
                    let json = JSON(data)
                    
                    if json["response"]["success"].intValue == 1 {
                        complition(true)
                    } else {
                        complition(false)
                    }
                    
                case .failure(_):
                    complition(false)
                }
            }
        } else {
            complition(false)
        }
    }
    
    // MARK: Поиск по группам
    public func getGroupSearch(query: String, complition: @escaping (Result<[Group], Error>) -> Void) {
        let token = AppSession.shared.getToken()
        var List = [Group]()
        
        if !token.isEmpty {
            let param: Parameters = [
                "access_token": token,
                "user_id": AppSession.shared.getUserId(),
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
    public func getGroupsList(complition: ((Result<[Group], Error>) -> Void)? = nil) {
        let token = AppSession.shared.getToken()
        var List = [Group]()
        
        if !token.isEmpty {
            let param: Parameters = [
                "access_token": token,
                "user_id": AppSession.shared.getUserId(),
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
                            do {
                                // Попытаемся загрузить друзей
                                let realmGroups = try RealmService.get(Group.self)
                                
                                // В случае, если запись есть в базе, то ее нужно будет
                                // обновить, а для этого нужно запустить транзакцию
                                // а для этого ружен realm
                                let realm = try RealmService.service()
                                
                                try realm.write {
                                    for group in json["response"]["items"].arrayValue {
                                        if let id = group["id"].int,
                                            let name = group["name"].string,
                                            let photo = group["photo_50"].string {
                                        
                                            let groupToAdd = Group(groupId: id, name: name, image: photo)
                                            List.append(groupToAdd)
                                            
                                            // Записываем инфу только если её нет в базе
                                            if realmGroups.count > 0,
                                                let rObj = realmGroups.filter("groupId=\(id)").first {
                                                
                                                if rObj.name != name {
                                                    rObj.name = name
                                                }
                                                
                                                if rObj.imageString != photo {
                                                    rObj.imageString = photo
                                                }
                                                
                                            } else {
                                                realm.add(groupToAdd, update: Realm.UpdatePolicy.modified)
                                            }
                                        }
                                    }
                                }
                                
                            } catch let error {
                                 complition?(.failure(error))
                            }

                            complition?(.success(List))
                        }
                    case let .failure(error):
                        complition?(.failure(error))
                    break
                }
            }
        }
    }
    
    // MARK: Загрузка фото
    func getPhotosByFriendId(friendId: Int, complition: ((_ data: Result<[Photo], Error>) -> Void)? = nil){
        let token = AppSession.shared.getToken()
        var List = [Photo]()
        
        if !token.isEmpty {
            let param: Parameters = [
                "access_token": token,
                "owner_id": friendId,
                "extended": 1,
                "need_hidden": 0,
                "skip_hidden": 1,
                "v": VK.shared.APIVersion
            ]
            
            VK.shared.setCommand("photos.getAll", param: param) { response in
                switch response.result {
                case let .success(data):
                    let json = JSON(data)
                    
                    if json["response"]["count"] > 0 {
                        do {
                            // Записываем все полученные данные
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
                                
                                // Создаем экземпляр объекта фото
                                let pObject = Photo(friendID: friendId, photoId: id, photo: photo, likes: likes, liked: liked, date: date)
                                
                                // Все данные получены инициализируем класс фото
                                List.append(pObject)
                                
                                // Записываем данные в реалм
                                try RealmService.save(items: pObject.self)
                            }
                            
                        
                            // Что-то нашли - запускаем замыкание
                            complition?(.success(List))
                            
                        } catch let err {
                            complition?(.failure(err))
                        }
                    }
                case let .failure(err):
                    complition?(.failure(err))
                }
            }
        }
        
    }
    
    // MARK: Парсинг JSON друзей
    private func parseFriend(from json: JSON) -> [Friend]? {
        var List = [Friend]()
        
        if json["response"]["count"].int != nil {
            guard let friendItem = json["response"]["items"].array else { return nil }
            
            do {
                let realm = try RealmService.service()
                
                // Попытаемся загрузить друзей
                let realmFriends = try RealmService.get(Friend.self)
                
                // Начинаем транзакцию на запись
                try realm.write {
                    // Перебираем друзей и инициализируем массив
                    for friend in friendItem {
                        // Все данные есть - можно заполнять
                        if let firstName = friend["first_name"].string,
                            let lastName = friend["last_name"].string,
                            let id = friend["id"].int,
                            let avatar = friend["photo_50"].string,
                            friend["deactivated"].stringValue != "deleted"
                        {
                            let cityName = friend["city"]["title"].stringValue
                            
                            let friendToAdd = Friend(userId: id, photo: avatar, name: firstName + " " + lastName, city: cityName)
                            List.append(friendToAdd)
                            
                            // Запишем в realm, но только если такой записи там еще нет
                            if realmFriends.count > 0,
                                let rObj = realmFriends.filter("userId=\(id)").first {
                                
                                if rObj.city != cityName {
                                    rObj.city = cityName
                                }
                                
                                if rObj.photo != avatar {
                                    rObj.photo = avatar
                                }
                                
                                if rObj.name != firstName + " " + lastName {
                                    rObj.name = firstName + " " + lastName
                                }
                            } else {
                                realm.add(friendToAdd.self)
                            }
                        }
                    }
                }
                
            } catch {
                print("ParseFriend: Realm crached")
            }
        }
        
        return List
    }
    
    // MARK: Загрузка друзей
    public func getFriendsList(completion: (([Friend]?, Error?) -> Void)? = nil) {
        let token = AppSession.shared.getToken()
        
        if !token.isEmpty {
            let param: Parameters = [
                "access_token": token,
                "order": "hints",
                "v": VK.shared.APIVersion,
                "fields":"nickname,photo_50,city"
            ]
            
            // Получаем данные
            VK.shared.setCommand("friends.get", param: param) { response in
                switch response.result {
                case let .success(data):
                    let json = JSON(data)
                    let friendList = VK.shared.parseFriend(from: json)
                        completion?(friendList, nil)
                    
                case let .failure(error):
                    completion?(nil, error)
                }
                
            }
        }
    }
    
    public func parseNews(from json: JSON, complition: @escaping ([News]) -> Void) {
        // Массив со списком источникв
        var sourceList = [Int:[[String:String]]]()
        
        // Результат парсинга json
        var NewsList = [News]()
        
        guard let items = json["response"]["items"].array else { return complition(NewsList) }
        
        // Группа для обработки профиля и групп
        let parsingDataGroupDispatch = DispatchGroup()
        
        // Новостей нет - дальше нет смысла смотреть
        if items.count == 0 {
            complition(NewsList)
        }
        
        // Закинем разбор групп и профилей в отдельный поток
        DispatchQueue.global().async(group: parsingDataGroupDispatch) {
            // Вернулся список групп
            if let groups = json["response"]["groups"].array,
                groups.count > 0 {
                
                for group in groups {
                    if let gID = group["id"].int,
                        let gName = group["name"].string,
                        let gAvatar = group["photo_50"].string
                    {
                        
                        sourceList[gID] = [["name": gName], ["avatar": gAvatar]]
                    }
                }
            }
            
            // Вернулся список профилей - источников новостей
            if let profiles = json["response"]["profiles"].array,
                profiles.count > 0 {
                
                for profile in profiles {
                    if let pID = profile["id"].int,
                        let pFirstName = profile["first_name"].string,
                        let pLastName = profile["last_name"].string,
                        let pAvatar = profile["photo_50"].string
                    {
                        sourceList[pID] = [["name": pFirstName + " " + pLastName], ["avatar": pAvatar]]
                    }
                }
            }
        }
        
        // Для сбора новостей заведем отдельный поток
        let parsingNewsDispatchGroup = DispatchQueue(label: "parsingNewsQueue")
        
        parsingDataGroupDispatch.notify(queue: parsingNewsDispatchGroup) {
            // Сформируем список новостей
            for item in items {
                if var sourceId = item["source_id"].int,
                    let date = item["date"].double,
                    let text = item["text"].string,
                    !text.isEmpty
                {
                    // Название новости - это паблик или профиль. По-умолчанию будет "Без названия" - дальше переопределим в случае успеха
                    var title = "Без названия"
                    var avatar: String?
                    var picture: String?
                    
                    // если источник < 0 - это группа
                    if sourceId < 0 {
                        // Для поиска в списке истоников нужно положительное число
                        sourceId = sourceId * -1
                        
                        if let sObj = sourceList[sourceId],
                            let sName = sObj[0]["name"],
                            let sAvatar = sObj[1]["avatar"] {
                            
                            title = sName
                            avatar = sAvatar
                        }
                    }
                    
                    if let attachments = item["attachments"].array {
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
                    
                    // Лайки просмотры комментарии
                    let likes = item["likes"]["count"].int ?? 0
                    let isLiked = (item["likes"]["user_likes"].intValue == 0 ? false : true)
                    let comments = item["comments"]["count"].int ?? 0
                    let views = item["views"]["count"].int ?? 0
                    let shared = item["reposts"]["count"].int ?? 0
                    
                    let humanDate = Date(timeIntervalSince1970: date)
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeStyle = .none //Set time style
                    dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
                    dateFormatter.timeZone = .current
                    let localDate = dateFormatter.string(from: humanDate)
                    
                    // Заполняем список новостей
                    NewsList.append(News(title: title, content: text, date: localDate, picture: picture, likes: likes, views: views, comments: comments, shared: shared, isLiked: isLiked, avatar: avatar))
                }
            }
            
            // Комплишен нужно вызывать в основном потоке - иначе будет ошибка (с обновлением TableView)
            DispatchQueue.main.async {
                complition(NewsList)
            }
        }
    }
    
    // MARK: Загрузка новостей
    public func getNewsList(completion: @escaping (([News]?, Error?) -> Void) ) {
        let token = AppSession.shared.getToken()
        
        if !token.isEmpty {
            let param: Parameters = [
                "access_token": token,
                "filters": "post",
                "return_banned": 0,
                "count": 20,
                "v": VK.shared.APIVersion,
                "fields":"nickname,photo_50"
            ]
            
            // Получаем данные
            VK.shared.setCommand("newsfeed.get", param: param) { response in
                switch response.result {
                case let .success(data):
                    let json = JSON(data)
                    
                    self.parseNews(from: json) { NewsList in
                        completion(NewsList, nil)
                    }
                    
                case let .failure(error):
                    completion(nil, error)
                }
                
            }
        }
    }
}
