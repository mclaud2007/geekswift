//
//  FriendsListView.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 04.05.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit

class FriendsListView: UIView {
    // MARK: Properties
    public lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isUserInteractionEnabled = true
        return tableView
    }()
        
    public lazy var searchController: UISearchController = {
        let controller = UISearchController()
        controller.definesPresentationContext = false
        controller.obscuresBackgroundDuringPresentation = false
        controller.hidesNavigationBarDuringPresentation = false
        controller.hidesBottomBarWhenPushed = false
        return controller
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
    
    private func configureView() {
        self.addSubview(self.tableView)
        
        // Добавлеяем в заголовок поисковую строку
        self.tableView.tableHeaderView = self.searchController.searchBar
                
        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            self.tableView.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor),
            self.tableView.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        self.tableView.tableHeaderView?.layoutIfNeeded()
        self.tableView.tableHeaderView = self.tableView.tableHeaderView
    }
}
