//
//  NewsShareCell.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 02.06.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit

protocol NewsCommentDelegate {
    func click(sender: UITableViewCell)
}

class NewsShareCell: UITableViewCell {
    var commentDelegate: NewsCommentDelegate?
    var indexPath: IndexPath?
    
    // Лайки под новостями
    private(set) lazy var likeControll: LikeControll = {
        let like = LikeControll(frame: CGRect(x: 0, y: 0, width: 38, height: 18))
        like.translatesAutoresizingMaskIntoConstraints = false
        return like
    }()
    
    // Иконка счетчика перепостов
    private(set) lazy var imgShareLabel: UIImageView = {
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        image.image = UIImage(systemName: "arrowshape.turn.up.right.fill")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.tintColor = .systemGray
        return image
    }()
    
    // Счетчик перепостов
    private(set) lazy var labelShareCount: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .natural
        return label
    }()
    
    // Иконка счетчика комментариев
    private(set) lazy var imgCommentLabel: UIImageView = {
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        image.image = UIImage(systemName: "message.fill")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.tintColor = .systemGray
        return image
    }()
    
    // Счетчик комментариев
    private(set) lazy var labelCommentCount: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemGray
        label.font = UIFont.systemFont(ofSize: 11)
        label.textAlignment = .natural
        return label
    }()
    
    // Иконка счетчика просмотров
    private(set) lazy var imgViewsLabel: UIImageView = {
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        image.image = UIImage(systemName: "eye")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.tintColor = .systemGray
        return image
    }()
    
    // Счетчик просомотров
    private(set) lazy var labelViewsCount: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemGray
        label.font = UIFont.systemFont(ofSize: 11)
        label.textAlignment = .natural
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.coonfigureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.coonfigureView()
    }
    
    fileprivate func coonfigureView() {
        self.addSubview(self.imgShareLabel)
        self.addSubview(self.labelShareCount)
        self.addSubview(self.likeControll)
        self.addSubview(self.imgViewsLabel)
        self.addSubview(self.labelViewsCount)
        self.addSubview(self.imgCommentLabel)
        self.addSubview(self.labelCommentCount)
        
        // Расставляем констрейнты
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            self.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor),
            // Контрол для лайков
            self.likeControll.widthAnchor.constraint(equalToConstant: 38),
            self.likeControll.heightAnchor.constraint(equalToConstant: 18),
            self.likeControll.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 10),
            self.likeControll.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 10),
            self.likeControll.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            // Репосты
            self.imgShareLabel.heightAnchor.constraint(equalToConstant: 15),
            self.imgShareLabel.widthAnchor.constraint(equalToConstant: 15),
            self.imgShareLabel.topAnchor.constraint(equalTo: self.likeControll.topAnchor),
            self.imgShareLabel.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 50),
            self.labelShareCount.topAnchor.constraint(equalTo: self.likeControll.topAnchor),
            self.labelShareCount.leftAnchor.constraint(equalTo: self.imgShareLabel.rightAnchor, constant: 10),
            // Комментарии
            self.imgCommentLabel.heightAnchor.constraint(equalToConstant: 15),
            self.imgCommentLabel.widthAnchor.constraint(equalToConstant: 15),
            self.labelCommentCount.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: -15),
            self.labelCommentCount.topAnchor.constraint(equalTo: self.likeControll.topAnchor),
            self.imgCommentLabel.topAnchor.constraint(equalTo: self.likeControll.topAnchor, constant: -2),
            self.imgCommentLabel.rightAnchor.constraint(equalTo: self.labelCommentCount.leftAnchor, constant: -5),
            // Просмотры
            self.labelViewsCount.rightAnchor.constraint(equalTo: self.imgCommentLabel.leftAnchor, constant: -10),
            self.labelViewsCount.topAnchor.constraint(equalTo: self.likeControll.topAnchor),
            self.imgViewsLabel.heightAnchor.constraint(equalToConstant: 15),
            self.imgViewsLabel.widthAnchor.constraint(equalToConstant: 15),
            self.imgViewsLabel.rightAnchor.constraint(equalTo: self.labelViewsCount.rightAnchor, constant: -25),
            self.imgViewsLabel.topAnchor.constraint(equalTo: self.likeControll.topAnchor, constant: -2),
        ])
        
    }
 
    public func configureFrom(news: News, at indexPath: IndexPath?) {
        self.indexPath = indexPath
        
        // Количество репостов
        if let shareCount = news.shared {
            // В строке позволим вывести только пять знаков, если показов десятки тысяч - выведем К
            if shareCount > 999 {
                let decShare = (shareCount / 1000)
                var strComment = ""

                if decShare > 99 {
                    strComment = String(decShare / 100) + "m"
                } else {
                    strComment = String(decShare) + "k"
                }

                self.labelShareCount.text = strComment
                self.likeControll.setLikes(like: news.likes, liked: news.isLiked)

            } else {
                self.labelShareCount.text = String(shareCount)
            }
        } else {
            self.labelShareCount.text = "0"
        }
        
        // Количество комментариев
        if let commentCount = news.comments {
            // В строке позволим вывести только пять знаков, если показов десятки тысяч - выведем К
            if commentCount > 999 {
                let decComments = (commentCount / 1000)
                var strComment = ""

                if decComments > 99 {
                    strComment = String(decComments / 100) + "m"
                } else {
                    strComment = String(decComments) + "k"
                }

                self.labelCommentCount.text = strComment

            } else {
                self.labelCommentCount.text = String(commentCount)

            }
        } else {
            self.labelCommentCount.text = "0"
        }
        
        // Количество просмотров
        if let viewsCount = news.views {
            // В строке позволим вывести только пять знаков, если показов десятки тысяч - выведем К
            if viewsCount > 999 {
                let decViews = (viewsCount / 1000)
                var strViews = ""
                
                if decViews > 99 {
                    strViews = String(decViews / 100) + "m"
                } else {
                    strViews = String(decViews) + "k"
                }
                
                self.labelViewsCount.text = strViews
            } else {
                self.labelViewsCount.text = String(viewsCount)
            }
        } else {
            self.labelViewsCount.text = "0"
        }
    }
    
    override func prepareForReuse() {
        self.likeControll.reset()
        self.labelShareCount.text = "0"
        self.labelViewsCount.text = "0"
        self.labelCommentCount.text = "0"
    }
}
