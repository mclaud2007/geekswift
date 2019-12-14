//
//  Session.swift
//  weather
//
//  Created by Григорий Мартюшин on 30.11.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import Foundation
import Alamofire

class Session {
    // Токен и userID можно получать только с сервере
    // в любой части приложения их можно либо получить
    // через getter's ниже, либо через новый запрос к
    // серверу
    private var token: String? {
        didSet {
            self.getUserInfo()
        }
    }
    
    private var userId: Int?
    private var userAvatar: String?
    private var userName: String?
    private var userNickName: String?
    
    static let shared = Session()
    
    private init () { }
    
    func getUserInfo () {
        if (self.token != nil) {
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
                            
                            let user_info = try decoder.decode(Users.self, from: data)
                            self.userId = user_info.response[0].id
                            self.userAvatar = user_info.response[0].avatar
                            self.userName = user_info.response[0].firstName + " " + user_info.response[0].lastName
                            self.userNickName = user_info.response[0].nickname
                            
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
        self.token = token
    }
    
    func logout (){
        self.token = nil
        self.userId = nil
        self.userAvatar = nil
        self.userNickName = nil
        self.userName = nil
    }
    
    func getUserId() -> Int {
        return self.userId ?? 0
    }
    
    func getToken() -> String {
        return self.token ?? ""
    }
}
