//
//  FriendDetailController.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 04.06.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit

class FriendDetailController: UIViewController {
    // MARK: Properties
    var friendDetailView: FriendDetailView {
        return view as! FriendDetailView
    }
    
    var collectionView: UICollectionView!
    var selectFriend: Friend?
    
    var friendPhotosList: [Photo] = []
    
    // MARK: Lifecycle
    override func loadView() {
        super.loadView()
        
        view = FriendDetailView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let friend = selectFriend {
            view.backgroundColor = Style.friendDetailScreen.background
            
            // Ставим название страницы как имя выбранного пользователя
            self.title = friend.name
            
            // Инициализируем коллекцию
            collectionView = friendDetailView.friendCollections
            collectionView.backgroundColor = .clear
            collectionView.delegate = self
            collectionView.dataSource = self
            
            // Регистрируем ячейку коллекции
            collectionView.register(FriendDetailCell.self, forCellWithReuseIdentifier: "collectionViewCell")
            
            // Загружаем данные
            VKService.shared.getPhotosBy(friendId: friend.userId) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case let .success(photos):
                    self.friendPhotosList = photos
                    
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                    
                    break
                case .failure(let err):
                    DispatchQueue.main.async {
                        self.showErrorMessage(message: err.localizedDescription)
                    }
                    break
                }
            }
        } else {
            navigationController?.popViewController(animated: true)
            self.showErrorMessage(message: NSLocalizedString("Can't find information about friend", comment: ""))
        }
    }
}

// MARK: UICollectionViewDelegate
extension FriendDetailController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let friendPhotoController = FriendPhotoController()
        
        friendPhotoController.title = selectFriend!.name
        friendPhotoController.friendPhotoList = friendPhotosList
        friendPhotoController.selectedPhotoIdx = indexPath.row
        
        navigationController?.pushViewController(friendPhotoController, animated: true)
    }
}

// MARK: UICollectionViewDataSource
extension FriendDetailController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        friendPhotosList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as? FriendDetailCell else { preconditionFailure("Error")
        }
        
        cell.configure(from: friendPhotosList[indexPath.row])
        
        // Делегат для лайк контрола
        if cell.likeControll.delegate == nil {
            cell.likeControll.delegate = self
        }
        
        return cell
    }
}

extension FriendDetailController: LikeControllDelegate {
    func click(sender: LikeControll) {
        // Здесь можно отправить например запрос в ВКАпи для того чтобы записать лукас
    }
}

extension FriendDetailController: TabBarScrollToTop {
    func doScroll() {
        collectionView.setContentOffset(.zero, animated: true)
    }
}
