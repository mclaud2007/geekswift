//
//  FriendsPhotoController.swift
//  weather
//
//  Created by Григорий Мартюшин on 25.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit
import RealmSwift

class FriendsPhotoController: UIViewController {
    // Id пользователя для, которого будем грузить фотки
    public var friendID: Int?
    
    // CollectionView с фотографиями
    @IBOutlet var PhotoListCollectionView: UICollectionView! {
        didSet {
            PhotoListCollectionView.delegate = self
            PhotoListCollectionView.dataSource = self
        }
    }
    
    // Массив фотографий выбранного пользователя (должен прийти из предыдущего окна или выведем фото notfound)
    var PhotosLists = [Photo]() {
        didSet {
            self.PhotoListCollectionView.reloadData()
        }
    }
    
    // Массив лайков под фотографиями или -1 - это значит оценок нет
    var Likes = [-1]
    // Массив уже отмеченных фотографий или -1 по умолчанию
    var Liked = [-1]
    
    var token: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Пытаемся загрузить фотографии пользователя
        if let friendID = self.friendID {
            do {
                // Подписываемся на изменения фотографий
                let photos = try RealmService.get(Photo.self).filter("friendID=\(friendID)").sorted(byKeyPath: "date", ascending: false)
                
                self.token = photos.observe({ [weak self] (changes: RealmCollectionChange) in
                    guard let self = self else { return }
                    
                    var localPhotoList = self.PhotosLists
                    
                    switch changes {
                    case let .initial(result):
                        localPhotoList.removeAll()
                        
                        for item in result {
                            localPhotoList.append(item)
                        }
                        
                    case let .update(res, del, ins, mod):
                        // Из базы пропала запись
                        if (del.count > 0) {
                            // Удаление из базы
                            for i in 0..<del.count {
                                if localPhotoList.indices.contains(del[i]) {
                                    localPhotoList.remove(at: del[i])
                                }
                            }
                            
                        } else if ins.count > 0 {
                            // Добавление записи
                            for i in 0..<ins.count {
                                if res.indices.contains(ins[i]) {
                                    localPhotoList.append(res[ins[i]])
                                }
                            }
                            
                        } else if mod.count > 0 {
                            // Запись обновилась
                            for i in 0..<mod.count {
                                if (localPhotoList.indices.contains(mod[i]) && res.indices.contains(mod[i])) {
                                    // Проще удалить старую запись
                                    localPhotoList.remove(at: mod[i])

                                    // И добавить новую
                                    localPhotoList.append(res[mod[i]])
                                }
                            }
                        }
                    case let .error(err):
                        self.showErrorMessage(message: err.localizedDescription)
                    }
                    
                    // Обновляем данные
                    self.PhotosLists.removeAll()
                    self.PhotosLists = localPhotoList
                    
                })
            } catch let err {
                showErrorMessage(message: err.localizedDescription)
            }
            
            // Запрашиваем данные
            VK.shared.getPhotosByFriendId(friendId: friendID)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowBigPhotos" {
            if let destinationVC = segue.destination as? BigPhotosController,
                let indexPath = PhotoListCollectionView.indexPathsForSelectedItems {
                destinationVC.friendID = self.friendID!
               
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
        return self.PhotosLists.count
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
