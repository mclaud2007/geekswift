//
//  NewsImageContentCell.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 02.06.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit

class NewsImageContentCell: UITableViewCell {
    // Фотография для новости
    private(set) lazy var imgNewsPhoto: UIImageView = {
        let image = UIImageView()
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
    
    fileprivate func configureView() {
        self.addSubview(self.imgNewsPhoto)
        
        // Фотография должна быть на всю ячейку
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            self.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor),
            self.imgNewsPhoto.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            self.imgNewsPhoto.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor),
            self.imgNewsPhoto.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor),
            self.imgNewsPhoto.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    override func prepareForReuse() {
        self.imgNewsPhoto.image = nil
    }

    public func configureFrom(news: News) {
        if let picture = news.picture {
            photoService.getPhotoBy(urlString: picture, catrgory: "news") { [weak self] image in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if let image = image {
                        self.imgNewsPhoto.image = image
                    }
                }
            }
        }
    }
}
