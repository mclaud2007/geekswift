//
//  SharedControll.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 08.06.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit

class SharedControll: UIControl {
    private(set) lazy var lblShare: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.text = "0"
        return label
    }()
    
    private(set) lazy var imgShare: UIImageView = {
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: 12, height: 12))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(systemName: "arrowshape.turn.up.right.fill")
        image.tintColor = .gray
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
        
        view.addSubview(self.imgShare)
        view.addSubview(self.lblShare)
        
        return view
    }()
    
    func setShared(shared: Int? = 0) {
        self.lblShare.text = String(shared ?? 0)
    }
    
    func reset() {
        self.lblShare.text = "0"
    }
    
    func setupView() {
        self.addSubview(self.viewBackground)
        
        NSLayoutConstraint.activate([
            self.viewBackground.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor),
            self.viewBackground.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor),
            self.viewBackground.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            self.viewBackground.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            self.imgShare.heightAnchor.constraint(lessThanOrEqualToConstant: 12),
            self.imgShare.widthAnchor.constraint(lessThanOrEqualToConstant: 12),
            self.imgShare.leftAnchor.constraint(lessThanOrEqualTo: self.safeAreaLayoutGuide.leftAnchor, constant: 5),
            self.imgShare.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 2),
            self.lblShare.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 1),
            self.lblShare.rightAnchor.constraint(lessThanOrEqualTo: self.safeAreaLayoutGuide.rightAnchor, constant: -5)
        ])
    }
}
