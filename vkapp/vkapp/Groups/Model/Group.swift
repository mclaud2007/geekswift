//
//  Groups.swift
//  weather
//
//  Created by Григорий Мартюшин on 26.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit
import RealmSwift

class Group: Object {
    @objc dynamic var name: String
    @objc dynamic var imageString: String? = nil
    @objc dynamic var groupId: Int
    
    override class func primaryKey() -> String? {
        "groupId"
    }
    
    init (groupId: Int, name: String, image: String?){
        self.groupId = groupId
        self.name = name
        self.imageString = image
    }

    init (groupId: Int, name: String){
        self.groupId = groupId
        self.name = name
        self.imageString = nil
    }
    
    required init() {
        self.groupId = 0
        self.name = ""
        self.imageString = nil
    }
}
