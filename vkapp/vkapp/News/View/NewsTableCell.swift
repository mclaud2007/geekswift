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
    @IBOutlet weak var imgNewsPicture: UIImageView!
    @IBOutlet weak var lblLikeControl: LikeControl!
    @IBOutlet weak var lblViews: UILabel!
    @IBOutlet weak var lblShare: UILabel!
    @IBOutlet weak var lblComments: UILabel!
    
    override func prepareForReuse() {
        imgAvatarView.showImage(image: UIImage(named: "photonotfound")!)
        imgNewsPicture.image = UIImage(named: "69850")!
        lblNewsTitle.text = "..."
        lblNewsDate.text = "..."
        lblNewsContent.text = "..."
        lblLikeControl.initLikes(likes: 0, isLiked: false)
        lblViews.text = "0"
        lblShare.text = "0"
        lblComments.text = "0"
    }
}
