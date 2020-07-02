//
//  AppSession.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 01.05.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation

class AppSession {
    var token: String? {
       return self.access_token
    }
    
    private var access_token: String?
    
    private(set) var userId: Int = 0
    private(set) var userAvatar: String?
    private(set) var userName: String?
    private(set) var userNickName: String?
    
    static let shared = AppSession()
    let keyChainService = KeyChainService()
    
    init () {
        if let sAvatar = UserDefaults.standard.string(forKey: "avatar"),
            let sName = UserDefaults.standard.string(forKey: "name"),
            let sToken = keyChainService.getKeyBy(name: "token")
        {
            self.userId = UserDefaults.standard.integer(forKey: "ID")
            self.userAvatar = sAvatar
            self.userName = sName
            self.access_token = sToken
            self.userNickName = UserDefaults.standard.string(forKey: "nickName")
            print("Restore session")
        }
    }
    
    public func setToken(token: String) {
        self.access_token = token
        keyChainService.setKeyBy(name: "token", value: token)
    }
    
    func setUserInfoBy(_ user: [String: Any]) {
        if let lastName = user["last_name"] as? String,
            let firstName = user["first_name"] as? String,
            let uID = user["id"] as? Int
        {
            self.userId = uID
            self.userName = firstName +  " " + lastName
            self.userAvatar = user["photo_50"] as? String
            
            // Сохраняем информацию на устройстве
            storeUserInfoToDefaults()
        }
    }
    
    func kill() {
        UserDefaults.standard.removeObject(forKey: "ID")
        UserDefaults.standard.removeObject(forKey: "avatar")
        UserDefaults.standard.removeObject(forKey: "name")
        UserDefaults.standard.removeObject(forKey: "nickName")
        keyChainService.delKeyBy(name: "token")
        
        // Удаляем сохраненную информаицю
        self.access_token = nil
        self.userId = 0
        self.userName = nil
        self.userAvatar = nil
        self.userNickName = nil
        
    }
    
    func storeUserInfoToDefaults() {
        UserDefaults.standard.set(userId, forKey: "ID")
        UserDefaults.standard.set(userAvatar, forKey: "avatar")
        UserDefaults.standard.set(userName, forKey: "name")
        UserDefaults.standard.set(userNickName, forKey: "nickName")
    }
}
