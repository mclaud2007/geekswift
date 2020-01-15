//
//  FriendPhotoList.swift
//  VKApp
//
//  Created by Григорий Мартюшин on 25.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit
import RealmSwift

class FriendsPhotoController: UIViewController {
    // MARK: Outlet
    // CollectionView с фотографиями
    @IBOutlet var photoListCollectionView: UICollectionView! {
        didSet {
            photoListCollectionView.delegate = self
            photoListCollectionView.dataSource = self
        }
    }
    
    // Аватарка пользователя
    @IBOutlet var friendAvatarPhoto: AvatarView! {
        didSet {
            friendAvatarPhoto.delegate = self
        }
    }
    
    // Имя пользователя
    @IBOutlet var lblFriandName: UILabel!
    
    // Подложка для аватара и имени пользователя
    @IBOutlet var viewBackground: UIView!
    
    // Город проживания пользоателя
    @IBOutlet weak var lblCityName: UILabel!
    
    // MARK: Properties
    // Пользователь, которого выбрали в списке
    public var selectedFriend: Friend? = nil
    
    // Массив фотографий выбранного пользователя (должен прийти из предыдущего окна или выведем фото notfound)
    var photosLists = [Photo]() {
        didSet {
            self.photoListCollectionView.reloadData()
        }
    }
    
    var token: NotificationToken?
    
    // Имя сеги для перехода на большую фотографию
    let bigPhotoSegueName: String = "ShowBigPhotos"
    let reuseIdentifier: String = "PhotosCell"
    let sectionInsets = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
    
    var alreadyShown = 0
    var currentRowCriteria: CGFloat = 3
    
    // MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alreadyShown = 0
        currentRowCriteria = 3
        
        if let friend = selectedFriend {
            // Меняем название экрана
            self.title = friend.name
            
            // Пишем имя пользователя
            lblFriandName.text = friend.name
            
            // И город проживания
            lblCityName.text = friend.city
            
            // Перекрасим задник у подложки с аватаром текущего пользователя
            if isDarkMode {
                viewBackground.backgroundColor = UIColor.darkGray
            }
            
            // И ставим его фотографию
            if let photo = friend.photo {
                let curPhotoIndexPath = IndexPath(item: 0, section: 0)
                friendAvatarPhoto.showImage(imageURL: photo, indexPath: curPhotoIndexPath)
            } else {
                friendAvatarPhoto.showImage(image: getNotFoundPhoto())
            }
            
            // Подписываемся на изменения реалм
            subscribeToRealmChanges(by: friend.userId)
            
            // Запрашиваем данные
            VK.shared.getPhotosByFriendId(friendId: friend.userId)
            
            // Локализуем кнопку назад
            navigationItem.backBarButtonItem?.title = NSLocalizedString("Back", comment: "")
            navigationItem.backBarButtonItem?.tintColor = DefaultStyle.self.Colors.tint
            
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Локализуем кнопку назад
        navigationController?.navigationItem.backBarButtonItem?.title = NSLocalizedString("Back", comment: "")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == bigPhotoSegueName {
            if let destinationVC = segue.destination as? BigPhotosController,
                let indexPath = photoListCollectionView.indexPathsForSelectedItems,
                let selectFriend = selectedFriend {
                destinationVC.friendID = selectFriend.userId
               
                if self.photosLists.indices.contains(indexPath[0][1]) {
                    destinationVC.currentImageNumber = indexPath[0][1]
                }
            }
        }
    }
    
    fileprivate func subscribeToRealmChanges (by friendID: Int) {
        do {
            // Получаем список фотографий из реалма
            let photos = try RealmService.get(Photo.self).filter("friendID=\(friendID)").sorted(byKeyPath: "date", ascending: false)
            
            // И подписываемся на изменения данных в нем
            self.token = photos.observe({ [weak self] (changes: RealmCollectionChange) in
                guard let self = self else { return }
                
                var localPhotoList = self.photosLists
                
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
                                // Заменим запись
                                localPhotoList[mod[i]] = res[mod[i]]
                            }
                        }
                    }
                case let .error(err):
                    self.showErrorMessage(message: err.localizedDescription)
                }
                
                // Обновляем данные
                self.photosLists.removeAll()
                self.photosLists = localPhotoList
                
            })
        } catch let err {
            showErrorMessage(message: err.localizedDescription)
        }
    }
}

// MARK: DataSource
extension FriendsPhotoController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photosLists.count
    }
    
    // Поготовка ячейки к выводу
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PhotosCell else {
            preconditionFailure("Error")
        }

        // Объявляем делегата для лайков и фотографии
        cell.FriendLike.delegate = self
        cell.FriendPhotoImageView.delegate = self

        // Configure the cell
        if photosLists.indices.contains(indexPath.row) {
            cell.configure(with: photosLists[indexPath.row], indexPath: indexPath)
        } else {
            cell.FriendPhotoImageView.showImage(image: getNotFoundPhoto(), indexPath: indexPath)
            cell.FriendLike.initLikes(likes: -1, isLiked: false)
        }
        
        return cell
    }
}

extension FriendsPhotoController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if (alreadyShown == 2 && currentRowCriteria == 2) {
            currentRowCriteria = 3
            alreadyShown = 0
        } else if (alreadyShown == 3 && currentRowCriteria == 3) {
            currentRowCriteria = 2
            alreadyShown = 0
        }
        
        
        print(indexPath)
        print(alreadyShown)
        print(currentRowCriteria)
        
        // Считаем сколько показали
        alreadyShown += 1
    
        let paddingSpace = sectionInsets.left * (1 + 1)
        let widthPerItem = (view.bounds.width / currentRowCriteria) - paddingSpace
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    
        return sectionInsets.left
    }
}

// MARK: Collection View Delegate
extension FriendsPhotoController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: bigPhotoSegueName, sender: self)
    }
}

// MARK: Like control delegate
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

// MARK: Avatar View Delegate
extension FriendsPhotoController: AvatarViewProto {
    func click(sender: AvatarView) {
        if let indexPath = sender.currentIndexPath {
            // Выберем ячейку, чтобы при подготовке сеги передались корректные данные
            photoListCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)

            // Выполняем сегу
            performSegue(withIdentifier: bigPhotoSegueName, sender: self)

            // Убираем выделение ячейки
            photoListCollectionView.deselectItem(at: indexPath, animated: true)
        }
    }
}
