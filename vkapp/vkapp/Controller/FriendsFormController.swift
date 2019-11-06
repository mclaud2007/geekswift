//
//  FriendsFormController.swift
//  weather
//
//  Created by Григорий Мартюшин on 24.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class FriendsFormController: UITableViewController {
    @IBOutlet weak var friendCharsControl: FriendsSearchControl!
    
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
    
    // Список букв пользователей для контрола
    var FriendAlphabetList: [String] = []
       
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // На этом экране нам нужна навигация
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.title = "Друзья"
       
        // Собираем все первые буквы фамилий
        for Friend in FriendsList {
            if (Friend.name != "") {
                let fullNameArr = Friend.name.split(separator: " ", maxSplits: 2)
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
            }
        }
        
        if (FriendAlphabetList.count > 0){
            friendCharsControl.setChars(sChars: FriendAlphabetList)
            friendCharsControl.addTarget(self, action: #selector(catchCharChanged(_:)), for: .valueChanged)
        }
    }
    
    @objc public func catchCharChanged(_ sender: FriendsSearchControl){
        if (friendCharsControl.selectedChar != nil){
            print("Выбрана буква " + (friendCharsControl.selectedChar ?? "nil"))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.topItem?.title = "Друзья"
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FriendsList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsCell", for: indexPath) as? FriendsCell else {
            preconditionFailure("Error")
        }
        
        // Configure the cell...
        cell.lblFriendsName.text = FriendsList[indexPath.row].name
        
        if FriendsList[indexPath.row].photo != nil {
            cell.FriendPhotoImageView.showImage(image: FriendsList[indexPath.row].photo!)
        } else {
            cell.FriendPhotoImageView.showImage(image: UIImage(named: "photonotfound")!)
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotos",
            let destinationVC = segue.destination as? FriendsPhotoController,
            let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.title = FriendsList[indexPath.row].name
            
            if FriendsList[indexPath.row].photos != nil {
                // Дальше надо заменить на передачу ID пользователя, а экран фото должен сам запрсоить данные
                destinationVC.PhotosLists = FriendsList[indexPath.row].photos!
                destinationVC.Likes = FriendsList[indexPath.row].likes!
                destinationVC.Liked = FriendsList[indexPath.row].liked!
            }
        }
    }
    
}
