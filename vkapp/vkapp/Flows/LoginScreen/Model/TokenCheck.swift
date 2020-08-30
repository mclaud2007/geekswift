//
//  LoginCheck.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 06.06.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation

// MARK: - CheckTocken
struct TokenCheck: Codable {
    let item: TokenResponse
    
    enum CodingKeys: String, CodingKey {
        case item = "response"
    }
}

// MARK: - Response
struct TokenResponse: Codable {
    let date, expire, userID, success: Int

    enum CodingKeys: String, CodingKey {
        case date, expire
        case userID = "user_id"
        case success
    }
}
