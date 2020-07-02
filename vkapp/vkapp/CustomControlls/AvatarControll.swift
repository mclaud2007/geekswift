//
//  Avatar.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 07.06.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit

protocol AvatarControllDelegate {
    func click (sender: AvatarControll) -> Void
}

class AvatarControll: UIControl {
    var avatarImageView: UIImageView!
    var photoService = PhotoService.shared
    var delegate: AvatarControllDelegate?
    var indexPath: IndexPath?
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    private func setupView() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5
        
        avatarImageView = UIImageView()
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = floor(bounds.width / 2)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(avatarImageView)
        
        NSLayoutConstraint.activate([
            self.avatarImageView.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor),
            self.avatarImageView.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor),
            self.avatarImageView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            self.avatarImageView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Вешаем тапджестор на нажатие кнопки
        let tapRecogniser = UITapGestureRecognizer(target: self, action: #selector(getClickOnAvatar(sender:)))
        self.addGestureRecognizer(tapRecogniser)
        
    }
    
    @objc func getClickOnAvatar(sender: UITapGestureRecognizer) {
        self.delegate?.click(sender: self)
    }
    
    func showImage(image: UIImage?, _ indexPath: IndexPath? = nil) {
        // Сохраняем indexPath в котором выведена картинка, если применимо
        self.indexPath = indexPath
        
        if let image = image {
            self.avatarImageView.image = image
        } else {
            self.avatarImageView.image = UIImage(named: "photonotfound")
        }
    }
    
    func showImage(image: String?, _ indexPath: IndexPath? = nil){
        // Сохраняем indexPath в котором выведена картинка, если применимо
        self.indexPath = indexPath
        
        if let image = image,
            !image.isEmpty
        {
            photoService.getPhotoBy(urlString: image) { [weak self] photo in
                guard let self = self else { return }
                
                if let photo = photo {
                    DispatchQueue.main.async {
                        self.avatarImageView.image = photo
                    }
                } else {
                    DispatchQueue.main.async {
                        self.avatarImageView.image = UIImage(named: "photonotfound")
                    }
                }
            }
        } else {
            self.avatarImageView.image = UIImage(named: "photonotfound")
        }
    }
    
    func resetImage() {
        self.avatarImageView.image = nil
    }
}
