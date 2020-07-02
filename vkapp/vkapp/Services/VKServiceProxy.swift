//
//  VKServiceProxy.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 02.04.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation
import SwiftyJSON
import PromiseKit

class VKProxy: VKServiceProxy {
    let service = VKService.shared
    
    public func getNewsList(startFrom: String? = nil, startTime: Double? = nil, completion: @escaping ((Swift.Result<[News], Error>, String?) -> Void) ) {
        print("News list requested!")
        
        // Запускаем настоящее получение новостей
        service.getNewsList(startFrom: startFrom, startTime: startTime, completion: completion)
    }
    
    public func getGroupsList(complition: ((Swift.Result<[RLMGroup], Error>) -> Void)? = nil) {
        print("Group list requested!")
        
        // Запускаем настоящее получение групп
        service.getGroupsList(complition: complition)
    }
    
    public func getFriendsList() -> Promise<JSON> {
        print("Friend list requested!")
        
        // Возвращаем результат сервиса
        return service.getFriendsList()
    }
}
