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

    var Image: UIImage!
    var ImageView: UIImageView!
    var CurrentIndexPath: IndexPath?
    var delegate: AvatarViewProto!
    
    @IBInspectable var shadowColor: UIColor = UIColor.black
    @IBInspectable var shdowRadius: CGFloat = 5
    @IBInspectable var shadowOpacity: Float = 0.5
    
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
            self.delegate?.click(sender: self)
        })
    }
    
    private func setupView(){
        // Слой с тенью
        layer.shadowOffset = .zero
        
        self.ImageView = UIImageView()
        self.ImageView.clipsToBounds = true
        self.ImageView.layer.masksToBounds = true
        self.ImageView.contentMode = .scaleAspectFill
        
        self.addSubview(self.ImageView)
    }
    
    override func layoutSubviews() {
        // перерисовка тут т.е. надо настроить размеры именно здесь
        self.ImageView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        self.ImageView.layer.cornerRadius = floor(bounds.width / 2)
        
        // Слой с тенью
        layer.cornerRadius = floor(bounds.width / 2)
        
        // Если вынести эти параметры - перестанет срабатывать IBInspectable :/
        layer.shadowColor = self.shadowColor.cgColor
        layer.shadowOpacity = self.shadowOpacity
        layer.shadowRadius = self.shdowRadius
    }
    
    public func showImage(imageURL: String, indexPath: IndexPath? = nil){
        // Меняем адрес картинки
        if (imageURL.isEmpty){
            self.ImageView.image = UIImage(named: "photonotfound")
        } else {
            self.ImageView.kf.setImage(with: URL(string: imageURL))
        }
        
        self.CurrentIndexPath = indexPath ?? nil
    }
    
    public func showImage(image: UIImage, indexPath: IndexPath? = nil){
        // Меняем адрес картинки
        self.ImageView.image = image
        self.CurrentIndexPath = indexPath ?? nil
    }
}
