//
//  NewsTableCell.swift
//  weather
//
//  Created by Григорий Мартюшин on 09.11.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class NewsTableCell: UITableViewCell {

    @IBOutlet weak var imgAvatarView: AvatarView!
    @IBOutlet weak var lblNewsTitle: UILabel!
    @IBOutlet weak var lblNewsDate: UILabel!
    @IBOutlet weak var lblNewsContent: UILabel!
    
    override func prepareForReuse() {
        imgAvatarView.showImage(image: UIImage(named: "photonotfound")!)
        lblNewsTitle.text = "..."
        lblNewsDate.text = "..."
        lblNewsContent.text = "..."
    }
    
    func configure (with newsCell: News, indexPath: IndexPath?) {
        lblNewsTitle.text = newsCell.title
        lblNewsDate.text = newsCell.date
        lblNewsContent.text = newsCell.content
        
        if let avatar = newsCell.avatar {
            imgAvatarView.showImage(image: avatar)
        } else {
            imgAvatarView.showImage(image: getNotFoundPhoto())
        }
    }
}
