//
//  MenuViewController.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 08.06.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    var menuView: MenuView {
        return view as! MenuView
    }
    
    override func loadView() {
        super.loadView()
        self.view = MenuView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Style.sideMenu.background
    }

}
