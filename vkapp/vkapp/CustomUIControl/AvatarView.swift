//
//  FriendPhoto.swift
//  weather
//
//  Created by Григорий Мартюшин on 03.11.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit
import Kingfisher

protocol AvatarViewProto {
    func click (sender: AvatarView) -> Void
}

class AvatarView: UIControl {
    var avatarImageView: UIImageView!
    var currentIndexPath: IndexPath?
    var delegate: AvatarViewProto!
    var isClicked = false
    var photoService = PhotoService()
    
    @IBInspectable var shadowColor: UIColor = UIColor.black
    @IBInspectable var shdowRadius: CGFloat = 5
    @IBInspectable var shadowOpacity: Float = 0.5
    @IBInspectable var haveShadow: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
        self.setupGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
        self.setupGesture()
    }
    
    private func setupGesture(){
        let doubleTapGR = UITapGestureRecognizer(target: self, action: #selector(startAnimation))
        doubleTapGR.numberOfTapsRequired = 1
        self.addGestureRecognizer(doubleTapGR)
    }
    
    @objc private func startAnimation(){
        if isClicked == false {
            // Аватарку кликнули - пока не закончится анимация, кликать больше нельзя
            isClicked = true
            
            let animation = CASpringAnimation(keyPath: "transform.scale")
            animation.toValue = 0.85
            animation.autoreverses = true
            animation.duration = 0.55
            animation.stiffness = 85
            animation.mass = 0.85
            animation.damping = 0.3
            animation.initialVelocity = 5
            self.layer.add(animation, forKey: nil)
            
            // После того как анимация закончилась отправим эвент что аватар нажат
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                self.isClicked = false
                self.delegate?.click(sender: self)
            })
        }
    }
    
    private func setupView(){
        // Слой с тенью
        layer.shadowOffset = .zero
        
        self.avatarImageView = UIImageView()
        self.avatarImageView.clipsToBounds = true
        self.avatarImageView.layer.masksToBounds = true
        self.avatarImageView.contentMode = .scaleAspectFill
        
        self.addSubview(self.avatarImageView)
    }
    
    override func layoutSubviews() {
        // перерисовка тут т.е. надо настроить размеры именно здесь
        avatarImageView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        
        // Слой с тенью
        if haveShadow == true {
            avatarImageView.layer.cornerRadius = floor(bounds.width / 2)
            layer.cornerRadius = floor(bounds.width / 2)
        
            // Если вынести эти параметры - перестанет срабатывать IBInspectable :/
            layer.shadowColor = self.shadowColor.cgColor
            layer.shadowOpacity = self.shadowOpacity
            layer.shadowRadius = self.shdowRadius
        }
    }
    
    public func showImage(imageURL: String, indexPath: IndexPath? = nil){
        // Меняем адрес картинки
        if (imageURL.isEmpty){
            self.avatarImageView.image = UIImage(named: "photonotfound")
        } else {
            photoService.getPhoto(by: imageURL) { result in
                DispatchQueue.main.async {
                    if let image = result {
                        self.avatarImageView.image = image
                    } else {
                        self.avatarImageView.image = UIImage(named: "photonotfound")!
                    }
                }
            }
        }
        
        self.currentIndexPath = indexPath ?? nil
    }
    
    public func showImage(image: UIImage, indexPath: IndexPath? = nil){
        // Меняем адрес картинки
        self.avatarImageView.image = image
        self.currentIndexPath = indexPath ?? nil
    }
}
