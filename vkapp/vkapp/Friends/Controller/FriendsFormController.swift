//
//  FriendsFormController.swift
//  weather
//
//  Created by Григорий Мартюшин on 09.11.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class FriendsFormController: UIViewController {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    @IBOutlet weak var friendCharsControl: FriendsSearchControl! {
        didSet {
            friendCharsControl.delegate = self
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    
    // Здесь будут список наших пользователей
    var FriendsList: [Friend] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    // Отфильтрованный список пользователей
    var ListOfFilterdFriends: [Friend] = []
    
    // Список букв пользователей для контрола
    var ListOfFirstCharOfLastname: [String] = []
    
    // Список пользователей разделенных по буквам
    var ListOfFriendByAlphabet: Dictionary<String,[Int]> = ["All":[-1]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Устанавливаем название экрана
        self.title = "Друзья"
        
        // Регистрируем xib в качестве прототипа ячейки
        tableView.register(UINib(nibName: "FriendsCellProto", bundle: nil), forCellReuseIdentifier: "FriendsCellProto")
        
        // Загружаем данные и перезагружаем tableView
        VK.shared.getFriendsList() { (friendList,error) in
            guard error == nil else { return }
            
            if let friends = friendList {
                self.FriendsList = friends
                
                if self.FriendsList.count > 0 {
                    // Собираем все первые буквы фамилий
                    for (index,elemnet) in self.FriendsList.enumerated() {
                        if !elemnet.name.isEmpty {
                            let fullNameArr = elemnet.name.split(separator: " ")

                            // Для простоты будем думать что формат у записи ФИ
                            let firstName = fullNameArr[0]
                            let lastName = fullNameArr.count > 1 ? fullNameArr.last : nil

                            // Первая буква фамили или, если ее нет - то имени
                            let firstLetter = String(lastName?.prefix(1) ?? firstName.prefix(1))

                            // Если такой буквы у нас еще нет - добавим её
                            if !self.ListOfFirstCharOfLastname.contains(firstLetter) {
                                self.ListOfFirstCharOfLastname.append(firstLetter)
                            }

                            // Запоминаем пользователя в конкретной секции
                            if self.ListOfFriendByAlphabet[firstLetter] == nil {
                                self.ListOfFriendByAlphabet[firstLetter] = [index]
                            } else {
                                self.ListOfFriendByAlphabet[firstLetter]!.append(index)
                            }
                        }
                    }

                    // Друзья найдены - нужно инициализировать контрол для поиска по первой букве фамилии
                    if (self.ListOfFirstCharOfLastname.count > 0){
                        self.friendCharsControl.setChars(sChars: self.ListOfFirstCharOfLastname )
                    }
                    
                    // Загружаем данные
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    // MARK: Получаем текущего пользователя из массива по секции и ключу
    public func getCurrentFriend(section: Int, row: Int) -> Friend? {
        if ListOfFilterdFriends.count > 0 {
            if ListOfFilterdFriends.indices.contains(row) {
                return ListOfFilterdFriends[row]
            }
            
        } else {
            // Выбираем пользователя из секции и ячейки
            if ListOfFirstCharOfLastname.indices.contains(section) {
                // Получаем букву по которой будем искать друзей
                let SectionName = ListOfFirstCharOfLastname[section]
                
                // Пользователи на выбранную букву существуют
                if ListOfFriendByAlphabet[SectionName] != nil {
                    // И осталось выяснить внутри есть кто-нибудь
                    if ListOfFriendByAlphabet[SectionName]!.indices.contains(row) {
                        let CurrentFriendID = ListOfFriendByAlphabet[SectionName]![row]
                        
                        if FriendsList.indices.contains(CurrentFriendID) {
                            return FriendsList[CurrentFriendID]
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotos",
            let destinationVC = segue.destination as? FriendsPhotoController,
            let indexPath = tableView.indexPathForSelectedRow {
            
            // Выбираем пользователя из секции и ячейки
            if let CurrentFriend = getCurrentFriend(section: indexPath.section, row: indexPath.row) {
                // Устанавливаем название экрана
                destinationVC.title = CurrentFriend.name
                
                // Единственное что требуется - это передать id пользователя
                destinationVC.FriendID = CurrentFriend.userId

            } else {
                showErrorMessage(message: "Данные не найдены")
            }
        }
    }
}

extension FriendsFormController: FriendsSearchControlProto {
    func charSelected(sender: FriendsSearchControl) {
         if let firstLetter = friendCharsControl.selectedChar {
             // Для начала очистим фильтр (если он не пустой)
             if ListOfFilterdFriends.count > 0 {
                 // Очищаем фильтр и перезагружаем список
                 ListOfFilterdFriends.removeAll()
                 tableView.reloadData()
             }
             
             // Убираем клавиатуру если она есть
             searchBar.endEditing(true)
             
             if let section = ListOfFirstCharOfLastname.firstIndex(of: firstLetter) {
                 // Просто мотаем к нужной секции
                 tableView.scrollToRow(at: IndexPath(row: 0, section: section), at: .top, animated: true)
             }
         }
    }
}

// Реализация поиска
extension FriendsFormController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Очищаем фильтрованный список
        ListOfFilterdFriends.removeAll()
        
        if FriendsList.count > 0 {
            for Friend in FriendsList {
                if Friend.name.contains(searchText) {
                    ListOfFilterdFriends.append(Friend)
                }
            }
        }
        
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.searchTextField.text = ""
        searchBar.endEditing(true)
        
        // Очищаем фильтрованный список
        ListOfFilterdFriends.removeAll()
        tableView.reloadData()
    }
}

extension FriendsFormController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowPhotos", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: Реализация протокола загрузки данных в таблицу
extension FriendsFormController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Пользователи отфильтрованы - там не будем разбивать пока на буквы
        if ListOfFilterdFriends.count > 0 {
            return ""
        } else {
            if ListOfFirstCharOfLastname.indices.contains(section) {
                return ListOfFirstCharOfLastname[section]
            } else {
                return ""
            }
        }
    }

    // MARK: Подготовка ячейки к выводу
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsCellProto", for: indexPath) as? FriendsCellProto else {
            preconditionFailure("Error")
        }
        
        // Выбираем пользователя из секции и ячейки
        if let CurrentFriend = getCurrentFriend(section: indexPath.section, row: indexPath.row) {
            // Configure the cell...
            cell.configure(with: CurrentFriend, indexPath: indexPath)
            cell.FriendPhotoImageView.delegate = self
            
        } else {
            cell.lblFriendsName.text = "Not found!"
            cell.FriendPhotoImageView.showImage(image: getNotFoundPhoto(), indexPath: indexPath)
        }
        
        return cell
    }
    
    // MARK: Колличество секций
    func numberOfSections(in tableView: UITableView) -> Int {
        // Если фильтрованный массив не пустой, значит у нас будет одна секция
        if ListOfFilterdFriends.count > 0 {
            return 1
            
        } else {
            return ListOfFirstCharOfLastname.count
            
        }
    }
    
    // MARK: Колличество строк в секции
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ListOfFilterdFriends.count > 0 {
            return ListOfFilterdFriends.count
        } else {
            if let FriendSectionList = ListOfFriendByAlphabet[ListOfFirstCharOfLastname[section]] {
                return FriendSectionList.count
            }
        }
        
        return 0
    }
}

// MARK: Реализация клика по аватару
extension FriendsFormController: AvatarViewProto {
    func click(sender: AvatarView) {
        if let indexPath = sender.CurrentIndexPath {
            // Выберем ячейку, чтобы при подготовке сеги передались корректные данные
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            
            // Выполняем сегу
            performSegue(withIdentifier: "ShowPhotos", sender: self)
            
            // Убираем выделение ячейки
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
