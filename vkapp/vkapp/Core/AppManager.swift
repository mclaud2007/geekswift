//
//  AppManager.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 30.04.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation
import UIKit

final class AppManager {
    private(set) var window: UIWindow?
    
    // Главный экран на него мы возвращаемся при логауте
    private(set) var rootVC: LoginViewController?
    
    // Контейнер в котором будет приложение + меню
    private(set) var containerVC: ContainerController?
    private(set) var menuVC: MenuViewController?
    private(set) var isMenuOpened = false
    
    static var shared = AppManager()
        
    public func setWindow(window: UIWindow?) {
        self.window = window
    }
    
    public func showApplicationContainer() {
        let container = ContainerController()
        self.containerVC = container

        container.modalTransitionStyle = .coverVertical
        container.modalPresentationStyle = .overFullScreen
        
        self.rootVC?.present(container, animated: true, completion: nil)
    }
    
    public func start() {
        // создаем экземпляр экрана логина
        self.rootVC = LoginViewController()
        
        self.window?.rootViewController = self.rootVC
        self.window?.makeKeyAndVisible()
        
        setupGlobalStyles()
    }
    
    func toggleMenu() {
        self.containerVC?.toggleMenu()
        
    }
    
    func logout() {
        self.rootVC?.dismiss(animated: true, completion: {
            // Стираем сессию
            self.rootVC?.wkLogout()
            
            // Убиваем сессию
            AppSession.shared.kill()
            
            // И запускаем проверку логина по новой (должен загрузится экран ввода пароля)
            self.rootVC?.checkLoggedInStatus()
        })
    }
}
