//
//  GroupViewModel.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 05.03.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit

struct GroupViewModel {
    var name: String = ""
    var image: Any?
    
    init (name: String, image: Any?){
        if let image = image {
            if let _ = image as? UIImage {
                self.image = image
            } else if let imageString = image as? String, !imageString.isEmpty {
                self.image = image
            } else {
                self.image = nil
            }
        }
        
        self.name = name
    }
}
