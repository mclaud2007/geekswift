//
//  FriendsTableViewCell.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 04.05.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {
    // MARK: Properties
    // Имя друга
    public lazy var labelFriendName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Style.friendScreen.textColor
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .natural
        return label
    }()
    
    // Город проживания друга
    public lazy var labelFriendCity: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .natural
        label.textColor = Style.friendScreen.cityColor
        return label
    }()
    
    // Аватарка друга
    public lazy var imageFriendAvatar: AvatarControll = {
        let avatar = AvatarControll(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
        avatar.translatesAutoresizingMaskIntoConstraints = false
        return avatar
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
    
    public func configureFrom (friend: Friend, at indexPath: IndexPath?) {
        self.labelFriendName.text = friend.name
        
        if let work = friend.workName,
            !work.isEmpty
        {
            self.labelFriendCity.text = work + ", " + friend.city
        } else {
            self.labelFriendCity.text = friend.city
        }
        
        if let photo = friend.photo {
            DispatchQueue.main.async {
                self.imageFriendAvatar.showImage(image: photo, indexPath)
            }
        }
    }
    
    private func configureView() {
        self.addSubview(self.imageFriendAvatar)
        self.addSubview(self.labelFriendName)
        self.addSubview(self.labelFriendCity)
        
        // Высота и ширина аватара
        let heightAncor = self.imageFriendAvatar.heightAnchor.constraint(equalToConstant: 64)
        heightAncor.priority = UILayoutPriority(rawValue: 999)
        
        let widthAncor = self.imageFriendAvatar.widthAnchor.constraint(equalTo: self.imageFriendAvatar.heightAnchor, multiplier: 1)
        widthAncor.priority = UILayoutPriority(rawValue: 999)
            
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            self.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor),
            
            // Аватарка
            heightAncor, widthAncor,
            self.imageFriendAvatar.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 10),
            self.imageFriendAvatar.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            self.imageFriendAvatar.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 10),
            
            // Имя друга
            self.labelFriendName.leftAnchor.constraint(equalTo: self.imageFriendAvatar.rightAnchor, constant: 10),
            self.labelFriendName.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: -10),
            
            // Гоород проживания друга
            self.labelFriendCity.leftAnchor.constraint(equalTo: self.labelFriendName.leftAnchor),
            self.labelFriendCity.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: -10),
            
            // Центрируем по вертикали относительно высоты аватара
            NSLayoutConstraint(item: self.labelFriendName, attribute: .centerY, relatedBy: .equal,
                               toItem: self.imageFriendAvatar, attribute: .centerY,
                               multiplier: 1, constant: -10
            ),
            
            self.labelFriendCity.topAnchor.constraint(equalTo: self.labelFriendName.bottomAnchor, constant: 5)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.labelFriendName.text = ""
        self.labelFriendCity.text = ""
        self.imageFriendAvatar.resetImage()
    }
}
