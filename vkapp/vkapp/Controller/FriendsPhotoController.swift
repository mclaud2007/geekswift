//
//  FriendsPhotoController.swift
//  weather
//
//  Created by Григорий Мартюшин on 25.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class FriendsPhotoController: UIViewController {
    // Id пользователя для, которого будем грузить фотки
    public var FriendID: Int?
    
    // CollectionView с фотографиями
    @IBOutlet var PhotoListCollectionView: UICollectionView! {
        didSet {
            PhotoListCollectionView.delegate = self
            PhotoListCollectionView.dataSource = self
        }
    }
    
    // Массив фотографий выбранного пользователя (должен прийти из предыдущего окна или выведем фото notfound)
    var PhotosLists: Array<Photo> = [Photo(photoId: 0, photo: UIImage(named: "photonotfound")!, likes: nil, date: nil)]
    
    // Массив лайков под фотографиями или -1 - это значит оценок нет
    var Likes = [-1]
    // Массив уже отмеченных фотографий или -1 по умолчанию
    var Liked = [-1]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Пытаемся загрузить фотографии пользователя
        if let friendID = self.FriendID {
            VK.shared.getPhotosByFriendId(friendId: friendID) { result in
                self.PhotosLists = result
                self.PhotoListCollectionView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowBigPhotos" {
            if let destinationVC = segue.destination as? BigPhotosController,
                let indexPath = PhotoListCollectionView.indexPathsForSelectedItems {
                destinationVC.PhotosLists = self.PhotosLists

                if self.PhotosLists.indices.contains(indexPath[0][1]) {
                    destinationVC.CurrentImageNumber = indexPath[0][1]
                }
            }
        }
    }
}

extension FriendsPhotoController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PhotosLists.count
    }
    
    // MARK: Поготовка ячейки к выводу
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotosCell", for: indexPath) as? PhotosCell else {
            preconditionFailure("Error")
        }

        // Configure the cell
        if PhotosLists.indices.contains(indexPath.row) {
            cell.configure(with: PhotosLists[indexPath.row], indexPath: indexPath)

            // Объявляем делегата для лайков и фотографии
            cell.FriendLike.delegate = self
            cell.FriendPhotoImageView.delegate = self
            
        } else {
            cell.FriendPhotoImageView.showImage(image: getNotFoundPhoto(), indexPath: indexPath)
            cell.FriendLike.initLikes(likes: -1, isLiked: false)
        }
        
        return cell
    }
}

extension FriendsPhotoController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowBigPhotos", sender: self)
    }
}

// MARK: расширение для подсчета лайков
extension FriendsPhotoController: LikeControlProto {
    func likeClicked (sender: LikeControl) {
        if (sender.isLiked == true){
            sender.likes -= 1
            sender.isLiked = false

        } else {
            sender.likes += 1
            sender.isLiked = true
            
            if (sender.likes == 0) {
                sender.likes = 1
            }
        }
        
        // Обновляем лайки
        sender.initLikes(likes: sender.likes, isLiked: sender.isLiked)
    }
}

// реакция на клик по аватару
extension FriendsPhotoController: AvatarViewProto {
    func click(sender: AvatarView) {
        if let indexPath = sender.CurrentIndexPath {
            // Выберем ячейку, чтобы при подготовке сеги передались корректные данные
            PhotoListCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)

            // Выполняем сегу
            performSegue(withIdentifier: "ShowBigPhotos", sender: self)

            // Убираем выделение ячейки
            PhotoListCollectionView.deselectItem(at: indexPath, animated: true)
        }
    }
}
