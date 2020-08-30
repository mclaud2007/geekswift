//
//  KeychainService.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 10.06.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation

class KeyChainService {
    private var query: [String: Any] = {
        let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: "im.mga.vkapp.keys"]
        
        return query
    }()
    
    func setKeyBy(name: String, value: String) {
        query[kSecAttrAccount as String] = "vk_app_" + name
        
        if let storeKey = value.data(using: .utf8) {
            if let _ = getKeyBy(name: name) {
                var attributesToUpdate: [String: Any] = [:]
                attributesToUpdate[kSecValueData as String] = storeKey
                
                SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            } else {
                query[kSecValueData as String] = storeKey
                let status = SecItemAdd(query as CFDictionary, nil)

                guard status == errSecSuccess else { print("error"); return }
            }
        }
    }
    
    func getKeyBy(name: String) -> String? {
        query[kSecAttrAccount as String] = "vk_app_" + name
        query[kSecReturnAttributes as String] = true
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else { return nil }
        
        guard let keyData = item as? [String: Any],
                let passwordData = keyData[kSecValueData as String] as? Data,
                let password = String(data: passwordData, encoding: .utf8) else { return nil }
        
       
        return password
        
    }
    
    func delKeyBy(name: String) {
        query[kSecAttrAccount as String] = "vk_app_" + name
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { return }
    }
}
