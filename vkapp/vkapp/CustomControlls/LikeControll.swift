//
//  LikeControll.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 08.06.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit

protocol LikeControllDelegate {
    func click(sender: LikeControll) -> Void
}

class LikeControll: UIControl {
    var delegate: LikeControllDelegate?
    
    private(set) var isLiked: Bool? = false
    private(set) var likes: Int? = 0
    
    private(set) lazy var lblCount: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.text = "0"
        return label
    }()
    
    private(set) lazy var imgHeart: UIImageView = {
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "heart-off")
        image.clipsToBounds = true
        return image
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    private(set) lazy var viewBackground: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        view.backgroundColor = UIColor.white
        view.layer.opacity = 0.8
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(self.imgHeart)
        view.addSubview(self.lblCount)
        
        return view
    }()
    
    func setLikes(like: Int? = 0, liked: Bool? = false) {
        // Сохраняем инициированные настройки, чтобы их увеличить или уменьшить при клике
        self.likes = like
        self.isLiked = liked
        
        self.lblCount.text = String(like ?? 0)
        self.imgHeart.image = UIImage(named: (liked == true ? "heart-on" : "heart-off"))
    }
    
    func reset() {
        self.lblCount.text = "0"
        self.imgHeart.image = nil
    }
    
    func setupView() {
        self.addSubview(self.viewBackground)
        
        NSLayoutConstraint.activate([
            self.viewBackground.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor),
            self.viewBackground.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor),
            self.viewBackground.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            self.viewBackground.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            self.imgHeart.heightAnchor.constraint(lessThanOrEqualToConstant: 12),
            self.imgHeart.widthAnchor.constraint(lessThanOrEqualToConstant: 12),
            self.imgHeart.leftAnchor.constraint(lessThanOrEqualTo: self.safeAreaLayoutGuide.leftAnchor, constant: 5),
            self.imgHeart.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 2),
            self.lblCount.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 1),
            self.lblCount.rightAnchor.constraint(lessThanOrEqualTo: self.safeAreaLayoutGuide.rightAnchor, constant: -5)
        ])
        
        // Вешаем тапджестор на нажатие кнопки
        let tapRecogniser = UITapGestureRecognizer(target: self, action: #selector(getClickOnLikeButton(sender:)))
        self.addGestureRecognizer(tapRecogniser)
    }
    
    @objc func getClickOnLikeButton(sender: UITapGestureRecognizer) {
        if let delegate = delegate {
            delegate.click(sender: self)
            
            var newLikes = self.likes ?? 0
            if let isLiked = self.isLiked,
                isLiked == true
            {
                if (newLikes >= 1) {
                    newLikes -= 1
                }
            } else {
                newLikes += 1
            }
            
            // Анимируем изменение счетчика
            UIView.transition(with: self.lblCount,
                              duration: 0.25,
                              options: .transitionFlipFromRight,
                              animations: {
                                self.lblCount.text = String(newLikes)
                                self.likes = newLikes
                              }
            )
            
            // Анимируем сердце
            UIView.transition(with: self.imgHeart, duration: 0.25, options: .transitionCrossDissolve, animations: {
                // Было инициированно лайкнутым, надо дизлайнуть
                if (self.isLiked == true) {
                    self.imgHeart.image = UIImage(named: "heart-off")
                    self.isLiked = false
                } else {
                    self.imgHeart.image = UIImage(named: "heart-on")
                    self.isLiked = true
                }
            })
        }
    }
}
