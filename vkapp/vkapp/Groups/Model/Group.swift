//
//  Group.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 05.03.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation

class Group {
    var name: String
    var imageString: String? = nil
    var groupId: Int
    
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
