//
//  LoginView.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 30.04.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit
import WebKit

class LoginView: UIView {
    // MARK: Properties
    // Название приложения
    private lazy var appLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "VK App"
        
        label.textColor = Style.loginScreen.appLabelColor
        label.shadowColor = Style.loginScreen.appLabelShadowColor
        label.tintColor = .blue
        
        label.font = .systemFont(ofSize: 30)
        return label
    }()
    
    // Фоновое изображение
    private lazy var backgroundImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "background")!
        image.contentMode = .scaleAspectFill
        image.alpha = 0.4
        return image
    }()
    
    // WebKitView
    public lazy var wkWebView: WKWebView = {
        let wkWebView = WKWebView()
        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        wkWebView.tintColor = Style.loginScreen.appLabelShadowColor
        wkWebView.backgroundColor = .white
        wkWebView.isHidden = false
        return wkWebView
    }()
    
    // Кнопка "Попробовать еще раз"
    public lazy var buttonRetry: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = Style.loginScreen.appLabelColor
        button.setTitle(NSLocalizedString("Retry", comment: ""), for: .normal)
        button.setTitleColor(Style.loginScreen.appLabelColor, for: .normal)
        button.isHidden = true
        return button
    }()
    
    // Надпись о том что не получилось законнектится
    public lazy var notConnectLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Style.loginScreen.appLabelColor
        label.font = .systemFont(ofSize: 14)
        label.isHidden = true
        label.numberOfLines = 3
        label.textAlignment = .center
        label.text = NSLocalizedString("Can't take auth token. To try again press \"Retry\" button.", comment: "")
        return label
    }()
    
    // Анимашка загрузки
    public lazy var labelAnimations: LoadingViewControl = {
        let loadingControl = LoadingViewControl(frame: CGRect(x: 0, y: 0, width: 60, height: 20))
        loadingControl.isHidden = true
        loadingControl.translatesAutoresizingMaskIntoConstraints = false
        return loadingControl
    }()
    
    // MARK: Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }

    private func configureView() {
        self.addSubview(self.appLabel)
        self.addSubview(self.backgroundImage)
        self.addSubview(self.wkWebView)
        self.addSubview(self.buttonRetry)
        self.addSubview(self.notConnectLabel)
        self.addSubview(self.labelAnimations)
        
        NSLayoutConstraint.activate([
            self.appLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 20),
            // Центрируем по горизонтали
            NSLayoutConstraint(item: self.appLabel, attribute: .centerX, relatedBy: .equal,
                               toItem: self.safeAreaLayoutGuide, attribute: .centerX,
                               multiplier: 1, constant: 0
            ),
            
            // Анимашка загрузки
            NSLayoutConstraint(item: self.labelAnimations, attribute: .centerX, relatedBy: .equal,
                               toItem: self.safeAreaLayoutGuide, attribute: .centerX,
                               multiplier: 1, constant: 0
            ),
            
            NSLayoutConstraint(item: self.labelAnimations, attribute: .centerY, relatedBy: .equal,
                               toItem: self.safeAreaLayoutGuide, attribute: .centerY,
                               multiplier: 1, constant: 0
            ),
            
            self.labelAnimations.widthAnchor.constraint(equalToConstant: 60),
            self.labelAnimations.heightAnchor.constraint(equalToConstant: 20),
            
            // Вебкит для прохождения авторизации
            self.wkWebView.topAnchor.constraint(equalTo: self.appLabel.bottomAnchor, constant: 20),
            self.wkWebView.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 20),
            self.wkWebView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            self.wkWebView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            // Фоновая картинка
            self.backgroundImage.topAnchor.constraint(equalTo: self.topAnchor),
            self.backgroundImage.leftAnchor.constraint(equalTo: self.leftAnchor),
            self.backgroundImage.rightAnchor.constraint(equalTo: self.rightAnchor),
            self.backgroundImage.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            // Кнопка повторить будет по центру снизу
            NSLayoutConstraint(item: self.buttonRetry, attribute: .centerX, relatedBy: .equal,
                               toItem: self.safeAreaLayoutGuide, attribute: .centerX,
                               multiplier: 1, constant: 0
            ),
            self.buttonRetry.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            // Надпись ничего не получилось
            NSLayoutConstraint(item: self.notConnectLabel, attribute: .centerX, relatedBy: .equal,
                               toItem: self.safeAreaLayoutGuide, attribute: .centerX,
                               multiplier: 1, constant: 0
            ),
            NSLayoutConstraint(item: self.notConnectLabel, attribute: .centerY, relatedBy: .equal,
                               toItem: self.safeAreaLayoutGuide, attribute: .centerY,
                               multiplier: 1, constant: 0
            ),
            
            self.notConnectLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 50),
            self.notConnectLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -50)
        ])
        
    }
}
