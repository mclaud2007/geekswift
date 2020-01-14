//
//  ColorScheme.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 04.01.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit

public enum DefaultStyle {
    public enum Colors {
        public static let darkTint: UIColor = .white
        public static let lightTint: UIColor = .link
        
        public static var tint: UIColor = {
            if #available(iOS 13, *) {
                return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
                    if UITraitCollection.userInterfaceStyle == .dark {
                        /// Return the color for Dark Mode
                        return Colors.darkTint
                    } else {
                        /// Return the color for Light Mode
                        return Colors.lightTint
                    }
                }
            } else {
                /// Return a fallback color for iOS 12 and lower.
                return Colors.darkTint
            }
        }()
    }
}
