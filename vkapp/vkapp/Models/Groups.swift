//
//  Groups.swift
//  weather
//
//  Created by Григорий Мартюшин on 26.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class Groups {
    let name: String
    let image: UIImage?
    
    init (name: String, image: UIImage?){
        self.name = name
        self.image = image
    }
    
    init (name: String){
        self.name = name
        self.image = nil
    }
}
