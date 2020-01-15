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
        self.FriendPhotoImageView.showImage(imageURL: "")
        self.FriendLike.initLikes(likes: -1, isLiked: false)
    }
    
    func configure(with photos: Photo, indexPath: IndexPath?){
        // Фотография по идее есть
        self.FriendPhotoImageView.showImage(imageURL: photos.photoUrlString ?? "", indexPath: indexPath)
        
        // Инициализируем лайки
        self.FriendLike.initLikes(likes: photos.likes, isLiked: photos.isLiked)
    }
}
