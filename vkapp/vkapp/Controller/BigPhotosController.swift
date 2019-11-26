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
    var animationHasFinished: Bool = true
    
    // Направление свайпа
    enum panDirectionEnum {
        case left
        case right
        case none
    }
    
    // Присвоем значение по-умолчанию - потом поменяем
    var panDirect: panDirectionEnum = .left
    
    var panInteractiveAnimator: UIViewPropertyAnimator!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Все фотографии"
        
        // Показываем текущее фото
        if let CurrentImage = PhotosLists[self.CurrentImageNumber] {
            self.BigPhotoImageView.image = CurrentImage
        } else {
            self.BigPhotoImageView.image = PhotosLists[0]
        }
    
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panCatch(_:)))
        self.view.addGestureRecognizer(panRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Изображение которое будет использоваться для появления из-за края экрана прячем
        self.BigPhotoImageViewTmp.center.x -= self.view.bounds.width
        self.BigPhotoImageViewTmp.isHidden = true
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
                self.panDirect = .none
            }
            
            if self.panDirect != .none {
                self.startAnimation()
            }
            
        case .changed:
            guard let propertyAnimator = self.panInteractiveAnimator else { return }
            
            switch self.panDirect {
            case .right:
                let percent = min(max(0, sender.translation(in: view).x / 200), 1)
                propertyAnimator.fractionComplete = percent
            case .left:
                let percent = min(max(0, -sender.translation(in: view).x / 200), 1)
                propertyAnimator.fractionComplete = percent
            case .none:
                let transition = sender.translation(in: self.view)
                
                // Определяем направление движения
                if transition.x < 0 {
                    self.panDirect = .left
                    self.startAnimation()
                } else if transition.x > 0 {
                    self.panDirect = .right
                    self.startAnimation()
                } else {
                    self.panDirect = .none
                }
            }
            
        case .ended:
            guard let propertyAnimator = self.panInteractiveAnimator else { return }
            
            if propertyAnimator.fractionComplete > 0.33 {
                propertyAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0.5)
            } else {
                propertyAnimator.isReversed = true
                propertyAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0.5)
            }
            
        default:
            break
        }
    }
    
    private func startAnimation(){
        if self.animationHasFinished == true {
            // Стартуя анимацию пока она не завершится, новую запускать нельзя
            self.animationHasFinished = false
            
            // Получим текущую фотографию в зависимости от того в какую сторону свайпим
            let CurrentImageNum = self.getCurrentPhotoNum()
            
            // Новую фотографию загружаем во второй ImageView, который будет выезжать
            if let CurrentImage = self.PhotosLists[CurrentImageNum] {
                self.BigPhotoImageViewTmp.image = CurrentImage
            } else {
                self.BigPhotoImageViewTmp.image = UIImage(named: "photonotfound")!
            }
            
            // Скрываем фотографию за краем экрана
            if self.panDirect == .left {
                self.BigPhotoImageViewTmp.transform = CGAffineTransform(translationX: -self.view.bounds.width, y: 0).concatenating(CGAffineTransform(scaleX: 0.5, y: 0.5))
            } else {
                self.BigPhotoImageViewTmp.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0).concatenating(CGAffineTransform(scaleX: 0.5, y: 0.5))
            }
            
            self.BigPhotoImageViewTmp.layer.zPosition = 100
            self.BigPhotoImageViewTmp.isHidden = false
            
            // Создаем универсальную анимацию
            panInteractiveAnimator = UIViewPropertyAnimator(duration: 2, curve: .easeInOut, animations: {
                if self.panDirect == .left {
                    self.BigPhotoImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5).concatenating(CGAffineTransform(translationX: -2 * self.view.bounds.width, y: 0))
                    self.BigPhotoImageViewTmp.transform = .identity
                    
                } else {
                    self.BigPhotoImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5).concatenating(CGAffineTransform(translationX: 2 * self.view.bounds.width, y: 0))
                    self.BigPhotoImageViewTmp.transform = .identity
                }
            })
            
            // Код который запуститься по окончании анимации
            panInteractiveAnimator.addCompletion { position in
                // Если анимация достигла конца надо заменить картинку
                if position == .end {
                    self.BigPhotoImageView.image = self.BigPhotoImageViewTmp.image
                    self.BigPhotoImageView.transform = .identity
                    self.BigPhotoImageView.layer.zPosition = 100
                    self.CurrentImageNumber = self.getCurrentPhotoNum()
                }
                
                // В конце или в начале надо вернуть временное изображение в начало
                if position == .start || position == .end {
                    // Вернем все настройки временного фото в начало
                    self.BigPhotoImageViewTmp.image = nil
                    self.BigPhotoImageViewTmp.layer.zPosition = 10
                    self.BigPhotoImageViewTmp.center.x -= self.view.bounds.width
                }
                
                // И поставить признак того что анимация закончилась
                self.animationHasFinished = true
            }
            
            panInteractiveAnimator.startAnimation()
        }
    }
    
    private func getCurrentPhotoNum() -> Int {
        let PhotosCount = PhotosLists.count - 1
        var retNumber = self.CurrentImageNumber

        if self.panDirect == .right {
            if self.CurrentImageNumber > 0 {
                retNumber = self.CurrentImageNumber - 1
            } else {
                retNumber = PhotosCount
            }
        } else if self.panDirect == .left {
            if (self.CurrentImageNumber + 1) <= PhotosCount {
                retNumber = self.CurrentImageNumber + 1
            } else {
                retNumber = 0
            }
        }
        
        return retNumber
    }
}
