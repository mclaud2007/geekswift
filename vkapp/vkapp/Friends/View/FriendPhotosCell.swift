//
//  PhotosCell.swift
//  weather
//
//  Created by Григорий Мартюшин on 26.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class PhotosCell: UICollectionViewCell {
    @IBOutlet weak var friendPhotoImageView: AvatarView!
    @IBOutlet weak var friendLike: LikeControl!
    
    override func prepareForReuse() {
        self.friendPhotoImageView.showImage(image: UIImage(named:"loadplaceholder")!)
        self.friendLike.initLikes(likes: -1, isLiked: false)
    }
    
    func configure(with photos: Photo, indexPath: IndexPath?){
        // Фотография по идее есть
        self.friendPhotoImageView.showImage(imageURL: photos.photoUrlString ?? "", indexPath: indexPath)
        
        // Инициализируем лайки
        self.friendLike.initLikes(likes: photos.likes, isLiked: photos.isLiked)
    }
}
