//
//  TabBarController.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 08.06.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit

protocol TabBarScrollToTop {
    func doScroll() -> Void
}

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    static var previosController: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Предыдущий контроллер равен текущему - значит нажали второй раз и надо отмотать его вверх
        if (TabBarController.previosController == viewController) {
            if let nav = viewController as? UINavigationController,
                let view = nav.viewControllers.last as? TabBarScrollToTop
            {
                view.doScroll()
            }
        }
        
        // Запоминаем предыдущий контролер
        TabBarController.previosController = viewController
    }
}
