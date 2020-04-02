//
//  GroupsAdapter.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 05.03.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class GroupsAdapter {
    // Просто меняем настоящий сервис на прокси
    // private let vkService = VKService.shared
    private let vkService = VKProxy()
    
    private var groups: [Group] = []
    private var realmGroupsList: Results<RLMGroup>?
    var token: NotificationToken?
    
    func getGropus(complition: @escaping ([Group]) -> Void) {
        // Подпишемся на изменения реалма
        do {
            self.realmGroupsList = try RealmService.get(RLMGroup.self).sorted(byKeyPath: "name", ascending: true)
            
            if let realmGroupsList = self.realmGroupsList {
                token = realmGroupsList.observe({ (changes: RealmCollectionChange) in
                    switch changes {
                    case .initial(let realmResults),.update(let realmResults, _, _, _):
                        let groups: [Group] = realmResults.compactMap { group in
                            Group(groupId: group.groupId, name: group.name, image: group.imageString)
                        }
                        
                        complition(groups)
                        
                    case .error(_):
                        break
                    }
                })
            }
        } catch _ {
            
        }
        
        // Загрузка информации о группах
        vkService.getGroupsList { result in
            switch result {
            case let .success(groupsList):
                do {
                    for group in groupsList {
                        try RealmService.save(items: group)
                    }
                    
                } catch _ {
                    break
                }
            case .failure(_):
                break
            }
        }
    }
}
