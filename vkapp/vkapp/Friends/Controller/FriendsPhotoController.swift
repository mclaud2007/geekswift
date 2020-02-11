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
    
    // Здесь будем хранить наш кастомный лайоут [Index.Row => CustomSectionRowCount]
    fileprivate var customLayout = [Int:CGFloat]()
    
    // Список пользоваетльских фотографий
    var realmPhotosList: Results<Photo>?
    
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
            loadPhoto()
            
            // Локализуем кнопку назад
            navigationItem.backBarButtonItem?.title = NSLocalizedString("Back", comment: "")
            navigationItem.backBarButtonItem?.tintColor = DefaultStyle.self.Colors.tint
            
            photoListCollectionView.refreshControl = UIRefreshControl()
            photoListCollectionView.refreshControl?.attributedTitle = NSAttributedString(string: "Loaded...")
            photoListCollectionView.refreshControl?.addTarget(self, action: #selector(loadPhoto), for: .valueChanged)
            
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func loadPhoto(){
        // Запрашиваем данные
        if let friend = selectedFriend {
            VKService.shared.getPhotosBy(friendId: friend.userId) { result in
                switch result {
                case let .success(photosList):
                    do {
                        for photo in photosList {
                            try RealmService.save(items: photo)
                        }
                    } catch let err {
                        self.showErrorMessage(message: err.localizedDescription)
                    }
                case let .failure(err):
                    self.showErrorMessage(message: err.localizedDescription)
                }
                
                self.photoListCollectionView.refreshControl?.endRefreshing()
            }
        } else {
            self.photoListCollectionView.refreshControl?.endRefreshing()
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
               
                if let photosList = self.realmPhotosList,
                    photosList.indices.contains(indexPath[0][1])
                {
                    destinationVC.currentImageNumber = indexPath[0][1]
                }
            }
        }
    }
    
    fileprivate func subscribeToRealmChanges (by friendID: Int) {
        do {
            // Получаем список фотографий из реалма
            self.realmPhotosList = try RealmService.get(Photo.self).filter("friendID=\(friendID)").sorted(byKeyPath: "date", ascending: false)
            
            if let photos = self.realmPhotosList {
                // И подписываемся на изменения данных в нем
                self.token = photos.observe({ [weak self] (changes: RealmCollectionChange) in
                    guard let self = self else { return }
                    
                    switch changes {
                    case .initial(_),.update(_, _, _, _):
                        self.photoListCollectionView.reloadData()
                    case let .error(err):
                        self.showErrorMessage(message: err.localizedDescription)
                    }
                    
                    // Обновим лайоут
                    self.customLayout = [Int:CGFloat]()
                    var currentRowCriteria: CGFloat = 2, alreadyShown: Int = 0
                    
                    // Сформируем лайоут
                    for i in 0..<photos.count {
                        if (alreadyShown == 2 && currentRowCriteria == 2) {
                            currentRowCriteria = 3
                            alreadyShown = 0
                        } else if (alreadyShown == 3 && currentRowCriteria == 3) {
                            currentRowCriteria = 2
                            alreadyShown = 0
                        }
                        
                        // Считаем сколько показали
                        alreadyShown += 1
                        self.customLayout[i] = currentRowCriteria
                    }
                })
            } else {
                throw VKService.VKError.FriendListIsEmpty
            }
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
        if let photosList = self.realmPhotosList {
            return photosList.count
        } else {
            return 0
        }
    }
    
    // Поготовка ячейки к выводу
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PhotosCell else {
            preconditionFailure("Error")
        }

        // Объявляем делегата для лайков и фотографии
        cell.friendLike.delegate = self
        cell.friendPhotoImageView.delegate = self

        // Configure the cell
        if let photosList = self.realmPhotosList,
            photosList.indices.contains(indexPath.row)
        {
            cell.configure(with: photosList[indexPath.row], indexPath: indexPath)
        } else {
            cell.friendPhotoImageView.showImage(image: getNotFoundPhoto(), indexPath: indexPath)
            cell.friendLike.initLikes(likes: -1, isLiked: false)
        }
        
        return cell
    }
}

extension FriendsPhotoController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Смотрим сколько выводить фотографий в данной ячейке
        currentRowCriteria = self.customLayout[indexPath.row] ?? 2
    
        let paddingSpace = sectionInsets.left * (1 + 1)
        let widthPerItem = (photoListCollectionView.frame.width / currentRowCriteria) - paddingSpace
        
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
