//
//  FriendsFormController.swift
//  weather
//
//  Created by Григорий Мартюшин on 24.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class FriendsFormController: UITableViewController {
    
    let FriendsList = [
        Friend(photo: UIImage(named: "bruce")!,
               name: "Брюс Уиллис",
               photos: [
                        UIImage(named: "bruce1")!,
                        UIImage(named: "bruce2")!,
                        UIImage(named: "bruce3")!,
                        UIImage(named: "bruce4")!,
                        UIImage(named: "bruce")!
                       ]
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
                       ]),
        Friend(name: "Сильвестер Сталоне"),
        Friend(name: "Джейсон Стеттем"),
        Friend(name: "Сэмюэл Л. Джексон"),
        Friend(name: "Киану Ривз"),
        Friend(name: "Жан-Клод Ван Дамм"),
        Friend(name: "Чак Норрис"),
        Friend(name: "Джеки Чан"),
        Friend(name: "Рутгер Хауэр")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // На этом экране нам нужна навигация
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.title = "Друзья"
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
            cell.imgFriendsPhoto.image = FriendsList[indexPath.row].photo
        } else {
            cell.imgFriendsPhoto.image = UIImage(named: "photonotfound")
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotos",
            let destinationVC = segue.destination as? FriendsPhotoController,
            let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.title = FriendsList[indexPath.row].name
            
            if FriendsList[indexPath.row].photos != nil {
                destinationVC.PhotosLists = FriendsList[indexPath.row].photos!
            }
        }
    }
    
}
