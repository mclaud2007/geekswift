//
//  Photos.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 08.12.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit
import RealmSwift

class Photo: Object {
    @objc dynamic var date: Int = 0
    @objc dynamic var id: Int
    @objc dynamic var likes: Int
    var photoURL: String?
    var photoImage: UIImage?
    @objc dynamic var isLiked: Bool = false
    
    init(photoId id: Int, photo: String, likes: Int?, liked: Bool? = false, date: Int?) {
        self.id = id
        self.photoURL = photo
        self.photoImage = nil
        self.likes = likes ?? -1
        self.date = date ?? 0
        self.isLiked = liked!
    }
    
    init(photoId id: Int, photo: UIImage, likes: Int?, liked: Bool? = false, date: Int?) {
        self.id = id
        self.photoURL = nil
        self.photoImage = photo
        self.likes = likes ?? -1
        self.date = date ?? 0
        self.isLiked = liked!
    }
    
    required init() {
        self.id = 0
        self.photoURL = nil
        self.photoImage = nil
        self.likes = -1
        self.date = 0
        self.isLiked = false
    }
}
