//
//  FriendsSearchControl.swift
//  weather
//
//  Created by Григорий Мартюшин on 05.11.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

protocol FriendsSearchControlProto {
    func charSelected(sender: FriendsSearchControl) -> Void
}

class FriendsSearchControl: UIControl {
    public var delegate: FriendsSearchControlProto!
    
    public var selectedChar: String? {
        didSet {
            self.updateSelectedChar()
            self.delegate?.charSelected(sender: self)
        }
    }
    
    var friendsLastNameCharsArray: [String?] = []
    var stackView: UIStackView!
    private var buttons: [UIButton] = []
    
    private func setupView(){
        self.stackView = UIStackView()
        
        self.stackView.axis = .vertical
        self.stackView.alignment = .center
        self.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.distribution = .fillEqually
        
        self.addSubview(self.stackView)
    }
    
    public func setChars (sChars: [String]){
        self.friendsLastNameCharsArray = sChars
        //self.friendChars.append("All")
        
        // Здесь будем хранить предыдущую кнопку для расчета констрейнтов
        var prevButton: UIButton?
        
        // Если есть буквы создаем под них кнопки
        if (friendsLastNameCharsArray.count > 0){
            for sChar in friendsLastNameCharsArray {
                let button = UIButton(type: .system)
                
                button.setTitle(sChar, for: .normal)
                button.setTitleColor(.link, for: .normal)
                button.setTitleColor(.white, for: .selected)
                button.addTarget(self, action: #selector(setChar), for: .touchUpInside)
                
                // Задаем размеры созданной кнопки
                let widthConstraint = button.widthAnchor.constraint(equalToConstant: 30)
                widthConstraint.priority = UILayoutPriority(rawValue: 999)
                widthConstraint.isActive = true

                let heightConstraint = button.heightAnchor.constraint(equalToConstant: 30)
                heightConstraint.priority = UILayoutPriority(rawValue: 999)
                heightConstraint.isActive = true
                
                // Добавляем в массив кнопок и размещаем на stackView
                self.buttons.append(button)
                self.stackView.addArrangedSubview(button)
                
                // Уже была создана кнопка ранее, верх расчитаем от её низа
                if let _ = prevButton {
                    let topConstraint = button.topAnchor.constraint(equalTo: prevButton!.bottomAnchor)
                    topConstraint.priority = UILayoutPriority(rawValue: 999)
                    topConstraint.isActive = true
                } else {
                    // В противном случае верх считаем от верха stackView
                    let topConstraint = button.topAnchor.constraint(equalTo: self.stackView.layoutMarginsGuide.topAnchor)
                    topConstraint.priority = UILayoutPriority(rawValue: 999)
                    topConstraint.isActive = true
                }
                
                // Вешаем обработку по нажатию
                button.addTarget(self, action: #selector(setChar(_:)), for: .touchUpInside)
                
                // Запоминаем текущую кнопку как предыдущую
                prevButton = button
            }
        }
    }
    
    @objc public func setChar(_ sender: UIButton){
        guard let index = self.buttons.firstIndex(of: sender) else { return }
        
        if friendsLastNameCharsArray.indices.contains(index) {
            self.selectedChar = friendsLastNameCharsArray[index]
        } else {
            return
        }
    }
    
    public func updateSelectedChar(){
        for (index, button) in self.buttons.enumerated() {
            if self.friendsLastNameCharsArray.indices.contains(index) {
                let sChar = self.friendsLastNameCharsArray[index]
            
                if sChar != "All" {
                    button.isSelected = sChar == self.selectedChar
                }
            }
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
