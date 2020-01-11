//
//  Friends.swift
//  weather
//
//  Created by Григорий Мартюшин on 25.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit
import RealmSwift

class Friend: Object {
    @objc dynamic var userId: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var city: String = ""
    
    override class func primaryKey() -> String? {
        return "userId"
    }
    
    // Аватарка пользовтеля
    @objc dynamic var photo: String? = nil
    
    init (userId: Int, photo: String, name: String, city: String){
        self.userId = userId
        self.name = name
        self.photo = photo
        self.city = city
    }
    
    init (userId: Int, photo: String, name: String){
        self.userId = userId
        self.name = name
        self.photo = photo
    }
    
    init (userId: Int, name: String){
        self.userId = userId
        self.name = name
        self.photo = nil
            
    }
    
    required init() {
        self.userId = 0
        self.name = ""
        self.photo = nil
        self.city = ""
    }
}
