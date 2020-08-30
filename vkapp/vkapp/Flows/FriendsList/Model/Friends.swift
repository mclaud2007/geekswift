//
//  Friends.swift
//  weather
//
//  Created by Григорий Мартюшин on 25.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class Friend {
    var name: String {
        return (lastName != nil ? firstName + " " + lastName! : firstName)
    }
    
    let lastName: String?
    let online: Int?
    let firstName: String
    private(set) var isClosed: Bool?
    let bDate: String?
    let photo: String?
    let userId: Int
    
    private(set) var city: String = ""
    private(set) var workName: String? = ""
    
    init(from: [String: Any]) {
        isClosed = false
        
        if let isClosedInt = from["is_closed"] as? Int {
            if isClosedInt == 1 {
                isClosed = true
            }
        }
        
        userId = from["id"] as? Int ?? 0
        photo = from["photo_50"] as? String
        online = from["online"] as? Int
        bDate = from["bdate"] as? String
        firstName = from["first_name"] as? String ?? ""
        lastName = from["last_name"] as? String
        
        // Пытаемся получить название города
        if let cityArray = from["city"] as? [String: Any] {
            city = cityArray["title"] as? String ?? ""
        }
         
        // пытаемся определить название компании
        if let workArray = from["occupation"] as? [String: Any],
            let workType = workArray["type"] as? String,
            workType == "work"
        {
            workName = workArray["name"] as? String
        }
    }
}
