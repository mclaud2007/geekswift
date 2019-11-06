//
//  FriendsPhotoController.swift
//  weather
//
//  Created by Григорий Мартюшин on 25.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class FriendsPhotoController: UICollectionViewController {
    
    // Массив фотографий выбранного пользователя (должен прийти из предыдущего окна или выведем фото notfound)
    var PhotosLists = [UIImage(named: "photonotfound")]
    // Массив лайков под фотографиями или -1 - это значит оценок нет
    var Likes = [-1]
    // Массив уже отмеченных фотографий или -1 по умолчанию
    var Liked = [-1]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PhotosLists.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotosCell", for: indexPath) as? PhotosCell else {
            preconditionFailure("Error")
        }
    
        // Configure the cell
        if (PhotosLists[indexPath.row] != nil){
            cell.FriendPhotoImageView.showImage(image: PhotosLists[indexPath.row]!)
            
            if (Likes.count > indexPath.item && Likes[indexPath.item] > 0){
                var isAlreadyLiked = false
                
                if (Liked.contains(where: { $0 == indexPath.item }) == true){
                    isAlreadyLiked = true
                }
                
                cell.FriendLike.initLikes(likes: Likes[indexPath.item], isLiked: isAlreadyLiked)
            }
            
        } else {
            cell.FriendPhotoImageView.showImage(image: UIImage(named: "photonotfound")!)
            cell.FriendLike.initLikes(likes: -1, isLiked: false)
        }
        
        return cell
    }
}
