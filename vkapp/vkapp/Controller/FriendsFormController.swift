//
//  FriendsFormController.swift
//  weather
//
//  Created by Григорий Мартюшин on 09.11.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class FriendsFormController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var friendCharsControl: FriendsSearchControl!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let FriendsList = [
        Friend(photo: UIImage(named: "bruce")!,
               name: "Брюс Уиллис",
               photos: [
                        UIImage(named: "bruce1")!,
                        UIImage(named: "bruce2")!,
                        UIImage(named: "bruce3")!,
                        UIImage(named: "bruce4")!,
                        UIImage(named: "bruce")!
                       ],
               likes: [10, 11, 15, 20, 50],
               liked: [1,2,4]

        ),
        Friend(photo: UIImage(named: "arnold")!,
               name: "Арнольд Шварценеггер",
               photos: [
                        UIImage(named: "arnold1")!,
                        UIImage(named: "arnold2")!,
                        UIImage(named: "arnold3")!,
                        UIImage(named: "arnold4")!,
                        UIImage(named: "arnold5")!,
                        UIImage(named: "arnold")!
                       ],
               likes: [13, 16, 21, 25, 43],
               liked: [1,3]),
        Friend(name: "Сильвестер Сталоне"),
        Friend(name: "Джейсон Стеттем"),
        Friend(name: "Сэмюэл Л. Джексон"),
        Friend(name: "Киану Ривз"),
        Friend(name: "Жан-Клод Ван Дамм"),
        Friend(name: "Чак Норрис"),
        Friend(name: "Джеки Чан"),
        Friend(name: "Рутгер Хауэр")
    ]
    
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
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        // Собираем все первые буквы фамилий
        for (index,elemnet) in FriendsList.enumerated() {
            if !elemnet.name.isEmpty {
                let fullNameArr = elemnet.name.split(separator: " ")
                
                // Для простоты будем думать что формат у записи ФИ
                let firstName = fullNameArr[0]
                let lastName = fullNameArr.count > 1 ? fullNameArr.last : nil
                
                // Первая буква фамили или, если ее нет - то имени
                let firstLetter = String(lastName?.prefix(1) ?? firstName.prefix(1))
                
                // Если такой буквы у нас еще нет - добавим её
                if !ListOfFirstCharOfLastname.contains(firstLetter) {
                    ListOfFirstCharOfLastname.append(firstLetter)
                }
                
                // Запоминаем пользователя в конкретной секции
                if ListOfFriendByAlphabet[firstLetter] == nil {
                    ListOfFriendByAlphabet[firstLetter] = [index]
                } else {
                    ListOfFriendByAlphabet[firstLetter]!.append(index)
                }
            }
        }
        
        // Друзья найдены - нужно инициализировать контрол для поиска по первой букве фамилии
        if (ListOfFirstCharOfLastname.count > 0){
            friendCharsControl.setChars(sChars: ListOfFirstCharOfLastname )
            friendCharsControl.addTarget(self, action: #selector(catchCharChanged(_:)), for: .valueChanged)
        }
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.navigationBar.topItem?.title = "Друзья"
//    }
    
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
    
    @objc public func catchAvatarViewClicked(_ sender: AvatarView){
        if let indexPath = sender.CurrentIndexPath {
            // Выберем ячейку, чтобы при подготовке сеги передались корректные данные
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            
            // Выполняем сегу
            performSegue(withIdentifier: "ShowPhotos", sender: self)
            
            // Убираем выделение ячейки
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @objc public func catchCharChanged(_ sender: FriendsSearchControl){
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotos",
            let destinationVC = segue.destination as? FriendsPhotoController,
            let indexPath = tableView.indexPathForSelectedRow {
            
            // Выбираем пользователя из секции и ячейки
            if let CurrentFriend = getCurrentFriend(section: indexPath.section, row: indexPath.row) {
                destinationVC.title = CurrentFriend.name
                
                if let photos = CurrentFriend.photos {
                    // Передаем фото, они точно есть (проверили выше) лайки передаем либо значения ли дефолт
                    destinationVC.PhotosLists = photos
                    destinationVC.Likes = CurrentFriend.likes ?? [-1]
                    destinationVC.Liked = CurrentFriend.liked ?? [-1]
                }
            } else {
                showErrorMessage(message: "Данные не найдены")
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsCellProto", for: indexPath) as? FriendsCellProto else {
            preconditionFailure("Error")
        }
        
        // Выбираем пользователя из секции и ячейки
        if let CurrentFriend = getCurrentFriend(section: indexPath.section, row: indexPath.row) {
            // Configure the cell...
            cell.lblFriendsName.text = CurrentFriend.name
            
            if let photos = CurrentFriend.photo {
                cell.FriendPhotoImageView.showImage(image: photos, indexPath: indexPath)
            } else {
                cell.FriendPhotoImageView.showImage(image: getNotFoundPhoto(), indexPath: indexPath)
            }
            
            // Вешаем обработчик на клик по аватару
            cell.FriendPhotoImageView.addTarget(self, action: #selector(catchAvatarViewClicked(_:)), for: .touchUpInside)
        } else {
            cell.lblFriendsName.text = "Not found!"
            cell.FriendPhotoImageView.showImage(image: getNotFoundPhoto(), indexPath: indexPath)
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Если фильтрованный массив не пустой, значит у нас будет одна секция
        if ListOfFilterdFriends.count > 0 {
            return 1
            
        } else {
            return ListOfFirstCharOfLastname.count
            
        }
    }
    
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
