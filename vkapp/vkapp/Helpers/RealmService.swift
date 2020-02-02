//
//  RealmService.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 24.12.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class RealmService {
    static let RealmDeleteMigration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    
    static func get<T: Object>(_ type: T.Type) throws -> Results<T> {
        let realm = try Realm(configuration: RealmDeleteMigration)
        print(realm.configuration.fileURL!)
        return realm.objects(type)
    }
    
    static func save<T: Object>(items: T) throws {
        let realm = try Realm(configuration: RealmDeleteMigration)
        
        try realm.write {
            realm.add(items.self, update: Realm.UpdatePolicy.modified)
        }
    }
    
    static func delete<T: Object>(object: T) throws {
        let realm = try Realm(configuration: RealmDeleteMigration)
        
        try realm.write {
            realm.delete(object)
        }
    }
    
    static func service () throws -> Realm {
        return try Realm(configuration: RealmDeleteMigration)
    }
}
