//
//  LikeControl.swift
//  weather
//
//  Created by Григорий Мартюшин on 03.11.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class LikeControl: UIControl {
    @IBInspectable var initLikes: Int = -1
    var likes: Int = 0
    var isLiked: Bool = false
    
    var lblLikes: UILabel!
    var imgHeart: UIImageView!
    
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
    
    private func setupView(){
        self.likes = self.initLikes
        
        // Drawing code
        self.lblLikes = UILabel()
        self.lblLikes.frame = CGRect(x: 20, y: 0, width: bounds.width, height: bounds.height)

        if (self.initLikes > 0){
            self.lblLikes.text = String(self.initLikes)
        } else {
            self.lblLikes.text = ""
        }
        addSubview(self.lblLikes)
        
        self.imgHeart = UIImageView()
        self.imgHeart.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        self.addSubview(self.imgHeart)
    }
    
    private func setupGesture(){
        let doubleTapGR = UITapGestureRecognizer(target: self, action: #selector(setLikeDislike))
        doubleTapGR.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapGR)
    }
    
    public func initLikes (likes: Int, isLiked: Bool){
        self.likes = likes
        self.isLiked = isLiked
        
        self.lblLikes.text = String(self.likes)
        
        if (self.isLiked == true){
            self.imgHeart.image = UIImage(named: "heart-on")
        } else {
            self.imgHeart.image = UIImage(named: "heart-off")
        }
        
        if (self.isLiked == true){
            self.lblLikes.textColor = UIColor.red
        } else {
            self.lblLikes.textColor = UIColor.white
        }
    }
    
    @objc public func setLikeDislike(){
        if (self.isLiked == true){
            self.likes -= 1
            self.isLiked = false

        } else {
            self.likes += 1
            self.isLiked = true
            
            if (self.likes == 0) {
                self.likes = 1
            }
        }
        
        self.initLikes(likes: self.likes, isLiked: self.isLiked)
    }
}
