//
//  FriendPhotoController.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 05.06.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit

class FriendPhotoController: UIViewController {
    // MARK: Properties
    private var friendPhotoView: FriendPhotoView {
        return view as! FriendPhotoView
    }
    
    private let photoService = PhotoService.shared
    
    public var friendPhotoList: [Photo] = []
    public var selectedPhotoIdx: Int = 0 {
        didSet {
            // Не нашли такого фото - покажем с самого первого снимка
            if !friendPhotoList.indices.contains(selectedPhotoIdx) {
                selectedPhotoIdx = 0
            }
            
            if let photo = friendPhotoList[selectedPhotoIdx].photoUrlString {
                photoService.getPhotoBy(urlString: photo, catrgory: "photo") { [weak self] image in
                    guard let self = self else { return }
                    
                    DispatchQueue.main.async {
                        if let image = image {
                            self.friendPhotoView.imgBigPhoto.image = image
                        } else {
                            self.friendPhotoView.imgBigPhoto.image = UIImage(named: "photonotfound")
                        }
                    }
                }
            } else {
                friendPhotoView.imgBigPhoto.image = UIImage(named: "photonotfound")
            }
            
            // Если вся инфа найдена, то заменим название экрана
            title = "\(selectedPhotoIdx+1) из \(friendPhotoList.count)"
        }
    }
    
    // MARK: Lifecycle
    override func loadView() {
        view = FriendPhotoView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Style.friendBigScreen.background
        
        
        // Вещаем tapRecogniser на view
        let tapRecogniser = UITapGestureRecognizer(target: self, action: #selector(goToNextPhoto(sender:)))
        self.view.addGestureRecognizer(tapRecogniser)
    }
    
    @objc private func goToNextPhoto(sender: UITapGestureRecognizer) {
        let point = sender.location(in: self.view)
        let halfScreen = self.view.bounds.width / 2
        var nextPhoto: Int = 0
        
        if point.x > halfScreen {
            if (selectedPhotoIdx + 1) <= friendPhotoList.count {
                nextPhoto = (selectedPhotoIdx + 1)
            } else {
                nextPhoto = 0
            }
        } else {
            if (selectedPhotoIdx - 1) > 0 {
                nextPhoto = selectedPhotoIdx - 1
            } else {
                nextPhoto = (friendPhotoList.count - 1)
            }
        }
        
        selectedPhotoIdx = nextPhoto
    }
}
