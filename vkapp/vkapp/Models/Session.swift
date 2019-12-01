//
//  Session.swift
//  weather
//
//  Created by Григорий Мартюшин on 30.11.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import Foundation

class Session {
    // Токен и userID можно получать только с сервере
    // в любой части приложения их можно либо получить
    // через getter's ниже, либо через новый запрос к
    // серверу
    private var token: String?
    private var userId: Int?
    
    static let instance = Session()
    
    private init () { }
    
    func login (login: String, password: String) -> Bool {
        if (login.isEmpty && password.isEmpty){
            self.token = "22ekjlkjl23j3lk3hl12hl1kl131"
            self.userId = 1
            
            return true
        }
        
        //  Для теста не пустые пароли будут возвращать пустой токен и юзерайдиё
        return true
//        return false
    }
    
    func logout (){
        self.token = nil
        self.userId = nil
    }
    
    func getUserId() -> Int {
        return self.userId ?? 0
    }
    
    func getToken() -> String {
        return self.token ?? ""
    }
}
