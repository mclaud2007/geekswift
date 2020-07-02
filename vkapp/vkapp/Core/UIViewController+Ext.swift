//
//  UIViewController+Ext.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 01.05.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showErrorMessage (message: String){
        let alertVC = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alertVC.addAction(okAction)
        present(alertVC, animated: true)
    }
}
