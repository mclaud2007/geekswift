//
//  News.swift
//  weather
//
//  Created by Григорий Мартюшин on 09.11.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class News {
    var title: String
    var content: String
    var date: String
    var picture: String?
    var likes: Int? = 0
    var comments: Int? = 0
    var views: Int? = 0
    var shared: Int? = 0
    var isLiked: Bool? = false
    var avatar: String?
    
    init (title: String, content: String, date: String, picture: String) {
        self.title = title
        self.content = content
        self.date = date
        self.picture = picture
    }
    
    init (title: String, content: String, date: String, picture: String, likes: Int) {
        self.title = title
        self.content = content
        self.date = date
        self.picture = picture
        self.likes = likes
    }
    
    init (title: String, content: String, date: String, picture: String, likes: Int, views: Int) {
        self.title = title
        self.content = content
        self.date = date
        self.picture = picture
        self.likes = likes
        self.views = views
    }
    
    init (title: String, content: String, date: String, picture: String, likes: Int, views: Int, comments: Int) {
        self.title = title
        self.content = content
        self.date = date
        self.picture = picture
        self.likes = likes
        self.comments = comments
        self.views = views
    }
    
    init (title: String, content: String, date: String, picture: String, likes: Int, views: Int, comments: Int, shared: Int) {
        self.title = title
        self.content = content
        self.date = date
        self.picture = picture
        self.likes = likes
        self.comments = comments
        self.views = views
        self.shared = shared
    }
    
    init (title: String, content: String, date: String, picture: String, likes: Int, views: Int, comments: Int, shared: Int, isLiked: Bool) {
        self.title = title
        self.content = content
        self.date = date
        self.picture = picture
        self.likes = likes
        self.comments = comments
        self.views = views
        self.shared = shared
        self.isLiked = isLiked
    }
    
    init (title: String, content: String, date: String, picture: String?, likes: Int, views: Int, comments: Int, shared: Int, isLiked: Bool, avatar: String?) {
        self.title = title
        self.content = content
        self.date = date
        self.picture = picture
        self.likes = likes
        self.comments = comments
        self.views = views
        self.shared = shared
        self.isLiked = isLiked
        self.avatar = avatar
    }
}
