//
//  FriendPhotoView.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 05.06.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit

class FriendPhotoView: UIView {
    // MARK: Properties
    private(set) lazy var imgBigPhoto: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = false
        image.layer.shadowColor = UIColor.black.cgColor
        image.layer.shadowOpacity = 0.5
        image.layer.shadowRadius = 5
        return image
    }()
    
    // MARK: Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    private func configureView() {
        self.addSubview(self.imgBigPhoto)
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self.imgBigPhoto, attribute: .centerY, relatedBy: .equal,
                           toItem: self.safeAreaLayoutGuide, attribute: .centerY,
                           multiplier: 1, constant: -10
            ),
            self.imgBigPhoto.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 10),
            self.imgBigPhoto.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: -10),
            self.imgBigPhoto.heightAnchor.constraint(equalTo: self.imgBigPhoto.widthAnchor, multiplier: 1)
        ])
    }
}
