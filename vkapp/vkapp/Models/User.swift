//
//  User.swift
//  weather
//
//  Created by Григорий Мартюшин on 07.12.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

// MARK: - Users
struct Users: Codable {
    let response: [Response]
    
    // MARK: - Response
    struct Response: Codable {
        let id: Int
        let firstName, lastName: String
        let isClosed, canAccessClosed: Bool
        let nickname: String
        let avatar: String

        enum CodingKeys: String, CodingKey {
            case id
            case firstName = "first_name"
            case lastName = "last_name"
            case isClosed = "is_closed"
            case canAccessClosed = "can_access_closed"
            case nickname
            case avatar = "photo_50"
        }
    }
}


