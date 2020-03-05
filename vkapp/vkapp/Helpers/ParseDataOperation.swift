//
//  ParseDataOperation.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 29.01.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation
import SwiftyJSON

class ParseData: Operation {
    var outputData: [RLMGroup] = []
    
    override func main() {
        guard let getDataOperation = dependencies.first as? GetDataOperation,
            let json = getDataOperation.data else { return }
        
        if json["response"]["count"].intValue > 0 {
            for group in json["response"]["items"].arrayValue {
                if group["id"].int != nil,
                    group["name"].string != nil,
                    group["photo_50"].string != nil
                {
                    outputData.append(RLMGroup(from: group))
                }
            }
        }
    }
}
