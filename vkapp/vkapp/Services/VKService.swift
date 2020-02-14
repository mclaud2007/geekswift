//
//  VKService.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 26.01.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import PromiseKit

class VKService {
    private let vkAPIUrl = "api.vk.com"
    private let vkAPIUriSuffix = "/method"
    let vkAPIVersion = "5.103"
    
    private let vkOAuthURL = "oauth.vk.com"
    private let vkOAuthUriSuffix = "/authorize"
    private let vkOAuthBackLink = "https://oauth.vk.com/blank.html"
    
    private let vkAPISchema = "https"
    private let vkClientID = "7238798"
    private let vkClientSecret = "FkU2VoEQb7vVr5esriPQ"
    
    // Седалем синглтоном
    static let shared = VKService()
    
    enum VKError: Error {
        case FriendListIsEmpty
        case PhotosListIsEmpty
        case GroupsListIsEmpty
        case GroupsNotFound
    }
    
    public func parseNews(from json: JSON, complition: @escaping ([News]) -> Void) {
        // Массив со списком источникв
        var groupList = [Group]()
        var usersList = [Friend]()
        
        // Результат парсинга json
        var NewsList = [News]()
        
        guard let items = json["response"]["items"].array else { return complition(NewsList) }
        
        // Группа для обработки профиля и групп
        let parseNewsSourceDispatch = DispatchGroup()
        
        // Новостей нет - дальше нет смысла смотреть
        if items.count == 0 {
            complition(NewsList)
        }
        
        // Закинем разбор групп и профилей в отдельный поток
        DispatchQueue.global().async(group: parseNewsSourceDispatch) {
            // Вернулся список групп
            if let groups = json["response"]["groups"].array,
                groups.count > 0 {
                
                for group in groups {
                    if let _ = group["id"].int,
                        let _ = group["name"].string,
                        let _ = group["photo_50"].string
                    {
                        
                        groupList.append(Group(from: group))
                    }
                }
            }
        }
            
        DispatchQueue.global().async(group: parseNewsSourceDispatch) {
            // Вернулся список профилей - источников новостей
            if let profiles = json["response"]["profiles"].array,
                profiles.count > 0 {
                
                for profile in profiles {
                    if let pID = profile["id"].int,
                        let pFirstName = profile["first_name"].string,
                        let pLastName = profile["last_name"].string,
                        let pAvatar = profile["photo_50"].string
                    {
                        usersList.append(Friend(userId: pID, photo: pAvatar, name: pFirstName + " " + pLastName))
                    }
                }
            }
        }
        
        parseNewsSourceDispatch.notify(queue: DispatchQueue.main) {
            // Сформируем список новостей
            for item in items {
                if let _ = item["source_id"].int,
                    let _ = item["date"].double,
                    let text = item["text"].string,
                    !text.isEmpty
                {
                    NewsList.append(News(json: item, groups: groupList, profiles: usersList))
                }
            }
            
            // Возвращаем список новостей в комплишен
            complition(NewsList)
        }
    }
    
    public func getNewsList(startFrom: String? = nil, startTime: Double? = nil, completion: @escaping ((Swift.Result<[News], Error>, String?) -> Void) ) {
        var param: Parameters = [
            "filters": "post",
            "return_banned": 0,
            "count": 50,
            "fields":"nickname,photo_50"
        ]
        
        if let startFrom = startFrom {
            param["start_from"] = startFrom
        }
        
        if let startTime = startTime {
            param["start_time"] = startTime
        }
        
        // Получаем данные
        VKService.shared.setCommand("newsfeed.get", param: param) { response in
            switch response.result {
            case let .success(data):
                let json = JSON(data)
                
                self.parseNews(from: json) { NewsList in
                    completion(.success(NewsList), json["response"]["next_from"].string)
                }
                
            case let .failure(error):
                completion(.failure(error), nil)
            }
        }
    }
    
    public func getGroupSearch(query: String, complition: @escaping (Swift.Result<[Group], Error>) -> Void) {
        var localGroupList = [Group]()
        
        let param: Parameters = [
            "user_id": AppSession.shared.getUserId(),
            "type": "group",
            "q": query,
            "count": 10,
        ]
        
        VKService.shared.setCommand("groups.search", param: param) { response in
            switch response.result {
            case let .success(data):
                let json = JSON(data)
                
                // что-то нашли
                if (json["response"]["count"].intValue > 0){
                    for group in json["response"]["items"].arrayValue {
                        if group["id"].int != nil,
                            group["name"].string != nil,
                            group["photo_50"].string != nil {
                            
                            localGroupList.append(Group(from: group))
                        }
                    }
                    
                    if localGroupList.count > 0 {
                        complition(.success(localGroupList))
                    } else {
                        complition(.failure(VKError.GroupsNotFound))
                    }
                } else {
                    complition(.failure(VKError.GroupsNotFound))
                }
            case let .failure(error):
                complition(.failure(error))
            }
        }
        
    }
    
    public func getGroupsList(complition: ((Swift.Result<[Group], Error>) -> Void)? = nil) {
        let param: Parameters = [
            "user_id": AppSession.shared.getUserId(),
            "extended": 1,
            "fields": "photo_50,name"
        ]
        
        let op = GetDataOperation(method: "groups.get", param: param)
        let opq = OperationQueue()
        opq.addOperation(op)
        
        let parse = ParseData()
        parse.addDependency(op)
        
        parse.completionBlock = {
            if parse.outputData.count > 0 {
                complition?(.success(parse.outputData))
            } else {
                complition?(.failure(VKError.GroupsListIsEmpty))
            }
        }
        
        opq.addOperation(parse)
    }
    
    // Получаем нужные нам размеры фото из атачмента
    func getPhotoMaxSizeFrom(attachments: [JSON]) -> JSON? {
        let attacheTypeToSearch = ["photo", "link", "video", "doc"]
        var attache: JSON?
        var pSizes: [JSON]?
        
        for i in 0..<attacheTypeToSearch.count {
            if let attacheTest = attachments.filter({ $0["type"].stringValue == attacheTypeToSearch[i] }).first {
                attache = attacheTest
                break
            }
        }
        
        // Ищем массив с размерами
        if let attache = attache {
            switch attache["type"].stringValue {
            case "photo":
                pSizes = attache["photo"]["sizes"].arrayValue
            case "video":
                pSizes = attache["video"]["image"]["sizes"].arrayValue
            case "link":
                pSizes = attache["link"]["photo"]["sizes"].arrayValue
            case "doc":
                pSizes = attache["doc"]["preview"]["photo"]["sizes"].arrayValue
            default:
                break
            }
        }
        
        // Массив размеров найден
        if let sizes = pSizes,
            let photoMaxSize = VKService.shared.getPhotoMaxSizeFrom(sizes: sizes)
        {
            return photoMaxSize
        }
    
        return nil
    }
    
    // Получаем нужные нам размеры фото
    func getPhotoMaxSizeFrom(sizes: [JSON]) -> JSON? {
        if sizes.count > 0 {
            //let neededSizes = ["m", "x", "p", "q", "r", "y"]
            
            // Возвращаем максимально доступный размер фотографии
            return sizes.sorted { (first, second) -> Bool in
                
                if first["width"].intValue > second["width"].intValue {
                    return true
                } else {
                    return false
                }
            }.first
        }
        
        return nil
    }
    
    // Загружаем фотографии пользователя
    func getPhotosBy(friendId: Int, completion: ((Swift.Result<[Photo], Error>) -> Void)? = nil){
        var localPhotoList = [Photo]()
    
        let param: Parameters = [
            "owner_id": friendId,
            "extended": 1,
            "need_hidden": 0,
            "skip_hidden": 1,
            "count": 200
        ]
        
        // Запрашиваем все фотографии пользователя
        VKService.shared.setCommand("photos.getAll", param: param) { response in
            switch response.result {
            case let .success(data):
                let json = JSON(data)
                
                if json["response"]["count"].intValue > 0 {
                    for photo in json["response"]["items"].arrayValue {
                        if let pID = photo["id"].int,
                            let date = photo["date"].int,
                            let sizes = photo["sizes"].array,
                            let photoMaxSizesURL = self.getPhotoMaxSizeFrom(sizes: sizes),
                            let photoURL = photoMaxSizesURL["url"].string
                        {
                            let likes = photo["likes"]["count"].int ?? -1
                            let liked = photo["likes"]["user_likes"] == 0 ? false : true
                            
                            localPhotoList.append(Photo(friendID: friendId, photoId: pID, photo: photoURL, likes: likes, liked: liked, date: date))
                            
                        }
                    }
                    
                    // Что-то таки нашли
                    if localPhotoList.count > 0 {
                        completion?(.success(localPhotoList))
                    } else {
                        completion?(.failure(VKError.PhotosListIsEmpty))
                    }
                } else {
                    completion?(.failure(VKError.PhotosListIsEmpty))
                }
            case let .failure(err):
                completion?(.failure(err))
            }
        }
    }
    
    // Загрузука списка друзей
    public func getFriendsList() -> Promise<JSON> {
        return Promise { seal in
            let param: Parameters = [
                "order": "hints",
                "fields":"nickname,photo_50,city"
            ]
            // Получаем данные
            VKService.shared.setCommand("friends.get", param: param) { response in
                switch response.result {
                case let .success(data):
                    seal.fulfill(JSON(data))
                    
                case let .failure(error):
                    seal.reject(error)
                }
            }
        }
    }
    
    // MARK: Проверка токена на валидность
    public func checkToken (token: String?, complition: @escaping (Bool) -> Void) {
        // Если токена нет, то смысла дальше продолжать тоже
        if token == nil {
            complition(false)
        }
        
        // Для првоерки токена требуются доп. параметры
        let param: Parameters = [
            "client_id": self.vkClientID,
            "client_secret": self.vkClientSecret,
            "v": self.vkAPIVersion,
            "token": token!
        ]
        
        VKService.shared.setCommand("secure.checkToken", param: param) { response in
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
    }
    
    // Добавление обязательных пареметров, которые требуются в каждом вызове
    public func appSysParam(_ param: Parameters?) -> Parameters? {
        // Проверим есть ли токен
        guard let token = AppSession.shared.getToken() else { return param }
        
        var newParam = param
        
        if newParam?["access_token"] == nil {
            newParam!["access_token"] = token
        }
        
        if newParam?["v"] == nil {
            newParam!["v"] = self.vkAPIVersion
        }
        
        return newParam
    }
    
    // Отправка комманда к апи
    public func setCommand (_ apiMethod: String, param: Parameters?, completion: ((AFDataResponse<Any>) -> Void)? ) {
        let url = self.vkAPISchema + "://" + self.vkAPIUrl + self.vkAPIUriSuffix + "/" + apiMethod
        
        // Генерируем запрос
        AF.request(url, method: .get, parameters: (apiMethod != "secure.checkToken" ? appSysParam(param) : param)).responseJSON { response in
            completion?(response)
        }
    }
    
    public func getOAuthRequest () -> URLRequest {
        // Готовим запрос
        var urlComponents = URLComponents()
        urlComponents.scheme = self.vkAPISchema
        urlComponents.host = self.vkOAuthURL
        urlComponents.path = self.vkOAuthUriSuffix
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: self.vkClientID),
            URLQueryItem(name: "display", value: "mobile"),
            URLQueryItem(name: "redirect_url", value: vkOAuthBackLink),
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "scope", value: "wall,photos,offline,friends,stories,status,groups")
        ]
        
        return URLRequest(url: urlComponents.url!)
    }
}
