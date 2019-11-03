//
//  Friends.swift
//  weather
//
//  Created by Григорий Мартюшин on 25.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class Friend {
    let name: String
    let photo: UIImage?
    let photos: Array<UIImage>?
    let likes: [Int]
    
    init (photo: UIImage, name: String, photos: Array<UIImage>, likes: [Int]){
        self.name = name
        self.photo = photo
        self.photos = photos
        self.likes = likes
    }
    
    init (photo: UIImage, name: String){
        self.name = name
        self.photo = photo
        self.photos = nil
        self.likes = [0]
    }
    
    init (name: String){
        self.name = name
        self.photo = nil
        self.photos = nil
        self.likes = [0]
    }
}
