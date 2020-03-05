//
//  UIViewController+Ext.swift
//  weather
//
//  Created by Григорий Мартюшин on 23.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

extension UIViewController {
    func showErrorMessage (message: String){
        let alertVC = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alertVC.addAction(okAction)
        present(alertVC, animated: true)
    }
}

extension UIViewController {
    var isDarkMode: Bool {
        if #available(iOS 13.0, *) {
            return self.traitCollection.userInterfaceStyle == .dark
        }
        else {
            return false
        }
    }
}

protocol  VKAppService {
    func getNotFoundPhoto () -> UIImage
}

extension VKAppService {
    func getNotFoundPhoto () -> UIImage {
        return UIImage(named: "photonotfound")!
    }
}

extension GroupsViewFactory {
    func getNotFoundPhoto () -> UIImage {
        return UIImage(named: "photonotfound")!
    }
}

extension UIViewController: VKAppService {}
//extension FriendsCellProto: VKAppService {}
extension UICollectionViewCell: VKAppService {}
extension UITableViewCell: VKAppService {}
