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
    @IBOutlet weak var FriendPhotoImageView: AvatarView!
    
    override func prepareForReuse() {
        self.lblFriendsName.text = "..."
        self.FriendPhotoImageView.showImage(image: getNotFoundPhoto())
    }
    
    public func configure(with friend: Friend, indexPath: IndexPath?){
        self.lblFriendsName.text = friend.name
        self.FriendPhotoImageView.showImage(imageURL: friend.photo ?? "", indexPath: indexPath)
    }
}
