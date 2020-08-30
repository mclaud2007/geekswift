//
//  FriendDetailView.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 04.06.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit

class FriendDetailView: UIView {
    // MARK: Properties
    private(set) lazy var friendCollections: UICollectionView = {
        let collection = UICollectionView(frame: self.frame, collectionViewLayout: CustomCollectionViewLayout())
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()

    // MARK: Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    fileprivate func configureView() {
        self.addSubview(self.friendCollections)
        
        NSLayoutConstraint.activate([
            self.friendCollections.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 10),
            self.friendCollections.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: -10),
            self.friendCollections.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            self.friendCollections.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 10)
        ])
    }
}
