//
//  Groups.swift
//  weather
//
//  Created by Григорий Мартюшин on 26.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class Groups {
    var List: [Group] = []
    
    public func loadFromNetwork (complition: @escaping (Result<[Group], Error>) -> Void) {
        let token = Session.shared.getToken()
        
        if !token.isEmpty {
            let param: Parameters = [
                "access_token": token,
                "user_id": Session.shared.getUserId(),
                "extended": 1,
                "fields": "photo_50,name",
                "v": VK.shared.APIVersion
            ]
        
            VK.shared.setCommand("groups.get", param: param) { response in
                switch response.result {
                    case .success(_):
                        if let data = response.data {
                            let json = JSON(data)
                            
                            // что-то нашли
                            if (json["response"]["count"].intValue > 0){
                                for group in json["response"]["items"].arrayValue {
                                    if let id = group["id"].int,
                                        let name = group["name"].string,
                                        let photo = group["photo_50"].string {
                                        
                                        self.List.append(Group(groupId: id, name: name, image: photo))
                                        complition(.success(self.List))
                                    }
                                }
                            }
                        }
                    case let .failure(error):
                        complition(.failure(error))
                    break
                }
            }
        }
    }
    
}

class Group {
    let name: String
    let imageString: String?
    let image: UIImage?
    let groupId: Int
    
    init (groupId: Int, name: String, image: UIImage?){
        self.groupId = groupId
        self.name = name
        self.image = image
        self.imageString = nil
    }
    
    init (groupId: Int, name: String, image: String?){
        self.groupId = groupId
        self.name = name
        self.imageString = image
        self.image = nil
    }

    init (groupId: Int, name: String){
        self.groupId = groupId
        self.name = name
        self.image = nil
        self.imageString = nil
    }
}
