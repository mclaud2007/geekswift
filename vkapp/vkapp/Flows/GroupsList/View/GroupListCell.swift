//
//  GroupListCell.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 02.06.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit

class GroupListCell: UITableViewCell {
    // MARK: Properties
    // Название группы
    private(set) lazy var labelGroupName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Style.groupScreen.textColor
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .natural
        return label
    }()
    
    // Аватарка группы
    private(set) lazy var imgGroupAvatar: AvatarControll = {
        let imageView = AvatarControll(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let photoService = PhotoService.shared
    
    // MARK: Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    fileprivate func configureView() {
        self.addSubview(self.labelGroupName)
        self.addSubview(self.imgGroupAvatar)
        
        // Настройка аватарки
        let avatarHeightAnchor = self.imgGroupAvatar.heightAnchor.constraint(equalToConstant: 64)
        avatarHeightAnchor.priority = UILayoutPriority(rawValue: 999)
        
        let avatarWidthAnchor = self.imgGroupAvatar.widthAnchor.constraint(equalTo: self.imgGroupAvatar.heightAnchor, multiplier: 1)
        avatarWidthAnchor.priority = UILayoutPriority(rawValue: 999)
        
        // Активируем констрейнты
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            self.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor),
            
            // Аватарка находится слева
            avatarHeightAnchor, avatarWidthAnchor,
            self.imgGroupAvatar.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 10),
            self.imgGroupAvatar.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 10),
            self.imgGroupAvatar.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            
            // Название группы находится справа от аватарки
            self.labelGroupName.leftAnchor.constraint(equalTo: self.imgGroupAvatar.rightAnchor, constant: 10),
            self.labelGroupName.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: -10),
            
            // Центрируем по вертикали относительно высоты аватарки
            NSLayoutConstraint(item: self.labelGroupName, attribute: .centerY, relatedBy: .equal, toItem: self.imgGroupAvatar, attribute: .centerY, multiplier: 1, constant: 0)
        ])
    }
    
    override func prepareForReuse() {
        self.imgGroupAvatar.resetImage()
        self.labelGroupName.text = nil
    }
    
    // Конфигурируем ячейку по данным из класса
    public func configureFrom(group: Group) {
        self.labelGroupName.text = group.name
        
        if let photo = group.imageString {
            photoService.getPhotoBy(urlString: photo, catrgory: "avatar") { [weak self] image in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.imgGroupAvatar.showImage(image: image)
                }
            }
        } else {
            self.imgGroupAvatar.showImage(image: "")
        }
    }
}
