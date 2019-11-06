//
//  FriendPhoto.swift
//  weather
//
//  Created by Григорий Мартюшин on 03.11.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class AvatarView: UIView {

    var Image: UIImage!
    var ImageView: UIImageView!
    
    @IBInspectable var shadowColor: UIColor = UIColor.black
    @IBInspectable var shdowRadius: CGFloat = 5
    @IBInspectable var shadowOpacity: Float = 0.5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
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
        layer.shadowOpacity = self.shadowOpacity
        layer.shadowRadius = self.shdowRadius
        layer.shadowColor = self.shadowColor.cgColor
        layer.cornerRadius = floor(bounds.width / 2)
    }
    
    public func showImage(image: UIImage){
        // Меняем адрес картинки
        self.ImageView.image = image
    }
}
