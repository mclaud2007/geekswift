//
//  FriendsCellProto.swift
//  weather
//
//  Created by Григорий Мартюшин on 08.11.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class FriendsCellProto: UITableViewCell {
    @IBOutlet weak var lblFriendsName: UILabel!
    @IBOutlet weak var friendPhotoImageView: AvatarView!
    
    override func prepareForReuse() {
        self.lblFriendsName.text = "..."
        self.friendPhotoImageView.showImage(image: getNotFoundPhoto())
    }
    
    public func configure(with friend: Friend, indexPath: IndexPath?){
        self.lblFriendsName.text = friend.name
        self.friendPhotoImageView.showImage(image: friend.photo ?? "", indexPath: indexPath)
    }
}
