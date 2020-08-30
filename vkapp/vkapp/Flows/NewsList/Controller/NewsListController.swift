//
//  NewsListController.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 04.05.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit

class NewsListController: UIViewController {
    var newsListView: NewsListView {
        return view as! NewsListView
    }
    
    var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.prefetchDataSource = self
        }
    }
    
    var newsList = [News]()
    var nextFrom: String? = nil
    var newsLoading = false
    
    override func loadView() {
        super.loadView()
        self.view = NewsListView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Style.newsScreen.background
        self.title = NSLocalizedString("News", comment: "")
        
        // Инициализируем TableView
        tableView = newsListView.tableView
        tableView.backgroundColor = .separator
        tableView.separatorStyle = .none
        
        // Регистрируем класс ячейки (заголовок новости)
        tableView.register(NewsHeadCell.self, forCellReuseIdentifier: "newsHeadCell")
        
        // содержание новости (картинка)
        tableView.register(NewsImageContentCell.self, forCellReuseIdentifier: "newsImageContentCell")
        
        // полоска с кнопками
        tableView.register(NewsShareCell.self, forCellReuseIdentifier: "newsShareCell")
        
        VKService.shared.getNewsList { [weak self] (result, next_from) in
            guard let self = self else { return }
            
            // Ссылка на следующую страницу (может быть nil)
            self.nextFrom = next_from
            
            switch result {
            case let .success(newsList):
                self.newsList = newsList
                
                // Обновляем таблицу в главном потоке
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                break
            case let .failure(err):
                DispatchQueue.main.async {
                    self.showErrorMessage(message: err.localizedDescription)
                }
                
                break
            }
        }
        
        // Инициализация обновления новостей
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.attributedTitle = NSAttributedString(string: NSLocalizedString("Loading ...", comment: ""))
        tableView.refreshControl?.addTarget(self, action: #selector(getReloadNews), for: .valueChanged)

        // TODO: Кнопка выхода
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Logout", comment: ""), style: .plain, target: self, action: #selector(logout(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3"), style: .plain, target: self, action: #selector(toggleMenu(_:)))
    }

    @objc func logout(_ sender: UIBarButtonItem) {
        AppManager.shared.logout()
    }
    
    @objc func toggleMenu(_ sender: UIBarButtonItem) {
        AppManager.shared.toggleMenu()
    }
    
    @objc func getReloadNews() {
        if let firstNewsInList = newsList.first,
            let firstNewsDate = firstNewsInList.unixDateTime
        {
            VKService.shared.getNewsList(startFrom: nil, startTime: (firstNewsDate + 1)) { [weak self] (result, news_next) in
                guard let self = self else { return }
                
                self.nextFrom = news_next
                
                switch result {
                case .success(let newNewsList):
                    // Для того чтобы подгрузить новости в начало нам надо очистить предыдущий список, но не забыть его сохранить
                    // иначе пропадут все новости, которые на данный момент в спике
                    let tmpNewsList = self.newsList
                    self.newsList.removeAll()
                    self.newsList = newNewsList + tmpNewsList
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.tableView.refreshControl?.endRefreshing()
                    }
                    
                    break
                case .failure(let err):
                    // В случае ошибки просто остановим рефреш контрол
                    DispatchQueue.main.async {
                        if let errCast = err as? VKService.VKError {
                            // Во всех случаях кроме, если нет новостей - выведем ошибку
                            switch errCast {
                            case .NewsListEmpty:
                                break
                            default:
                                self.showErrorMessage(message: err.localizedDescription)
                            }
                        } else {
                            self.showErrorMessage(message: err.localizedDescription)
                        }
                        
                        self.tableView.refreshControl?.endRefreshing()
                    }
                    
                    break
                }
                
                self.newsLoading = false
                
            }
        }
    }
}

extension NewsListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 1) {
            if let ratio = newsList[indexPath.section].aspectRatio {
                return (tableView.bounds.width * ratio).rounded()
            }
            
            return 0
        }
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = Style.isDarkMode ? .black : .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let fView = UIView()
        fView.backgroundColor = Style.isDarkMode ? .black : .clear
        return fView
    }
}

extension NewsListController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        // Нам нужно начать загружать новую порцию за три секции до конца, а для этого надо расчитать максимальную на данный момент секцию
        guard let maxSection = indexPaths.map({ $0.section }).max() else { return }
        
        let newsCount = newsList.count
        
        // Для успеха мерприятия нам нужна ссылка на следущую страницу
        if let nextFrom = nextFrom,
            (newsCount > 0 && ((newsCount - 3) < maxSection && !newsLoading))
        {
            // Флаг о начале загрузки новостей, чтобы пока мы их не загрузим не запускали подгрузку заново
            newsLoading = true
            
            VKService.shared.getNewsList(startFrom: nextFrom, startTime: nil) { [weak self] (result, next_from) in
                guard let self = self else { return }
                
                // Щапоминаем новый адрес на следующую страницу
                self.nextFrom = next_from
                
                switch result {
                case let .success(newNewsList):
                    let startIndex = self.newsList.count
                    let endIndex = startIndex + newNewsList.count
                    let indexSet = IndexSet(integersIn: startIndex ..< endIndex)
                    
                    // Добавляем новые новости в конец списка
                    self.newsList.append(contentsOf: newNewsList)
                    
                    // Присваиваем новый адрес следующей страницы
                    self.nextFrom = next_from
                    
                    // Добавляем новые новости в конец
                    DispatchQueue.main.async {
                        self.tableView.insertSections(indexSet, with: .automatic)
                    }
                    
                    break
                case .failure(let err):
                    DispatchQueue.main.async {
                        self.showErrorMessage(message: err.localizedDescription)
                    }
                    
                    break
                }
                
                // Сбрасываем флаг загрузки новостей
                self.newsLoading = false
            }
            
        }
    }
}

extension NewsListController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return newsList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Заголовок новости
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "newsHeadCell") as? NewsHeadCell else {
                preconditionFailure("Error")
            }
            
            cell.configureFrom(news: newsList[indexPath.section])
            cell.selectionStyle = .none
            
            return cell
        }
        // Строка с кнопками
        else if indexPath.row == 2 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "newsShareCell") as? NewsShareCell else {
                preconditionFailure("Error")
            }
            
            cell.configureFrom(news: newsList[indexPath.section], at: indexPath)
            cell.selectionStyle = .none
            
            // Если делегат еще не объявлен - самое время
            if cell.likeControll.delegate == nil {
                cell.likeControll.delegate = self
            }
            
            return cell
        }
        // Содержание новости
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "newsImageContentCell") as? NewsImageContentCell else {
                preconditionFailure("Error")
            }
            
            cell.configureFrom(news: newsList[indexPath.section])
            cell.selectionStyle = .none
            
            return cell
        }
    }
}

extension NewsListController: LikeControllDelegate {
    func click(sender: LikeControll) {
        // Здаесь можно отправить запрос к сервер ВК, чтобы учесть лайк
    }
}

extension NewsListController: TabBarScrollToTop {
    func doScroll() {
        tableView.setContentOffset(.zero, animated: true)
    }
}
