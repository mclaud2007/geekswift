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
    var FriendListFiltered: [Friend] = []
    
    // Список букв пользователей для контрола
    var FriendAlphabetList: [String] = []
    
    // Список пользователей разделенных по буквам
    var FriendsAlphabetList: Dictionary<String,[Int]> = ["All":[-1]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // На этом экране нам нужна навигация
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.title = "Друзья"
        
        // Регистрируем xib в качестве прототипа ячейки
        tableView.register(UINib(nibName: "FriendsCellProto", bundle: nil), forCellReuseIdentifier: "FriendsCellProto")
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        // Собираем все первые буквы фамилий
        for (index,elemnet) in FriendsList.enumerated() {
            if (elemnet.name != "") {
                let fullNameArr = elemnet.name.split(separator: " ", maxSplits: 2)
                let firstName = fullNameArr[0]
                let lastName = fullNameArr.count > 1 ? fullNameArr[1] : nil
                var firstLetter = String(firstName.prefix(1))
                
                // Есть фамилия
                if (lastName != nil){
                    firstLetter = String(lastName!.prefix(1))
                }
                
                if (FriendAlphabetList.contains(firstLetter) == false){
                    FriendAlphabetList.append(firstLetter)
                }
                
                // Первый запуск
                if FriendsAlphabetList["All"] != nil && FriendsAlphabetList["All"]![0] == -1 {
                    FriendsAlphabetList["All"]![0] = index
                } else {
                    FriendsAlphabetList["All"]!.append(index)
                }
                
                // Запоминаем пользователя в конкретной секции
                if FriendsAlphabetList[firstLetter] == nil {
                    FriendsAlphabetList[firstLetter] = [index]
                } else {
                    FriendsAlphabetList[firstLetter]!.append(index)
                }
            }
        }
        
        if (FriendAlphabetList.count > 0){
            friendCharsControl.setChars(sChars: FriendAlphabetList )
            friendCharsControl.addTarget(self, action: #selector(catchCharChanged(_:)), for: .valueChanged)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.topItem?.title = "Друзья"
    }
    
    // MARK: Получаем текущего пользователя из массива по секции и ключу
    public func getCurrentFriend(section: Int, row: Int) -> Friend {
        if FriendListFiltered.count > 0 {
            return FriendListFiltered[row]
            
        } else {
            // Выбираем пользователя из секции и ячейки
            let SectionName = FriendAlphabetList[section]
            let FriendListFromSection = FriendsAlphabetList[SectionName]
            let CurrentFriendID = FriendListFromSection![row]
            
            return FriendsList[CurrentFriendID]
        }
    }
    
    @objc public func catchCharChanged(_ sender: FriendsSearchControl){
        if let firstLetter = friendCharsControl.selectedChar {
            // Для начала очистим фильтр (если он не пустой)
            if FriendListFiltered.count > 0 {
                // Очищаем фильтр и перезагружаем список
                FriendListFiltered.removeAll()
                tableView.reloadData()
            }
            
            // Убираем клавиатуру если она есть
            searchBar.endEditing(true)
            
            if let section = FriendAlphabetList.firstIndex(of: firstLetter) {
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
            let CurrentFriend = getCurrentFriend(section: indexPath.section, row: indexPath.row)
            
            destinationVC.title = CurrentFriend.name
            
            if CurrentFriend.photos != nil {
                // Дальше надо заменить на передачу ID пользователя, а экран фото должен сам запрсоить данные
                destinationVC.PhotosLists = CurrentFriend.photos!
                destinationVC.Likes = CurrentFriend.likes!
                destinationVC.Liked = CurrentFriend.liked!
            }
        }
    }
}

// Реализация поиска
extension FriendsFormController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Очищаем фильтрованный список
        FriendListFiltered.removeAll()
        
        
        
        if searchText.count >= 2 {
            for Friend in FriendsList {
                if Friend.name.contains(searchText) {
                    FriendListFiltered.append(Friend)
                }
            }
        }
        
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.searchTextField.text {
            if searchText.count < 2 {
                show(message: "Для поиска необходимо минимум два символа")
            }
        }
        
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.searchTextField.text = ""
        searchBar.endEditing(true)
        
        // Очищаем фильтрованный список
        FriendListFiltered.removeAll()
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
        if FriendListFiltered.count > 0 {
            return ""
        } else {
            if let headTitle:String = FriendAlphabetList[section] {
                return headTitle
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
        let CurrentFriend = getCurrentFriend(section: indexPath.section, row: indexPath.row)
        
        // Configure the cell...
        cell.lblFriendsName.text = CurrentFriend.name
        
        if CurrentFriend.photo != nil {
            cell.FriendPhotoImageView.showImage(image: CurrentFriend.photo!)
        } else {
            cell.FriendPhotoImageView.showImage(image: UIImage(named: "photonotfound")!)
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Если фильтрованный массив не пучтой, значит у нас будет одна секция
        if FriendListFiltered.count > 0 {
            return 1
        } else {
            return FriendAlphabetList.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if FriendListFiltered.count > 0 {
            return FriendListFiltered.count
            
        } else {
            if let FriendSectionList = FriendsAlphabetList[FriendAlphabetList[section]] {
                return FriendSectionList.count
            }
        }
        
        return 0
    }
    
    
}
