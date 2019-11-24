//
//  PhotosCell.swift
//  weather
//
//  Created by Григорий Мартюшин on 26.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class PhotosCell: UICollectionViewCell {
    @IBOutlet weak var FriendPhotoImageView: AvatarView!
    @IBOutlet weak var FriendLike: LikeControl!
    
    override func prepareForReuse() {
        self.FriendPhotoImageView.showImage(image: getNotFoundPhoto())
        self.FriendLike.initLikes(likes: -1, isLiked: false)
    }
}
