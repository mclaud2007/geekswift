//
//  FriendDetailCell.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 04.06.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit

class FriendDetailCell: UICollectionViewCell {
    // MARK: Properties
    private(set) lazy var imgFriendPicture: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        return img
    }()
    
    private(set) lazy var sharedControll: SharedControll = {
        let like = SharedControll(frame: CGRect(x: 0, y: 0, width: 38, height: 18))
        like.translatesAutoresizingMaskIntoConstraints = false
        return like
    }()
    
    private(set) lazy var likeControll: LikeControll = {
        let like = LikeControll(frame: CGRect(x: 0, y: 0, width: 38, height: 18))
        like.translatesAutoresizingMaskIntoConstraints = false
        return like
    }()
        
    private let photoService = PhotoService.shared
    
    // MARK: Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    public func configure(from: Photo) {
        if let photo = from.photoUrlString {
            photoService.getPhotoBy(urlString: photo, catrgory: "photo") { [weak self] image in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if let image = image {
                        self.imgFriendPicture.image = image
                        self.sharedControll.setShared(shared: from.reposts)
                        self.likeControll.setLikes(like: from.likes, liked: from.isLiked)
                    } else {
                        self.imgFriendPicture.image = UIImage(named: "photonotfound")
                    }
                }
            }
        } else {
            self.imgFriendPicture.image = UIImage(named: "photonotfound")
        }
    }
    
    override func prepareForReuse() {
        self.imgFriendPicture.image = nil
        self.sharedControll.reset()
        self.likeControll.reset()
    }
    
    fileprivate func configureView() {
        self.addSubview(self.imgFriendPicture)
        self.addSubview(self.sharedControll)
        self.addSubview(self.likeControll)
        
        NSLayoutConstraint.activate([
            self.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor),
            self.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            self.imgFriendPicture.widthAnchor.constraint(equalTo: self.widthAnchor),
            self.imgFriendPicture.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor),
            self.imgFriendPicture.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            self.imgFriendPicture.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor),
            self.imgFriendPicture.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            // Счётчик репостов
            self.sharedControll.widthAnchor.constraint(equalToConstant: 38),
            self.sharedControll.heightAnchor.constraint(equalToConstant: 18),
            self.sharedControll.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: -5),
            self.sharedControll.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -5),
            
            // лайки
            self.likeControll.widthAnchor.constraint(equalToConstant: 38),
            self.likeControll.heightAnchor.constraint(equalToConstant: 18),
            self.likeControll.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 5),
            self.likeControll.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -5),
        ])
    }
}
