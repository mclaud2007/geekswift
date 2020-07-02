//
//  MenuView.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 08.06.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit

class MenuView: UIView {

    private(set) lazy var lblUserName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = AppSession.shared.userName ?? "User"
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    private(set) lazy var imgUserAvatar: AvatarControll = {
        let image = AvatarControll(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.showImage(image: AppSession.shared.userAvatar ?? "photonotfound")
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    fileprivate func configureView() {
        self.addSubview(self.lblUserName)
        self.addSubview(self.imgUserAvatar)
        
        NSLayoutConstraint.activate([
            self.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 0),
            self.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: 0),
            self.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            self.lblUserName.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 10),
            self.lblUserName.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 30),
            self.imgUserAvatar.topAnchor.constraint(equalTo: self.lblUserName.bottomAnchor, constant: 10),
            self.imgUserAvatar.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 35),
            self.imgUserAvatar.widthAnchor.constraint(greaterThanOrEqualToConstant: 70),
            self.imgUserAvatar.heightAnchor.constraint(greaterThanOrEqualToConstant: 70)
        ])
    }

}
