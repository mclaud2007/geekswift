//
//  FriendBigPhoto.swift
//  VKApp
//
//  Created by Григорий Мартюшин on 17.11.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit
import Kingfisher
import RealmSwift

class BigPhotosController: UIViewController {
    
    @IBOutlet weak var bigPhotoImageView: UIImageView!
    @IBOutlet weak var bigPhotoImageViewTmp: UIImageView!
    
    // Массив фотографий выбранного пользователя (должен прийти из предыдущего окна или выведем фото notfound)
    var photosList = [Photo]()
    
    var currentImageNumber: Int = 0
    var animationHasFinished: Bool = true
    var friendID: Int = 0
    
    // Направление свайпа
    enum Direction {
        case left
        case right
        case bottom
        case none
    }
    
    // Присвоем значение по-умолчанию - потом поменяем
    var panDirect: Direction = .left
    
    var panInteractiveAnimator: UIViewPropertyAnimator!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Все фотографии"
        
        // загружаем список фотографий из realm
        do {
            let realmPhotos = try RealmService.get(Photo.self).filter("friendID=\(self.friendID)")
                                              .sorted(byKeyPath: "date", ascending: false)
            
            // Фотографий нет
            guard realmPhotos.count > 0 else { return }
            
            //  Навсякий очистим список
            photosList.removeAll()
            
            // Заполняем список
            for i in 0..<realmPhotos.count {
                photosList.append(realmPhotos[i])
            }
            
            // Если текущего фото не существует - вместо него начнем с первого
            if !photosList.indices.contains(currentImageNumber) {
                currentImageNumber = 0
            }
            
            // Если фотографии по индексу нет - смысла продолжать тоже нет
            guard photosList.indices.contains(currentImageNumber) else { return }
            
            // Загружаем фотографию
            bigPhotoImageView.kf.setImage(with: photosList[currentImageNumber].photoUrl, placeholder: nil, options: nil, progressBlock: nil) { result in
                
                switch result {
                case .success(let data):
                    self.bigPhotoImageView.image = data.image
                case .failure:
                    self.bigPhotoImageView.image = self.getNotFoundPhoto()
                }
            }
            
            // Если вся инфа найдена, то заменим название экрана
            title = "\(currentImageNumber+1) из \(photosList.count)"
            
            let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panCatch(_:)))
            view.addGestureRecognizer(panRecognizer)
            
        } catch {
            print("BigPhotosController RealmCrashed")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Локализуем кнопку назад
        navigationController?.navigationItem.backBarButtonItem?.title = NSLocalizedString("Back", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Изображение которое будет использоваться для появления из-за края экрана прячем
        bigPhotoImageViewTmp.center.x -= self.view.bounds.width
        bigPhotoImageViewTmp.isHidden = true
    }
    
    @objc func panCatch( _ sender: UIPanGestureRecognizer){
        switch sender.state {
        case .began:
            let transition = sender.translation(in: self.view)
            
            // Определяем направление движения
            if transition.x < 0 {
                self.panDirect = .left
            } else if transition.x > 0 {
                self.panDirect = .right
            } else {
                if transition.y > 0 {
                    self.panDirect = .bottom
                } else {
                    self.panDirect = .none
                }
            }
            
            if panDirect != .none && panDirect != .bottom {
                startAnimation()
            } else if panDirect == .bottom {
                goBack()
            }
            
        case .changed:
            guard let propertyAnimator = panInteractiveAnimator else { return }
            
            switch panDirect {
            case .right:
                let percent = min(max(0, sender.translation(in: view).x / 500), 1)
                propertyAnimator.fractionComplete = percent
            case .left:
                let percent = min(max(0, -sender.translation(in: view).x / 500), 1)
                propertyAnimator.fractionComplete = percent
            case .bottom:
                let percent = min(max(0, sender.translation(in: view).y / 500), 1)
                propertyAnimator.fractionComplete = percent
            case .none:
                let transition = sender.translation(in: view)
                
                // Определяем направление движения
                if transition.x < 0 {
                    panDirect = .left
                    startAnimation()
                } else if transition.x > 0 {
                    panDirect = .right
                    startAnimation()
                } else {
                    if transition.y > 0 {
                        panDirect = .bottom
                        goBack()
                    } else {
                        panDirect = .none
                    }
                }
            }
            
        case .ended:
            guard let propertyAnimator = panInteractiveAnimator else { return }
            
            if propertyAnimator.fractionComplete > 0.20 {
                propertyAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0.5)
            } else {
                propertyAnimator.isReversed = true
                propertyAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0.5)
            }
            
        default:
            break
        }
    }
    
    private func goBack(){
        navigationController?.popViewController(animated: true)
    }
    
    private func startAnimation(){
        // Если направление движения лево/право
        if animationHasFinished == true {
            // Стартуя анимацию пока она не завершится, новую запускать нельзя
            animationHasFinished = false

            // Получим текущую фотографию в зависимости от того в какую сторону свайпим
            let currentImageNum = getCurrentPhotoNum()

            // Новую фотографию загружаем во второй ImageView, который будет выезжать
            if photosList.indices.contains(currentImageNum) {
                let CurrentImage = photosList[currentImageNum]
                
                if let photo = CurrentImage.photoUrlString {
                    bigPhotoImageViewTmp.kf.setImage(with: URL(string: photo))
                } else {
                    bigPhotoImageViewTmp.image = UIImage(named: "photonotfound")!
                }
            } else {
                bigPhotoImageViewTmp.image = UIImage(named: "photonotfound")!
            }

            // Скрываем фотографию за краем экрана
            if panDirect == .left {
                bigPhotoImageViewTmp.transform = CGAffineTransform(translationX: -view.bounds.width, y: 0).concatenating(CGAffineTransform(scaleX: 0.5, y: 0.5))
            } else {
                bigPhotoImageViewTmp.transform = CGAffineTransform(translationX: view.bounds.width, y: 0).concatenating(CGAffineTransform(scaleX: 0.5, y: 0.5))
            }

            bigPhotoImageViewTmp.layer.zPosition = 100
            bigPhotoImageViewTmp.isHidden = false

            // Создаем универсальную анимацию
            panInteractiveAnimator = UIViewPropertyAnimator(duration: 1, curve: .linear, animations: {
                if self.panDirect == .left {
                    self.bigPhotoImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5).concatenating(CGAffineTransform(translationX: -2 * self.view.bounds.width, y: 0))
                    self.bigPhotoImageViewTmp.transform = .identity

                } else {
                    self.bigPhotoImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5).concatenating(CGAffineTransform(translationX: 2 * self.view.bounds.width, y: 0))
                    self.bigPhotoImageViewTmp.transform = .identity
                }
            })

            // Код который запуститься по окончании анимации
            panInteractiveAnimator.addCompletion { position in
                // Если анимация достигла конца надо заменить картинку
                if position == .end {
                    self.bigPhotoImageView.image = self.bigPhotoImageViewTmp.image
                    self.bigPhotoImageView.transform = .identity
                    self.bigPhotoImageView.layer.zPosition = 100
                    self.currentImageNumber = self.getCurrentPhotoNum()
                }

                // В конце или в начале надо вернуть временное изображение в начало
                if position == .start || position == .end {
                    // Вернем все настройки временного фото в начало
                    self.bigPhotoImageViewTmp.image = nil
                    self.bigPhotoImageViewTmp.layer.zPosition = 10
                    self.bigPhotoImageViewTmp.center.x -= self.view.bounds.width
                }

                // И поставить признак того что анимация закончилась
                self.animationHasFinished = true
            }

            panInteractiveAnimator.startAnimation()
        }
    }
    
    private func getCurrentPhotoNum() -> Int {
        let PhotosCount = photosList.count - 1
        var retNumber = currentImageNumber

        if panDirect == .right {
            if currentImageNumber > 0 {
                retNumber = currentImageNumber - 1
            } else {
                retNumber = PhotosCount
            }
        } else if panDirect == .left {
            if (currentImageNumber + 1) <= PhotosCount {
                retNumber = currentImageNumber + 1
            } else {
                retNumber = 0
            }
        }
        
        // Если вся инфа найдена, то заменим название экрана
        title = "\(retNumber+1) из \(photosList.count)"
        
        return retNumber
    }
}
