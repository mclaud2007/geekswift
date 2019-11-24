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
        if PhotosLists.indices.contains(indexPath.row),
            let photos = PhotosLists[indexPath.row] {
            
            // Фотография по идее есть
            cell.FriendPhotoImageView.showImage(image: photos, indexPath: indexPath)
            
            // Ищем информацию о лайках
            if Likes.count > indexPath.item && Likes.indices.contains(indexPath.item) {
                if Likes[indexPath.item] > 0 {
                    var isAlreadyLiked = false
                    
                    if (Liked.contains(where: { $0 == indexPath.item }) == true){
                        isAlreadyLiked = true
                    }
                    
                    // Лайки нашли - инициализируем контрол
                    cell.FriendLike.initLikes(likes: Likes[indexPath.item], isLiked: isAlreadyLiked)
                }
            }
            
        } else {
            cell.FriendPhotoImageView.showImage(image: getNotFoundPhoto(), indexPath: indexPath)
            cell.FriendLike.initLikes(likes: -1, isLiked: false)
        }
        
        // Вешаем обработчик клика по аватарке
        cell.FriendPhotoImageView.addTarget(self, action: #selector(catchAvatarClicked(_:)), for: .touchUpInside)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowBigPhotos", sender: self)
    }
    
    @objc func catchAvatarClicked (_ sender: AvatarView){
        if let indexPath = sender.CurrentIndexPath {
            // Выберем ячейку, чтобы при подготовке сеги передались корректные данные
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
           
            // Выполняем сегу
            performSegue(withIdentifier: "ShowBigPhotos", sender: self)
            
            // Убираем выделение ячейки
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowBigPhotos" {
            if let destinationVC = segue.destination as? BigPhotosController,
                let indexPath = collectionView.indexPathsForSelectedItems {
                destinationVC.PhotosLists = self.PhotosLists
                
                if let _ = self.PhotosLists[indexPath[0][1]] {
                    destinationVC.CurrentImageNumber = indexPath[0][1]
                }
            }
        }
    }
}
