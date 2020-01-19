//
//  NewsImageCell.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 19.01.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit
import Kingfisher

class NewsImageCell: UITableViewCell {
    @IBOutlet var imgNewsPhoto: UIImageView!
    
    override func prepareForReuse() {
        imgNewsPhoto.image = getNotFoundPhoto()
    }
    
    func configure (with newsCell: News, indexPath: IndexPath?) {
        if let picture = newsCell.picture {
            imgNewsPhoto.kf.setImage(with: URL(string: picture))
        } else {
            imgNewsPhoto.image = getNotFoundPhoto()
        }
    }

}
