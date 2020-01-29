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
        
        // Регистрируем xib в качестве прототипа ячейки для аватара
        tableView.register(UINib(nibName: "NewsTableCell", bundle: nil), forCellReuseIdentifier: "NewsTableCell")
        
        // Регистрируем xib в качестве прототипа ячейки для фото
        tableView.register(UINib(nibName: "NewsImageCell", bundle: nil), forCellReuseIdentifier: "NewsTableImage")
        
        // Xib для строчки поделитс
        tableView.register(UINib(nibName: "NewsShareCell", bundle: nil), forCellReuseIdentifier: "NewsTableShare")
        
        // Локлизация
        title = NSLocalizedString("News", comment: "")
        btnLogout.title = NSLocalizedString("Logout", comment: "")
        btnLogout.tintColor = DefaultStyle.self.Colors.tint
        
        // Загружаем новости
        VKService.shared.getNewsList() { result  in
            switch result {
            case let .success(newsList):
                self.newsList = newsList
                self.tableView.reloadData()
            case let .failure(err):
                self.showErrorMessage(message: err.localizedDescription)
            }
        }
    }
}

extension NewsFormController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return newsList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var newsCell: News?
        
        if newsList.indices.contains(indexPath.section) {
            newsCell = newsList[indexPath.section]
        }
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableCell", for: indexPath) as! NewsTableCell
            
            if let news = newsCell {
                cell.configure(with: news, indexPath: indexPath)
            }
            
            return cell
            
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableImage", for: indexPath) as! NewsImageCell
            
            if let news = newsCell {
                cell.configure(with: news, indexPath: indexPath)
            }
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableShare", for: indexPath) as! NewsShareCell
            
            if let news = newsCell {
                cell.configure(with: news, indexPath: indexPath)
                cell.likeControl.delegate = self
            }
            
            return cell
        }
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
