//
//  NewsHeadCell.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 02.06.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit

class NewsHeadCell: UITableViewCell {
    // Название группы
    private(set) lazy var labelGroupName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Style.newsScreen.textColor
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .natural
        return label
    }()
    
    // Дата добавления новости
    private(set) lazy var labelNewsAddDate: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .natural
        return label
    }()
    
    // Текст новости
    private(set) lazy var labelNewsContent: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Style.newsScreen.textColor
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .natural
        return label
    }()
    
    // Аватарка группы
    private(set) lazy var imgGroupAvatar: AvatarControll = {
        let image = AvatarControll(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let photoService = PhotoService.shared
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    override func prepareForReuse() {
        self.labelGroupName.text = ""
        self.labelNewsAddDate.text = ""
        self.labelNewsContent.text = ""
        self.imgGroupAvatar.resetImage()
    }
    
    public func configureFrom(news: News) {
        self.labelGroupName.text = news.title
        self.labelNewsAddDate.text = news.date
        self.labelNewsContent.text = news.content
        self.labelNewsContent.numberOfLines = 0
        
        if let photo = news.avatar {
            photoService.getPhotoBy(urlString: photo, catrgory: "avatar") { [weak self] image in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.imgGroupAvatar.showImage(image: image)
                }
            }
        } else {
            self.imgGroupAvatar.showImage(image: UIImage(named: "photonotfound"))
        }
    }
    
    fileprivate func configureView() {
        self.addSubview(self.labelGroupName)
        self.addSubview(self.labelNewsAddDate)
        self.addSubview(self.labelNewsContent)
        self.addSubview(self.imgGroupAvatar)
        
        // Настраиваем аватарку
        let avatarHeightAnchor = self.imgGroupAvatar.heightAnchor.constraint(equalToConstant: 64)
        avatarHeightAnchor.priority = UILayoutPriority(rawValue: 999)
        
        let avatarWidthAnchor = self.imgGroupAvatar.widthAnchor.constraint(equalTo: self.imgGroupAvatar.heightAnchor, multiplier: 1)
        avatarWidthAnchor.priority = UILayoutPriority(rawValue: 999)
        
        // Активируем констрейнты
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            self.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor),
            
            // Аватар
            avatarWidthAnchor, avatarHeightAnchor,
            self.imgGroupAvatar.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 10),
            self.imgGroupAvatar.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 10),
            
            // Название группы
            self.labelGroupName.topAnchor.constraint(equalTo: self.imgGroupAvatar.topAnchor),
            self.labelGroupName.leftAnchor.constraint(equalTo: self.imgGroupAvatar.rightAnchor, constant: 10),
            self.labelGroupName.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: -10),
            
            // Дата написания новости
            self.labelNewsAddDate.topAnchor.constraint(equalTo: self.labelGroupName.bottomAnchor, constant: 5),
            self.labelNewsAddDate.leftAnchor.constraint(equalTo: self.labelGroupName.leftAnchor),
            
            // Содержание новости
            self.labelNewsContent.topAnchor.constraint(equalTo: self.imgGroupAvatar.bottomAnchor, constant: 10),
            self.labelNewsContent.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 10),
            self.labelNewsContent.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: -10),
            self.labelNewsContent.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -10)            
        ])
    }
}
