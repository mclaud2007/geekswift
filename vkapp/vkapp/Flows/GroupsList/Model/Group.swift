//
//  Group.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 02.06.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation

// MARK: - Group
struct Group {
    let groupId: Int
    let imageString: String?
    let name: String
    let type: GroupType
    
    init (from: [String: Any]) {
        if let gID = from["id"] as? Int,
            let gName = from["name"] as? String,
            let gType = from["type"] as? String
        {
            self.type = gType == "page" ? .page : .group
            self.groupId = gID
            self.name = gName
            self.imageString = from["photo_50"] as? String
        } else {
            self.type = .group
            self.name = ""
            self.groupId = 0
            self.imageString = nil
        }
    }
}


enum GroupType: String {
    case group = "group"
    case page = "page"
}
