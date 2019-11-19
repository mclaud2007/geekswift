//
//  BigPhotosController.swift
//  weather
//
//  Created by Григорий Мартюшин on 17.11.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class BigPhotosController: UIViewController {
    
    @IBOutlet weak var BigPhotoImageView: UIImageView!
    @IBOutlet weak var BigPhotoImageViewTmp: UIImageView!
    
    // Массив фотографий выбранного пользователя (должен прийти из предыдущего окна или выведем фото notfound)
    var PhotosLists = [UIImage(named: "photonotfound")]
    var CurrentImageNumber: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Все фотографии"
        
        // Показываем текущее фото
        if let CurrentImage = PhotosLists[self.CurrentImageNumber] {
            self.BigPhotoImageView.image = CurrentImage
        } else {
            self.BigPhotoImageView.image = PhotosLists[0]
        }
    
        let swipeRecognizerLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeCatch(_:)))
        swipeRecognizerLeft.direction = .left
        self.view.addGestureRecognizer(swipeRecognizerLeft)
        
        let swipeRecognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeCatch(_:)))
        swipeRecognizerRight.direction = .right
        self.view.addGestureRecognizer(swipeRecognizerRight)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Изображение которое будет использоваться для появления из-за края экрана прячем
        self.BigPhotoImageViewTmp.center.x -= self.view.bounds.width
        self.BigPhotoImageViewTmp.isHidden = true
    }
    
    @objc func swipeCatch(_ sender : UISwipeGestureRecognizer){
        let PhotosCount = PhotosLists.count - 1

        if sender.direction == .right {
            if self.CurrentImageNumber > 0 {
                self.CurrentImageNumber -= 1
            } else {
                self.CurrentImageNumber = PhotosCount
            }
        } else if sender.direction == .left {
            if (self.CurrentImageNumber + 1) != PhotosCount && (self.CurrentImageNumber + 1) <= PhotosCount {
                self.CurrentImageNumber += 1
            } else {
                self.CurrentImageNumber = 0
            }
        }
        
        self.startAnimation(direction: sender.direction)
    }
    
    private func startAnimation(direction: UISwipeGestureRecognizer.Direction = .left) {
        // Новую фотографию загружаем во второй ImageView, который будет выезжать
        if let CurrentImage = self.PhotosLists[self.CurrentImageNumber] {
            self.BigPhotoImageViewTmp.image = CurrentImage
        } else {
            self.BigPhotoImageViewTmp.image = UIImage(named: "photonotfound")!
        }

        // Показываем слой и вытаскиваем его на передний план
        if direction == .left {
            self.BigPhotoImageViewTmp.center.x -= self.view.bounds.width
        } else {
            self.BigPhotoImageViewTmp.center.x += self.view.bounds.width
        }
        
        self.BigPhotoImageViewTmp.layer.zPosition = 100
        self.BigPhotoImageViewTmp.isHidden = false
        
        // Запускаем анимации
        UIView.animateKeyframes(withDuration: 2, delay: 0, options: [],
                                animations: {
                                    // Уменьшаем оригинал
                                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25) {
                                        self.BigPhotoImageView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                                        self.BigPhotoImageView.layer.opacity = 0.3
                                        self.BigPhotoImageView.layer.zPosition = 10
                                    }
                                    // Отправляем его за пределы экрана
                                    UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.45) {
                                        if direction == .left {
                                            self.BigPhotoImageView.center.x -= self.view.bounds.width
                                        } else {
                                            self.BigPhotoImageView.center.x += self.view.bounds.width
                                        }
                                    }
                                    // И выдвигаем чуть позже из-за края экрана новую картинку
                                    UIView.addKeyframe(withRelativeStartTime: 0.35, relativeDuration: 0.5) {
                                        if direction == .left {
                                            self.BigPhotoImageViewTmp.center.x += self.view.bounds.width
                                        } else {
                                            self.BigPhotoImageViewTmp.center.x -= self.view.bounds.width
                                        }
                                    }
                                }, completion: { _ in
                                    self.BigPhotoImageView.image = self.BigPhotoImageViewTmp.image
                                    self.BigPhotoImageView.transform = .identity
                                    self.BigPhotoImageView.layer.opacity = 1
                                    self.BigPhotoImageView.layer.zPosition = 100
                                    
                                    self.BigPhotoImageViewTmp.center.x = 0
                                    self.BigPhotoImageViewTmp.transform = .identity
                                    self.BigPhotoImageViewTmp.layer.opacity = 1
                                    self.BigPhotoImageViewTmp.layer.zPosition = 10
                                    self.BigPhotoImageViewTmp.isHidden = true
                                })
    }
}
