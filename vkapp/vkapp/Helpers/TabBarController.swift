//
//  TabBarController.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 03.01.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = DefaultStyle.self.Colors.tint

        if let items = tabBar.items {
            for item in items {
                if let title = item.title {
                    item.title = NSLocalizedString(title, comment: "")
                }
            }
        }
    }
}
