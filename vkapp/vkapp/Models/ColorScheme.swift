//
//  ColorSchema.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 30.04.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation
import UIKit

// Таблица стилей
public enum Style {
    public static var isDarkMode: Bool {
        if #available(iOS 13.0, *) {
            return UITraitCollection.current.userInterfaceStyle == .dark
        }
        else {
            return false
        }
    }
    
    public enum Colors {
        public static let darkTint: UIColor = .link
        public static let lightTint: UIColor = .white
        
        public static let defaultTintColor: UIColor = {
            return Style.isDarkMode ? Style.Colors.lightTint : Style.Colors.darkTint
        }()
        
        public static let defaultTextColor: UIColor = {
            return Style.isDarkMode ? .white : .black
        }()
    }
    
    public enum friendScreen {
        public static var background: UIColor = {
            return Style.isDarkMode ? .black : .systemBackground
        }()
        
        public static let textColor: UIColor = {
            return Style.isDarkMode ? .white : .black
        }()
        
        public static let cityColor: UIColor = {
            return Style.isDarkMode ? .white : .lightGray
        }()
    }
    
    public enum friendDetailScreen {
        public static var background: UIColor = {
            return Style.isDarkMode ? .black : .systemBackground
        }()
        
        public static let textColor: UIColor = {
            return Style.isDarkMode ? .white : .black
        }()
        
        public static let cityColor: UIColor = {
            return Style.isDarkMode ? .white : .lightGray
        }()
    }
    
    public enum friendBigScreen {
        public static var background: UIColor = {
            return Style.isDarkMode ? .black : .systemBackground
        }()
        
        public static let textColor: UIColor = {
            return Style.isDarkMode ? .white : .black
        }()
        
        public static let cityColor: UIColor = {
            return Style.isDarkMode ? .white : .lightGray
        }()
    }
    
    public enum groupScreen {
        // На самом деле это тоже самое
        public static var background: UIColor = {
            return Style.friendScreen.background
        }()
        
        public static let textColor: UIColor = {
            return Style.friendScreen.textColor
        }()
    }
    
    public enum newsScreen {
        public static var background: UIColor = {
            return Style.friendScreen.background
        }()
        
        public static let textColor: UIColor = {
            return Style.friendScreen.textColor
        }()
    }
    
    public enum loginScreen {
        public static var background: UIColor = {
            return Style.isDarkMode ? .black : UIColor(red: 0.253648, green: 0.490195, blue: 0.838409, alpha: 1)
        }()
        
        public static let appLabelColor: UIColor = .white
        public static var appLabelShadowColor: UIColor = {
            return Style.isDarkMode ? .link : .darkText
        }()
    }
    
    public enum sideMenu {
        public static var background: UIColor = {
            return Style.isDarkMode ? .darkGray : .lightGray
        }()
    }
    
    public enum TabBar {
        public static let titntColor: UIColor = {
            return Style.isDarkMode ? .white : .link
        }()
        
        public static let backgroundColor: UIColor = {
            return Style.isDarkMode ? .black : .white
        }()
    }
}

func setupGlobalStyles() {
    let attributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: Style.Colors.defaultTintColor
    ]
    
    UIBarButtonItem.appearance().setTitleTextAttributes(attributes, for: .normal)
}
