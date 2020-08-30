//
//  FriendsListController.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 01.05.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit

class FriendsListController: UIViewController {
    // MARK: Properties
    // Вью текщуего контроллера закасчена под кастомный класс
    var friendsListView: FriendsListView {
        return view as! FriendsListView
    }

    // TableView
    var tableView: UITableView!

    // SearchBar
    var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    
    // Список первых букв фамилий
    var lastNameFirstLetters: [String] = []
    
    // Друзья разбитые на секии
    var friendInSections: [Int: [Friend]] = [:]

    // Список друзей
    var friendsList: [Friend] = [] {
        didSet {
            // На всякий случай очищаем системные массивы
            friendInSections.removeAll()
            lastNameFirstLetters.removeAll()
            
            lastNameFirstLetters = Array(Set(friendsList
                                                    // Выбираем всех друзей у которых есть фамилия
                                                    .compactMap({ $0.name.split(separator: " ").last?.first })
                                                    // Преобразуем Character (который вернул предыдущий фильтр
                                                    .map { String($0) })
                                        )
                                        // Сортируем получившийся массив по алфавиту
                                        .sorted { $0 < $1 }
                        
            // Пройдемся по массиву букв и соберем всех пользователей
            for (section, letter) in lastNameFirstLetters.enumerated() {
                let foundFriend = friendsList.filter { friend -> Bool in
                    if let fLetter = friend.name.split(separator: " ").last?.first,
                        String(fLetter) == letter
                    {
                        return true
                    } else {
                        return false
                    }
                }
                
                // Добавляем пользователей на выбранную букву в секцию этой буквы
                if let _ = friendInSections[section] {
                    friendInSections[section]?.append(contentsOf: foundFriend)
                } else {
                    friendInSections[section] = foundFriend
                }
            }
        }
    }
    
    // При поиске сюда будем скидывать изначальный список друзей, для пересортировки в последствии
    var friendListOrigin: [Friend]?
    
    // MARK: Lifecycle
    override func loadView() {
        super.loadView()
        view = FriendsListView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Style.friendScreen.background
        self.title = NSLocalizedString("Friends", comment: "")
        
        // Инициализируем TableView и searchBar
        tableView = friendsListView.tableView
        tableView.delegate = self
        tableView.dataSource = self
        
        // Регистрируем класс ячейки таблицы
        tableView.register(FriendsTableViewCell.self, forCellReuseIdentifier: "friendsTableViewCell")
        
        // Строка поиска
        searchBar = friendsListView.searchController.searchBar
        self.definesPresentationContext = true

        // Загружаем список друзей
        VKService.shared.getFriendsList { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let friendsArray):
                self.friendsList = friendsArray
                
                // И обновляем таблицу
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                break
            case .failure(_):
                DispatchQueue.main.async {
                    self.showErrorMessage(message: NSLocalizedString("Something went wrong", comment: ""))
                }
                
                break
            }
        }       
        
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
}

// MARK: UITableViewDelegate
extension FriendsListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friendDetail = FriendDetailController()
        
        if let friends = friendInSections[indexPath.section] {
            friendDetail.selectFriend = friends[indexPath.row]
            navigationController?.pushViewController(friendDetail, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

// MARK: UITableViewDataSource
extension FriendsListController: UITableViewDataSource {
    // Список первых букв фамилий для быстрого перехода
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        lastNameFirstLetters
    }
    
    // Для заголовка секции выводим первую букву фамилии
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        lastNameFirstLetters[section]
    }
    
    
    
    // Количество секций - это количество букв фамилий
    func numberOfSections(in tableView: UITableView) -> Int {
        return lastNameFirstLetters.count
    }
    
    // Секции могли оказаться пустыми (вдруг что-то пошло не так с фильтром)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if friendInSections.count > 0,
            let friends = friendInSections[section]
        {
            return friends.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendsTableViewCell") as? FriendsTableViewCell else {
            preconditionFailure("Error")
        }
     
        if let friends = friendInSections[indexPath.section] {
            cell.configureFrom(friend: friends[indexPath.row], at: indexPath)
            
            // Если у нас не объявлен делегат
            if cell.imageFriendAvatar.delegate == nil {
                cell.imageFriendAvatar.delegate = self
            }
            
            
        }
        
        return cell
    }
}

// MARK: UISearchBarDelegate
extension FriendsListController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Текст поиска пустой, а оригинальный список друзей нет - значит это отмена поиска
        if let friendListOrigin = friendListOrigin,
            friendListOrigin.count > 0,
            searchText.isEmpty
        {
            self.friendsList = friendListOrigin
            self.friendListOrigin = nil
        }
        // В противном случае это поиск
        else {
            // Перед поиском сохраним первоначальный список для отмены или пересортировки
            if friendListOrigin == nil {
                friendListOrigin = friendsList
            }
            
            // Удалим старый список друзей
            friendsList.removeAll()
            
            // И сформируем его заново из сохраненной копии
            if let friendListOrigin = friendListOrigin {
                friendsList = friendListOrigin.filter { friend in
                    return friend.name.contains(searchText)
                }
            }
        }
        
        // В любом случае перезагружаем данные
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if let friendListOrigin = friendListOrigin,
            friendListOrigin.count > 0
        {
            self.friendsList = friendListOrigin
            self.friendListOrigin = nil
            tableView.reloadData()
        }
    }
}

// MARK: AvatarControllDelegate
extension FriendsListController: AvatarControllDelegate {
    func click(sender: AvatarControll) {
        if let indexPath = sender.indexPath {
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            
            // Переходим на страницу подробностей
            let friendDetail = FriendDetailController()
            
            if let friends = friendInSections[indexPath.section] {
                friendDetail.selectFriend = friends[indexPath.row]
                navigationController?.pushViewController(friendDetail, animated: true)
            }
            
            // Снимаем выбор ячейки
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

extension FriendsListController: TabBarScrollToTop {
    func doScroll() {
        tableView.setContentOffset(.zero, animated: true)
    }
}
