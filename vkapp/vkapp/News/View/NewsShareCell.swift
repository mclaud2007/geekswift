//
//  NewsShareCell.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 19.01.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit

class NewsShareCell: UITableViewCell {

    @IBOutlet weak var lblComments: UILabel!
    @IBOutlet weak var lblShare: UILabel!
    @IBOutlet weak var lblViews: UILabel!
    @IBOutlet weak var likeControl: LikeControl!

    override func prepareForReuse() {
        likeControl.initLikes(likes: 0, isLiked: false)
        lblViews.text = "0"
        lblShare.text = "0"
        lblComments.text = "0"
    }

    func configure (with newsCell: News, indexPath: IndexPath?){
        lblShare.text = String(newsCell.shared!)
        lblViews.text = String(newsCell.views!)
        lblComments.text = String(newsCell.comments!)
        likeControl.initLikes(likes: newsCell.likes!, isLiked: newsCell.isLiked!)
    }

}
