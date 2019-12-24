//
//  Session.swift
//  weather
//
//  Created by Григорий Мартюшин on 30.11.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import Alamofire
import RealmSwift

class AppSession: Object {
    // Токен и userID можно получать только с сервере
    // в любой части приложения их можно либо получить
    // через getter's ниже, либо через новый запрос к
    // серверу
    private var token: String? {
        get {
            return self.access_token
        }
        set (value) {
            self.access_token = value
        }
    }
    
    @objc dynamic var id: String = UUID.init().uuidString
    @objc dynamic private var access_token: String?
    @objc dynamic var userId: Int = 0
    @objc dynamic var userAvatar: String?
    @objc dynamic var userName: String?
    @objc dynamic var userNickName: String?
    
    static let shared = AppSession()
    
    required init () { }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    func getCacheData() -> Bool {
        do {
            let realm = try Realm()
            let sessData = realm.objects(AppSession.self)
            
            if sessData.count > 0 {
                // В базе есть данные не нужно делать запрос!
                if sessData[0].userId != 0,
                    let userAvatar = sessData[0].userAvatar,
                    let userName = sessData[0].userName,
                    let userNickName = sessData[0].userNickName {
                
                    self.userId = sessData[0].userId
                    self.userAvatar = userAvatar
                    self.userName = userName
                    self.userNickName = userNickName
                    return true
                }
            }
            
        } catch let err {
            print("Realm crashed: \(err)")
        }
        
        return false
    }
    
    func getUserInfo () {
        if (self.getCacheData() == false && self.token != nil) {
            let parameters: Parameters = [
                "access_token": self.token!,
                "order": "hints",
                "v": VK.shared.APIVersion,
                "fields":"nickname,photo_50"
            ]
            
            // Получим информацию о пользователе
            VK.shared.setCommand("users.get", param: parameters) { response in
                switch response.result {
                case .success(_):
                    if let data = response.data {
                        let decoder = JSONDecoder()
                        
                        do {
                            
                            let realm = try Realm()
                            realm.beginWrite()
                            
                            let user_info = try decoder.decode(Users.self, from: data)
                            self.access_token = self.token
                            self.userId = user_info.response[0].id
                            self.userAvatar = user_info.response[0].avatar
                            self.userName = user_info.response[0].firstName + " " + user_info.response[0].lastName
                            self.userNickName = user_info.response[0].nickname
                            realm.add(self)
                            try realm.commitWrite()
                            
                        } catch {
                            break
                        }
                    }
                    
                case .failure(_):
                    break
                }
            }
        }
    }
    
    func setToken (token: String){
        do {
            let realm = try Realm()
            realm.beginWrite()
            self.token = token
            try realm.commitWrite()
        } catch {
            print("Realm crashed")
        }
        
        self.getUserInfo()
    }
    
    func logout (){
        do {
            let realm = try Realm()
            let result = realm.objects(AppSession.self).filter("userId = \(self.userId)")
            
            realm.beginWrite()
            
            self.token = nil
            self.userId = 0
            self.userAvatar = nil
            self.userNickName = nil
            self.userName = nil
            
            realm.delete(result)
            
            realm.add(self)
            try realm.commitWrite()
            
        } catch let err {
            print("logout: Realm error \(err)")
        }
    }
    
    func getUserId() -> Int {
        return self.userId
    }
    
    func getToken() -> String {
        do {
            let realm = try Realm()
            let result = realm.objects(AppSession.self)
            
            // Нашли данные сессии в базе
            if result.count > 0 {
                if let token = result.first?.token,
                    token != self.token{
                    self.setToken(token: token)
                }
            }
            
        } catch {
            print("getToken: Realm crashed")
        }
        
        return self.token ?? ""
    }
}
