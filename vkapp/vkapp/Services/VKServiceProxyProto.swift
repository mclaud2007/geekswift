//
//  VKServiceProto.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 02.04.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation
import SwiftyJSON
import PromiseKit

protocol VKServiceProxy {
    func getNewsList(startFrom: String?, startTime: Double?, completion: @escaping ((Swift.Result<[News], Error>, String?) -> Void) )
    
    func getGroupsList(complition: ((Swift.Result<[RLMGroup], Error>) -> Void)?)
    
    func getFriendsList() -> Promise<JSON>
}
