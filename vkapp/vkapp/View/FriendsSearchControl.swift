//
//  FriendsSearchControl.swift
//  weather
//
//  Created by Григорий Мартюшин on 05.11.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class FriendsSearchControl: UIControl {
    var selectedChar: String? = nil {
        didSet {
            self.updateSelectedChar()
            self.sendActions(for: .valueChanged)
        }
    }
    
    var friendChars: [String] = []
    var stackView: UIStackView!
    private var buttons: [UIButton] = []
    
    private func setupView(){
        self.stackView = UIStackView()
        
        self.stackView.spacing = 8
        self.stackView.axis = .horizontal
        self.stackView.alignment = .center
        self.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.distribution = .fillEqually
        
        self.addSubview(self.stackView)
    }
    
    public func setChars (sChars: [String]){
        self.friendChars = sChars
        
        // Если есть буквы создаем под них кнопки
        if (friendChars.count > 0){
            for sChar in friendChars {
                let button = UIButton(type: .system)
                button.setTitle(sChar, for: .normal)
                button.setTitleColor(.link, for: .normal)
                button.setTitleColor(.white, for: .selected)
                button.addTarget(self, action: #selector(selectChar), for: .touchUpInside)
                button.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
                button.widthAnchor.constraint(greaterThanOrEqualToConstant: 30).isActive = true
                button.addTarget(self, action: #selector(selectChar(_:)), for: .touchUpInside)
                self.buttons.append(button)
                self.stackView.addArrangedSubview(button)
            }
        }
    }
    
    @objc public func selectChar(_ sender: UIButton){
        guard let index = self.buttons.firstIndex(of: sender) else { return }
        self.selectedChar = friendChars[index]
    }
    
    public func updateSelectedChar(){
        for (index, button) in self.buttons.enumerated() {
            guard let sChar:String = self.friendChars[index] else { return }
            button.isSelected = sChar == self.selectedChar
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    

    override func layoutSubviews() {
        super.layoutSubviews()
        self.stackView.frame = bounds
    }
}
