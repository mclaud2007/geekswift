//
//  LoadingViewControl.swift
//  weather
//
//  Created by Григорий Мартюшин on 12.11.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class LoadingViewControl: UIControl {
    private lazy var lblLoading: UIView! = {
        let label = UIView()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.backgroundColor = .white
        label.layer.cornerRadius = 7.5
        label.layer.borderWidth = 2
        label.layer.borderColor = UIColor.gray.cgColor
        return label
    }()
    
    private var lblLoading1: UIView! = {
        let label = UIView()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.backgroundColor = .white
        label.layer.cornerRadius = 7.5
        label.layer.borderWidth = 2
        label.layer.borderColor = UIColor.gray.cgColor
        return label
    }()
    
    private var lblLoading2: UIView! = {
        let label = UIView()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.backgroundColor = .white
        label.layer.cornerRadius = 7.5
        label.layer.borderWidth = 2
        label.layer.borderColor = UIColor.gray.cgColor
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    

    private func configureView(){
        isHidden = true
        
        self.addSubview(lblLoading)
        self.addSubview(lblLoading1)
        self.addSubview(lblLoading2)
        
        NSLayoutConstraint.activate([
            lblLoading.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            lblLoading.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor),
            lblLoading.widthAnchor.constraint(equalToConstant: 15),
            lblLoading.heightAnchor.constraint(equalToConstant: 15),
            
            lblLoading1.widthAnchor.constraint(equalToConstant: 15),
            lblLoading1.heightAnchor.constraint(equalToConstant: 15),
            lblLoading1.leftAnchor.constraint(equalTo: self.lblLoading.leftAnchor, constant: 20),
            lblLoading1.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            
            lblLoading2.widthAnchor.constraint(equalToConstant: 15),
            lblLoading2.heightAnchor.constraint(equalToConstant: 15),
            lblLoading2.leftAnchor.constraint(equalTo: self.lblLoading1.leftAnchor, constant: 20),
            lblLoading2.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
        ])
        
    }
    
    func startAnimation(){
        isHidden = false
        
        lblLoading.alpha = 1
        
        UIView.animate(withDuration: 1, delay: 0.2, options: [.repeat, .autoreverse], animations: {
            self.lblLoading.alpha = 0.3
            self.lblLoading.backgroundColor = UIColor.green
            self.lblLoading.layer.borderColor = UIColor.white.cgColor
        } )
        
        UIView.animate(withDuration: 1, delay: 0.3, options: [.repeat, .autoreverse], animations: {
            self.lblLoading1.alpha = 0.3
            self.lblLoading1.backgroundColor = UIColor.green
            self.lblLoading1.layer.borderColor = UIColor.white.cgColor
        } )
        
        UIView.animate(withDuration: 1, delay: 0.4, options: [.repeat, .autoreverse], animations: {
            self.lblLoading2.alpha = 0.3
            self.lblLoading2.backgroundColor = UIColor.green
            self.lblLoading2.layer.borderColor = UIColor.white.cgColor
        } )
    }
    
    func stopAnimation(){
        isHidden = true
        lblLoading.alpha = 1
        
        // Удаляем все анимации
        lblLoading.layer.removeAllAnimations()
        lblLoading1.layer.removeAllAnimations()
        lblLoading2.layer.removeAllAnimations()
        
        // Возвращаем все на свои места
        lblLoading.backgroundColor = .white
        lblLoading.layer.cornerRadius = 7.5
        lblLoading.layer.borderWidth = 2
        lblLoading.layer.borderColor = UIColor.gray.cgColor
    }
}
