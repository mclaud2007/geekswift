//
//  ContainerController.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 08.06.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit

class ContainerController: UIViewController {
    private(set) var MainScreenVC: UITabBarController?
    private(set) weak var MenuVC: MenuViewController?
    private(set) var IsMenuOpened: Bool = false
    
    // Количество пикселей насколько будет недоезжать правое меню до края экрана
    let magickNumberForRightMenu: CGFloat = 55
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.configureView()
    }
    
    func configureView() {
        // Разводкой в приложении занимается таббар - первой вьюхой, которого экран
        // со списком друзей
        let builder = TabBarBuilder()
         
        // Вкладка друзья, она завернута в NavigationController
        builder.addNavController(viewController: FriendsListController(), title: NSLocalizedString("Friends", comment: ""), image: "person", selectedImage: "person.fill")
         
        // Вкладка группы
        builder.addNavController(viewController: GroupsListController(), title: NSLocalizedString("Groups", comment: ""), image: "person.3", selectedImage: "person.3.fill")
         
        // Вкладка новости
        builder.addNavController(viewController: NewsListController(), title: NSLocalizedString("News", comment: ""), image: "book", selectedImage: "book.fill")

        // Создаем таббар
        let mainScreenVC = builder.build()
        self.MainScreenVC = mainScreenVC
        view.addSubview(mainScreenVC.view)
        addChild(mainScreenVC)
    }
    
    func configureMenuView() {
        // Если мы еще не добавили вьюху для меню - самое время
        if self.MenuVC == nil {
            let menuVC = MenuViewController()
            menuVC.view.frame = CGRect(x: magickNumberForRightMenu, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            self.MenuVC = menuVC
            view.insertSubview(menuVC.view, at: 0)
            addChild(menuVC)
        }
    }
    
    func toggleMenu() {
        configureMenuView()
        // Для следующего раза переключаем состояния
        IsMenuOpened = !IsMenuOpened
        
        // Сдвинуть основной экран надо на всю его ширину - 50 пикселей
        // 295 - просто "магическое число", т.е. если что-то пойдет не так
        // экран уедет на 240 пикселей
        let mainScreenMoveTo = view.bounds.width - magickNumberForRightMenu

        // Анимация для меню
        if IsMenuOpened == true {
            // Сначала задвигаем меню, чтобы оно выезжало
            self.MenuVC?.view.frame.origin.x += mainScreenMoveTo
            
            // показываем menu
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0,
                           options: .curveEaseInOut,
                           animations: {
                            self.MainScreenVC?.view.frame.origin.x -= mainScreenMoveTo
                            self.MenuVC?.view.frame.origin.x -= mainScreenMoveTo

            })
        } else {
            // показываем menu
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0,
                           options: .curveEaseInOut,
                           animations: {
                            self.MainScreenVC?.view.frame.origin.x += mainScreenMoveTo
                            self.MenuVC?.view.frame.origin.x += mainScreenMoveTo
                            
            }) { (finish) in
                self.MenuVC?.view.frame.origin.x = self.magickNumberForRightMenu
            }
        }
    }
}
