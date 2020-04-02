//
//  NewsFormController.swift
//  weather
//
//  Created by Григорий Мартюшин on 09.11.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class NewsFormController: UIViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.prefetchDataSource = self
        }
    }
    
    @IBOutlet weak var btnLogout: UIBarButtonItem!
    
    var newsList = [News]()
    var nextFrom: String?
    var newsLoading = false
    
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
        VKService.shared.getNewsList { [weak self] (result, next_from)  in
            guard let self = self else { return }
            
            switch result {
            case let .success(newsList):
                self.newsList = newsList
                self.nextFrom = next_from
                self.tableView.reloadData()
            case let .failure(err):
                self.showErrorMessage(message: err.localizedDescription)
            }
        }
        
        // Инициилизируем refreshControl
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.attributedTitle = NSAttributedString(string: NSLocalizedString("Loading ...", comment: ""))
        tableView.refreshControl?.addTarget(self, action: #selector(getReloadNews), for: .valueChanged)
    }
    
    @objc func getReloadNews(){
        if let newsList = self.newsList.first,
            let uxDateTime = newsList.unixDateTime
        {
            // Загружаем новости
            VKService.shared.getNewsList(startFrom: nil, startTime: uxDateTime + 1) { [weak self] (result, next_from)  in
                guard let self = self else { return }
                
                switch result {
                case let .success(news):
                    let localNewsList = self.newsList
                    self.newsList.removeAll()
                    
                    // Добавляем новые новости в конец списка
                    self.newsList = news + localNewsList
                    
                    // Присваиваем новый адрес следующей страницы
                    self.nextFrom = next_from
                    
                    // Добавляем новые новости в конец
                    self.tableView.reloadData()
                    
                case let .failure(err):
                    self.showErrorMessage(message: err.localizedDescription)
                }
                
                self.newsLoading = false
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }
}

extension NewsFormController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1,
            newsList.indices.contains(indexPath.section)
        {
            if let ratio = newsList[indexPath.section].aspectRatio {
                return (tableView.bounds.width * ratio).rounded()
            }
            
            
            return 0
            
        } else if indexPath.row == 2 {
            return 35
        } else {
            return UITableView.automaticDimension
        }
    }
}

extension NewsFormController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let maxSection = indexPaths.map({ $0.section }).max() else { return }
        
        let newsCount = newsList.count
        
        if let nextFrom = nextFrom,
            // Нам нужно подгружать следующую страницу, только когда новости уже есть
            // за три секции до конца списка, в случае если не ведется загрузка
            (newsCount > 0 && ((newsCount - 3) < maxSection) && !newsLoading)
        {
            newsLoading = true
            
            // Загружаем новости
            VKService.shared.getNewsList(startFrom: nextFrom, startTime: nil) { [weak self] (result, next_from)  in
                guard let self = self else { return }
                
                switch result {
                case let .success(news):
                    let startIndex = self.newsList.count
                    let endIndex = startIndex + news.count
                    let indexSet = IndexSet(integersIn: startIndex ..< endIndex)
                    
                    // Добавляем новые новости в конец списка
                    self.newsList.append(contentsOf: news)
                    
                    // Присваиваем новый адрес следующей страницы
                    self.nextFrom = next_from
                    
                    // Добавляем новые новости в конец
                    self.tableView.insertSections(indexSet, with: .automatic)
                    
                case let .failure(err):
                    self.showErrorMessage(message: err.localizedDescription)
                }
                
                self.newsLoading = false
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
