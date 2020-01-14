//
//  NewsFormController.swift
//  weather
//
//  Created by Григорий Мартюшин on 09.11.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit
import Kingfisher

class NewsFormController: UIViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
        }
    }
    
    @IBOutlet weak var btnLogout: UIBarButtonItem!
    
    var newsList = [News]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Регистрируем xib в качестве прототипа ячейки
        tableView.register(UINib(nibName: "NewsTableCell", bundle: nil), forCellReuseIdentifier: "NewsTableCell")
        
        VK.shared.getNewsList() { (result, err)  in
            if (err == nil && result != nil) {
                self.newsList = result!
                self.tableView.reloadData()
            }
        }
        
        self.title = NSLocalizedString("News", comment: "")
        btnLogout.title = NSLocalizedString("Logout", comment: "")
        btnLogout.tintColor = DefaultStyle.self.Colors.tint
    }
}

extension NewsFormController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableCell", for: indexPath) as! NewsTableCell
    
        if newsList.indices.contains(indexPath.row) {
            let newsCell: News = newsList[indexPath.row]
        
            cell.lblLikeControl.delegate = self
            cell.configure(with: newsCell, indexPath: indexPath)
        }
        
        return cell
    }
}

// MARK: Like controller delegate
extension NewsFormController: LikeControlProto {
    func likeClicked (sender: LikeControl) {
        if (sender.isLiked == true){
            sender.likes -= 1
            sender.isLiked = false

        } else {
            sender.likes += 1
            sender.isLiked = true
            
            if (sender.likes == 0) {
                sender.likes = 1
            }
        }
        
        // Обновляем лайки
        sender.initLikes(likes: sender.likes, isLiked: sender.isLiked)
    }
}
