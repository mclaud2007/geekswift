//
//  VKService.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 01.05.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation

class VKService {
    private let vkApiUrlString = "api.vk.com"
    private let vkAPIUriSuffix = "/method"
    private let vkAPIVersion = "5.103"
    
    private let vkAPISchema = "https"
    private let vkClientID = "7503380"
    private let vkClientSecret = "34RFFYCFu7tVqp7Kjn1B"
    
    // Полный адрес для запроса методов АПИ
    private lazy var vkApiUrlComponents: URLComponents = {
        let session = VKService.shared.session
            
        var url = URLComponents()
        url.scheme = VKService.shared.vkAPISchema
        url.host = VKService.shared.vkApiUrlString
        
        // Если токена нет - все тлен, выбьем ошибку авторизации при вызове АПИ
        guard let token = session.token else { return url }
        
        // Список дефолтных параметров, которые должны быть всегда
        url.queryItems = [
            URLQueryItem(name: "access_token", value: token),
            URLQueryItem(name: "v", value: VKService.shared.vkAPIVersion)
        ]
        
        return url
    }()
    
    // Параметры запроса формы входа
    private let vkOAuthURL = "oauth.vk.com"
    private let vkOAuthUriSuffix = "/authorize"
    private let vkOAuthBackLink = "https://oauth.vk.com/blank.html"
    private let vkOauthScope = "wall,photos,offline,friends,stories,status,groups"
    private let vkOauthTimeout = 10.0
    
    // Полный адрес для запроса авторизации
    private lazy var vkOAuthUrlComponents: URLComponents = {
        var url = URLComponents()
        url.scheme = VKService.shared.vkAPISchema
        url.host = VKService.shared.vkOAuthURL
        url.path = VKService.shared.vkOAuthUriSuffix
        url.queryItems = [
            URLQueryItem(name: "client_id", value: VKService.shared.vkClientID),
            URLQueryItem(name: "display", value: "mobile"),
            URLQueryItem(name: "redirect_url", value: VKService.shared.vkOAuthBackLink),
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "scope", value: VKService.shared.vkOauthScope)
        ]
        
        return url
    }()
    
    // Седалем синглтоном
    static let shared = VKService()
    
    // Данные сессии
    private let session = AppSession.shared
    
    // Служба сети
    private let network = NetworkService(configuration: nil)
    
    // Список возможных ошибок сервиса
    enum VKError: Error {
        case FriendListIsEmpty
        case PhotosListIsEmpty
        case GroupsListIsEmpty
        case GroupsNotFound
        case NewsListEmpty
        case EmptyURL
        case NoToken
        case UserNotFound
        case UserIdNotFoundInSession
    }
    
    // Получение списка новостей
    func getNewsList(startFrom: String? = nil, startTime: Double? = nil, completion: @escaping ((Result<[News], Error>, String?) -> Void) )  {
        var param = [
            URLQueryItem(name: "filters", value: "post"),
            URLQueryItem(name: "return_banned", value: "0"),
            URLQueryItem(name: "count", value: "50"),
            URLQueryItem(name: "fields", value: "nickname,photo_50")
        ]
        
        if let _ = startFrom {
            param.append(URLQueryItem(name: "start_from", value: startFrom))
        }
        
        if let startTime = startTime {
            param.append(URLQueryItem(name: "start_time", value: String(startTime)))
        }
        
        // Готовим адрес для загрузки данных
        if let rURI = VKService.shared.getApiMethodRequest("newsfeed.get", param: param),
            let url = rURI.url
        {
            // Запускаем запрос
            network.getDataFrom(url: url) { response in
                switch response {
                case .success(let data):
                    if let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: []),
                        let jsonArray = jsonObject as? [String: Any],
                        let response = jsonArray["response"] as? [String: Any]
                    {
                        if let news = response["items"] as? [[String: Any]] {
                            var groupList = [Group]()
                            var profilesList = [Friend]()
                            
                            if let groups = response["groups"] as? [[String: Any]] {
                                groupList = groups.map { Group(from: $0) }
                            }
                            
                            if let profiles = response["profiles"] as? [[String: Any]] {
                                profilesList = profiles.map { Friend(from: $0) }
                            }
                        
                            let newsList = news.map { News(from: $0, groups: groupList, profiles: profilesList) }
                            let nextFrom = response["next_from"] as? String
                            
                            completion(.success(newsList), nextFrom)
                        } else {
                            completion(.failure(VKError.NewsListEmpty), nil)
                        }
                    } else {
                        completion(.failure(VKError.NewsListEmpty), nil)
                    }
                    
                    
                    break
                case .failure(let err):
                    completion(.failure(err), nil)
                    break;
                }
            }
        }
    }
        
    // Получение информации о пользователи
    func getUserInfo(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let userInfoParam = [URLQueryItem(name: "fields", value: "nickname,photo_50")];
        
        // Готовим адрес для запроса данных
        if let rURI = VKService.shared.getApiMethodRequest("users.get", param: userInfoParam),
            let url = rURI.url
        {
            // Запускаем запрос на выполнение
            network.getDataFrom(url: url) { result in
                switch result {
                case .success(let data):
                    if let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: []) {
                        if let jsonArray = jsonObject as? [String: Any],
                            let response = jsonArray["response"] as? [[String: Any]],
                            let userInfo = response.first
                        {
                            completion(.success(userInfo))
                        }
                    } else {
                        completion(.failure(VKError.UserNotFound))
                    }
                    
                    break
                case .failure(_):
                    completion(.failure(VKError.UserNotFound))
                    break
                }
            }
            
        } else {
            completion(.failure(VKError.EmptyURL))
        }
    }
    
    // Поиск групп по ключевому слову
    func getGroupListBy(query: String, completion: @escaping (Result<[Group], Error>) -> Void) {
        let param = [
            URLQueryItem(name: "user_id", value: String(session.userId)),
            URLQueryItem(name: "type", value: "group"),
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "count", value: "10"),
        ]
        
        if let rURI = VKService.shared.getApiMethodRequest("groups.search", param: param),
            let url = rURI.url
        {
            // Выполняем запрос
            network.getDataFrom(url: url) { result in
                switch result {
                case .success(let data):
                    // Разбираем пришедшие данные как JSON
                    if let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: []),
                        
                        // закастим главный объект как словарь
                        let jsonRootObject = jsonResult as? [String: Any],
                        
                        // В нем найдем массив с ответом
                        let jsonResponse = jsonRootObject["response"] as? [String: Any],
                        
                        // Общее количество найденых групп
                        let totalGroups = jsonResponse["count"] as? Int,
                        totalGroups > 0,
                        
                        // Непосредственно сами группы
                        let groups = jsonResponse["items"] as? [[String: Any]]
                    {
                        let groupsList = groups.map { Group(from: $0) }
                        completion(.success(groupsList))
                    }
                    
                    break
                case .failure(let err):
                    completion(.failure(err))
                    break
                }
            }
        }
    }
    
    // Получения списка групп пользователя
    func getGroupList(completion: @escaping (Result<[Group], Error>) -> Void) {
        let param = [
            URLQueryItem(name: "user_id", value: String(session.userId)),
            URLQueryItem(name: "extended", value: "1"),
            URLQueryItem(name: "fields", value: "photo_50,name")
        ]
        
        if let rURI = VKService.shared.getApiMethodRequest("groups.get", param: param),
            let url = rURI.url
        {
            // Выполняем запрос
            network.getDataFrom(url: url) { response in
                switch response {
                case .success(let data):
                    // Первоначальный разбор вернувшегося JSON
                    if let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: []),
                        let jsonRootObject = jsonResult as? [String: Any],
                         
                        // Верхний уровень - массив response
                        let jsonResponse = jsonRootObject["response"] as? [String: Any],
                        
                        // Общее количество вернувщихся щаписей,
                        let totalGroups = jsonResponse["count"] as? Int,
                        
                        // .. если их ноль то вернем ошибку
                        totalGroups > 0,
                        
                        // Непосередственно сам список групп
                        let groups = jsonResponse["items"] as? [[String: Any]]
                    {
                        let groupList = groups.map { Group(from: $0) }
                        completion(.success(groupList))
                    } else {
                        completion(.failure(VKError.GroupsListIsEmpty))
                    }
                    
                    break
                    
                case .failure(let err):
                    completion(.failure(err))
                    break
                }
            }
        } else {
            completion(.failure(VKError.EmptyURL))
        }
    }
    
    func getPhotosBy(friendId: Int, completion: ((Result<[Photo], Error>) -> Void)? = nil) {
        let param = [
            URLQueryItem(name: "owner_id", value: String(friendId)),
            URLQueryItem(name: "extended", value: "1"),
            URLQueryItem(name: "need_hidden", value: "0"),
            URLQueryItem(name: "skip_hidden", value: "1"),
            URLQueryItem(name: "count", value: "200")
        ]
        
        if let rURI = VKService.shared.getApiMethodRequest("photos.getAll", param: param),
            let url = rURI.url
        {
            // Выполняем запрос
            network.getDataFrom(url: url) { result in
                switch result {
                case .success(let data):
                    // Пытаемся разобрать вернувшийся json
                    if let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: []),
                        // Кастим объект как словарь
                        let jsonRootObject = jsonResult as? [String: Any],
                        
                        // Корневой уровень ответа
                        let jsonResponse = jsonRootObject["response"] as? [String: Any],
                        
                        // Общее количество фотографий
                        let totalPhotos = jsonResponse["count"] as? Int,
                        
                        // если их нет, то дальше идти нет смысл
                        totalPhotos > 0,
                        
                        // Непосредственно список фотогрфаий
                        let photos = jsonResponse["items"] as? [[String: Any]]
                    {
                        let photosList = photos.map { Photo(from: $0) }
                        completion?(.success(photosList))
                    } else {
                        completion?(.failure(VKError.PhotosListIsEmpty))
                    }
                    
                    break
                case .failure(let err):
                    completion?(.failure(err))
                    break
                }
            }
        }
    }
    
    // Получение списка друзей
    func getFriendsList(completion: @escaping (Result<[Friend], Error>) -> Void) {
        let param = [
            URLQueryItem(name: "order", value: "hints"),
            URLQueryItem(name: "fields", value: "nickname,photo_50,city,occupation,bdate")
        ]
        
        // Получаем данные
        if let rURI = VKService.shared.getApiMethodRequest("friends.get", param: param),
            let url = rURI.url
        {
            network.getDataFrom(url: url) { result in
                switch result {
                case .success(let data):
                    // Пытаемся разобрать полученный json
                    if let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: []),
                        
                        // Кастим объект как словарь
                        let jsonRootObject = jsonResult as? [String: Any],
                        
                        // Верхний уровень
                        let jsonResponse = jsonRootObject["response"] as? [String: Any],
                        
                        // Количество друзей
                        let totalFriends = jsonResponse["count"] as? Int,
                        
                        // если их 0, то разбирать не нужно
                        totalFriends > 0,
                        
                        // Список друзей
                        let friends = jsonResponse["items"] as? [[String: Any]]
                    {
                        let friendList = friends.map { Friend(from: $0) }
                        completion(.success(friendList))
                    }
                    
                    break
                case .failure(let err):
                    completion(.failure(err))
                    break
                }
            }
            
        } else {
            completion(.failure(VKError.EmptyURL))
        }
    }
    
    // MARK: Проверка токена на валидность
    func checkToken (token: String?, complition: @escaping (Bool) -> Void) {
        // Если токена нет, то смысла дальше продолжать тоже
        if token == nil {
            complition(false)
        }

        // Для првоерки токена требуются доп. параметры
        let param = [
            URLQueryItem(name: "client_id", value: self.vkClientID),
            URLQueryItem(name: "client_secret", value: self.vkClientSecret),
            URLQueryItem(name: "token", value: token!),
            URLQueryItem(name: "v", value: self.vkAPIVersion)
        ]
        
        // Выполняем запрос к АПИ на проверку токена
        if let rURI = VKService.shared.getApiMethodRequest("secure.checkToken", param: param),
            let url = rURI.url
        {
            network.getDataFrom(url: url) { result in
                switch result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    
                    if let response = try? decoder.decode(TokenCheck.self, from: data!) {
                        if response.item.success == 1 {
                            complition(true)
                        }
                    } else {
                        complition(false)
                    }
                    
                    break
                case .failure(_):
                    complition(false)
                    break
                }
            }
            
        } else {
            complition(false)
        }
    }
    
    // Если удалось восстановить сессию из БД - проверим токен на валидность
    // В противном случае в замыкании вызывается WebKit с запросом доступа
    func getCheckLogedIn(complition: @escaping (Bool) -> Void) {
        // Если токен не определен, то возрващаем ошибку
        if let token = session.token {
            // В противном случае проверим его на корректность
            VKService.shared.checkToken(token: token, complition: complition)
            
        } else {
            complition(false)
        }
    }
    
    // Просто подготовка адреса для запроса ключа авторизации
    func getOAuthRequest() -> URLRequest {
        // Готовим запрос
        let urlComponents = self.vkOAuthUrlComponents
        return URLRequest(url: urlComponents.url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: vkOauthTimeout)
    }
    
    // Просто подготовка адреса для запроса метода АПИ
    private func getApiMethodRequest(_ apiMethod: String, param: [URLQueryItem]?) -> URLComponents? {
        // Адрес запроса состоит из общей части
        var url = self.vkApiUrlComponents
        
        // И кстомного пути
        url.path = self.vkAPIUriSuffix + "/" + apiMethod
        
        // Для запроса всегда нужен токен!
        guard let _ = session.token else { return nil }
        
        // Небольшой говнокод, для метода проверки токена параметры должны перезаписать дефолтные
        if let param = param {
            if apiMethod == "secure.checkToken" {
                url.queryItems = param
                
            } else {
                for item in param {
                    url.queryItems?.append(item)
                }
            }
        }
        
        return url
    }
}
