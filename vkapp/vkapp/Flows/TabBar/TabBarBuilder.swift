//
//  TabBarBuilder.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 02.06.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation
import UIKit

final class TabBarBuilder {
    // MARK: Propertie
    private var tabs = [UIViewController]()
    
    // MARK: Methods
    public func addNavController(viewController: UIViewController, title: String?, image: String?, selectedImage: String?) -> Void {
        let tabNavController = UINavigationController()
        let tabNavControllerIcon = UITabBarItem(title: title, image: (image != nil ? UIImage(systemName: image!) : nil), selectedImage: (selectedImage != nil ? UIImage(systemName: selectedImage!) : nil))
        tabNavController.tabBarItem = tabNavControllerIcon
        tabNavController.viewControllers = [viewController]
        tabs.append(tabNavController)
    }
    
    public func build() -> UITabBarController {
        let tabBarController = TabBarController()
        tabBarController.viewControllers = tabs
        
        // Настраиваем стиль
        tabBarController.view.tintColor = Style.TabBar.titntColor
        tabBarController.view.backgroundColor = Style.TabBar.backgroundColor
        
        return tabBarController
    }
}
