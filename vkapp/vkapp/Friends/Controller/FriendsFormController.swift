//
//  AllFriendsList.swift
//  VKApp
//
//  Created by Григорий Мартюшин on 09.11.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit
import RealmSwift
import PromiseKit
import SwiftyJSON

class FriendsFormController: UIViewController {
    // MARK: Outlets
    
    // Таблица пользователей
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    // Кнопка "Выход"
    @IBOutlet weak var btnLogout: UIBarButtonItem!
    
    // Контрол с выбором первых букв фамилий
    @IBOutlet weak var friendCharsControl: FriendsSearchControl! {
        didSet {
            friendCharsControl.delegate = self
        }
    }
    
    // Поисковая строка
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.placeholder = NSLocalizedString("Search", comment: "")
            searchBar.delegate = self
        }
    }
    
    // MARK: Properties
    // Здесь будут список наших пользователей
    var friendList = [Friend]() {
        // При присвоении значения построем зависимые от этого списки
        didSet {
            // Обновляем разбиение друзей по буквам
            self.updateFriendCharactersMap()
            
            // И перезагружаем данные в таблице
            self.tableView.reloadData()
        }
    }
    
    // Отфильтрованный список пользователей
    var listOfFilteredFriends = [Friend]()
    
    // Список пользователей разделенных по буквам
    var listOfFriendByAlphabet = Dictionary<String,[Int]>()
    
    // Что выводить будем проверять по флагу
    var isFiltered = false
    
    // Список букв пользователей для контрола
    var firstCharOfLastName = [String]() {
        didSet {
            // Инициализиаруем контрол списком букв друзей
            self.friendCharsControl.setChars(sChars: self.firstCharOfLastName)
        }
    }
    
    // Токен изменений реалма
    var token: NotificationToken?
    
    // MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // И локализованное название кнопки
        btnLogout.title = NSLocalizedString("Logout", comment: "")
        btnLogout.tintColor = DefaultStyle.self.Colors.tint
        
        // Регистрируем xib в качестве прототипа ячейки
        tableView.register(UINib(nibName: "FriendsCellProto", bundle: nil), forCellReuseIdentifier: "FriendsCellProto")
        
        // Подписываемся на изменение данных
        subscribeToRealmChanges()

        // Загружаем данные в реалм, а его обсервер (объявлен выше) обновит список пользователей,
        // который в свою очередь вызовет обновление зависимых от него списков и обновит tableView
        VKService.shared.getFriendsList().then { [weak self] data -> Promise<[Friend]> in
            guard let self = self else { preconditionFailure("error") }
            
            return Promise { seal in
                let json = JSON(data)
                
                if let friends = self.parseFriends(with: json) {
                    seal.fulfill(friends)
                } else {
                    seal.reject(VKService.VKError.FriendListIsEmpty)
                }
            }
        }
        .done { friendList in
            do {
                for friend in friendList {
                    try RealmService.save(items: friend)
                }
            } catch let err {
                self.showErrorMessage(message: err.localizedDescription)
            }
        }
        .catch { err in
            self.showErrorMessage(message: err.localizedDescription)
        }
        
        // Устанавливаем название экрана
        title = NSLocalizedString("Friends", comment: "")
        
        // Локализуем кнопку назад
        navigationItem.backBarButtonItem?.title = NSLocalizedString("Back", comment: "")
        navigationItem.backBarButtonItem?.tintColor = DefaultStyle.self.Colors.tint
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Локализуем кнопку назад
        navigationController?.navigationItem.backBarButtonItem?.title = NSLocalizedString("Back", comment: "")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotos",
            let destinationVC = segue.destination as? FriendsPhotoController,
            let indexPath = tableView.indexPathForSelectedRow {
            
            // Выбираем пользователя из секции и ячейки
            if let currentFriend = getCurrentFriend(section: indexPath.section, row: indexPath.row) {
                // Единственное что требуется - это передать id пользователя
                destinationVC.selectedFriend = currentFriend

            } else {
                showErrorMessage(message: "Данные не найдены")
            }
        }
    }
    
    // При уничтожении экрана отпишемся от обсервера реалма
    deinit {
        self.token?.invalidate()
    }
    
    // MARK: Custom Methods
    // Скрываем клавиатуру по клику на вьюху
    @objc func cancelSearchWhenViewTapped () {
        searchBar.endEditing(true)
    }
    
    fileprivate func parseFriends(with json: JSON) -> [Friend]? {
        if json["response"]["count"].intValue > 0,
            let friends = json["response"]["items"].array {
    
            // Список найденых пользователей
            var friendList = [Friend]()
            
            // Создаем список пользователей
            for friend in friends {
                if let firstName = friend["first_name"].string,
                    let lastName = friend["last_name"].string,
                    let uID = friend["id"].int,
                    let avatarUrlString = friend["photo_50"].string,
                    friend["deactivated"].stringValue != "deleted"
                {
                    let city = friend["city"]["title"].stringValue
                    
                    friendList.append(Friend(userId: uID, photo: avatarUrlString, name: firstName + " " + lastName, city: city))
                }
            }
            
            if friendList.count > 0 {
                return friendList
            }
        }
        
        return nil
    }
    
    // Подписываемся на изменения данных в реалм
    fileprivate func subscribeToRealmChanges () {
        do {
            let realmFriendList = try RealmService.get(Friend.self)

            // Подпишемся на обновление списка
            self.token = realmFriendList.observe { [weak self] (changes: RealmCollectionChange) in
                guard let self = self else { return }
                
                // Меняем сначала в локальной переменной
                var localFriendsList = self.friendList
                
                switch changes {
                case let .initial(results):
                    if results.count > 0 {
                        // Собираем список друзей
                        for item in results {
                            localFriendsList.append(item)
                        }
                    }
                    
                case let .update(res, del, ins, mod):
                    // Из базы пропала запись
                    if (del.count > 0) {
                        // Удаление из базы
                        for i in 0..<del.count {
                            if localFriendsList.indices.contains(del[i]) {
                                localFriendsList.remove(at: del[i])
                            }
                        }
                        
                    } else if ins.count > 0 {
                        // Добавление записи
                        for i in 0..<ins.count {
                            if res.indices.contains(ins[i]) {
                                localFriendsList.append(res[ins[i]])
                            }
                        }
                        
                    } else if mod.count > 0 {
                        // Запись обновилась
                        for i in 0..<mod.count {
                            if (localFriendsList.indices.contains(mod[i]) && res.indices.contains(mod[i])) {
                                // И добавить новую
                                localFriendsList[mod[i]] = res[mod[i]]
                            }
                        }
                    }
                    
                case let .error(err):
                    self.showErrorMessage(message: err.localizedDescription)
                }
                
                // Обновляем список друзей
                self.friendList.removeAll()
                
                // Внутри групп отсортируем по имни
                self.friendList = localFriendsList.sorted(by: { $0.name.prefix(1) < $1.name.prefix(1) })
            }
            
        } catch let err {
            self.showErrorMessage(message: err.localizedDescription)
        }
    }

    // Строим массив содержащий уникальные первые буквы фамилий
    fileprivate func updateFriendCharactersMap () {
        // Надо обнулить те массивы, что будем здесь заполнять
        firstCharOfLastName.removeAll()
        
        // Список друзей которым мы будем в дальнейшем манипулировать
        // по - умолчанию это полный список друзей
        if isFiltered == true {
            firstCharOfLastName = Array(Set(listOfFilteredFriends.compactMap { $0.name.split(separator: " ").last?.first }.map { String($0) })).sorted(by: { $0 < $1 })
        } else {
            firstCharOfLastName = Array(Set(friendList.compactMap { $0.name.split(separator: " ").last?.first }.map { String($0) })).sorted(by: { $0 < $1 })
        }
        
        // Обновляем словарь со списком друзей разбитых по буквам
        updateSecteionedFriendList()
    }
    
    // Строит словарь соответствия Первая_Буква_Фамилии=>Индекс_в_массиве_пользователей
    fileprivate func updateSecteionedFriendList () {
        // Очищаем словарь соответствия буква - номер друга
        listOfFriendByAlphabet.removeAll()
        
        // Список друзей которым мы будем в дальнейшем манипулировать (по - умолчанию это полный список друзей)
        for (idx,friend) in getLocalFriendList().enumerated() {
            // Имя (фамилия) не должно быть пустым, а также мы должны получить первую букву
            if !friend.name.isEmpty,
                let lastNameFirstChar = friend.name.split(separator: " ").last?.first
            {
                // Первая буква есть - переведем ее в строку
                let lastNameFirstLetter = String(lastNameFirstChar)
                
                // Если на эту букву еще никого небыло - создадим массив
                if listOfFriendByAlphabet[lastNameFirstLetter] == nil {
                    listOfFriendByAlphabet[lastNameFirstLetter] = [idx]
                } else {
                    listOfFriendByAlphabet[lastNameFirstLetter]!.append(idx)
                }
            }
        }
    }
    
    // В зависимости от флага получаем тот или иной список друзей
    public func getLocalFriendList () -> [Friend] {
        (isFiltered == false ? friendList : listOfFilteredFriends)
    }
    
    // Получаем текущего пользователя из массива по секции и ключу
    public func getCurrentFriend(section: Int, row: Int) -> Friend? {
        // Выбираем пользователя из секции и ячейки
        if firstCharOfLastName.indices.contains(section) {
            // Получаем букву по которой будем искать друзей
            let sectionName = firstCharOfLastName[section]
            
            // Пользователи на выбранную букву существуют
            if listOfFriendByAlphabet[sectionName] != nil {
                // И осталось выяснить внутри есть кто-нибудь
                if listOfFriendByAlphabet[sectionName]!.indices.contains(row) {
                    let currentFriendID = listOfFriendByAlphabet[sectionName]![row]
                    
                    // Список друзей которым мы будем в дальнейшем манипулировать (по - умолчанию это полный список друзей)
                    let localFriendList = getLocalFriendList()
                    
                    if localFriendList.indices.contains(currentFriendID) {
                        return localFriendList[currentFriendID]
                    }
                }
            }
        }
        
        return nil
    }
}

// MARK: Friends search control delegate
extension FriendsFormController: FriendsSearchControlProto {
    func charSelected(sender: FriendsSearchControl) {
         if let firstLetter = friendCharsControl.selectedChar {
             // Убираем клавиатуру если она есть
             searchBar.endEditing(true)
             
             if let section = firstCharOfLastName.firstIndex(of: firstLetter) {
                 // Просто мотаем к нужной секции
                 tableView.scrollToRow(at: IndexPath(row: 0, section: section), at: .top, animated: true)
             }
         }
    }
}

// MARK: Search bar delegate
extension FriendsFormController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Очищаем фильтрованный список
        listOfFilteredFriends.removeAll()
        
        if !searchText.isEmpty {
            // Покажем кнопку "Отмена"
            searchBar.showsCancelButton = true
            
            // Выставим флаг фильтрации
            isFiltered = true
            
            if friendList.count > 0 {
                for friend in friendList {
                    // Фамилия содержит подстроку вбитую в поиск
                    if let firstCharOfLastName = friend.name.split(separator: " ").last,
                        firstCharOfLastName.lowercased().contains(searchText.lowercased()) == true {
                        listOfFilteredFriends.append(friend)
                    }
                }
                
                listOfFilteredFriends = listOfFilteredFriends.sorted(by: { $0.name.prefix(1) < $1.name.prefix(1) })
            }
        } else {
            // Прячем кнопку "Отмена"
            searchBar.showsCancelButton = false
            
            // Убираем флаг фильтрованности
            isFiltered = false
        }
            
        // Обновляем список первых букв фамилий
        updateFriendCharactersMap()
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        
        // Прячем кнопку "Отмена"
        searchBar.showsCancelButton = false
        isFiltered = false
        
        // Очищаем фильтрованный список
        listOfFilteredFriends.removeAll()
            
        // Обновляем список первых букв фамилий
        updateFriendCharactersMap()
        
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.searchTextField.text = ""
        searchBar.endEditing(true)
        
        // Прячем кнопку "Отмена"
        searchBar.showsCancelButton = false
        isFiltered = false
        
        // Очищаем фильтрованный список
        listOfFilteredFriends.removeAll()
            
        // Обновляем список первых букв фамилий
        updateFriendCharactersMap()
        
        tableView.reloadData()
    }
}

// MARK: Table view delegate
extension FriendsFormController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowPhotos", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: Table data source
extension FriendsFormController: UITableViewDataSource {
    // Вывод буквы в заголовок секции
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if firstCharOfLastName.indices.contains(section) {
            return firstCharOfLastName[section]
        } else {
            return ""
        }
    }

    // Подготовка ячейки к выводу
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsCellProto", for: indexPath) as? FriendsCellProto else {
            preconditionFailure("Error")
        }
        
        // Выбираем пользователя из секции и ячейки
        if let currentFriend = getCurrentFriend(section: indexPath.section, row: indexPath.row) {
            // Configure the cell...
            cell.configure(with: currentFriend, indexPath: indexPath)
            cell.friendPhotoImageView.delegate = self
            
        } else {
            cell.lblFriendsName.text = "Not found!"
            cell.friendPhotoImageView.showImage(image: getNotFoundPhoto(), indexPath: indexPath)
        }
        
        return cell
    }
    
    // Колличество секций
    func numberOfSections(in tableView: UITableView) -> Int {
        firstCharOfLastName.count
    }
    
    // Колличество строк в секции
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let friendSectionList = listOfFriendByAlphabet[firstCharOfLastName[section]] {
            return friendSectionList.count
        }
        
        return 0
    }
}

// MARK: Avatar view delegate
extension FriendsFormController: AvatarViewProto {
    func click(sender: AvatarView) {
        if let indexPath = sender.currentIndexPath {
            // Выберем ячейку, чтобы при подготовке сеги передались корректные данные
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            
            // Выполняем сегу
            performSegue(withIdentifier: "ShowPhotos", sender: self)
            
            // Убираем выделение ячейки
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
