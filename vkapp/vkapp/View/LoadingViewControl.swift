//
//  LoadingViewControl.swift
//  weather
//
//  Created by Григорий Мартюшин on 12.11.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class LoadingViewControl: UIControl {
    var lblLoading: UIView!
    var lblLoading1: UIView!
    var lblLoading2: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    private func makeLoadingDot(leftOffset: Int = 0) -> UIView {
        let lblLoadDot = UIView()
        lblLoadDot.backgroundColor = .white
        lblLoadDot.layer.cornerRadius = 7.5
        lblLoadDot.layer.borderWidth = 2
        lblLoadDot.layer.borderColor = UIColor.gray.cgColor
        lblLoadDot.layer.frame = CGRect(x: 0 + leftOffset, y: 0, width: 15, height: 15)
        
        return lblLoadDot
    }

    private func setupView(){
        self.isHidden = true
        
        self.lblLoading = makeLoadingDot()
        addSubview(self.lblLoading)
        
        self.lblLoading1 = makeLoadingDot(leftOffset: 20)
        addSubview(self.lblLoading1)
        
        self.lblLoading2 = makeLoadingDot(leftOffset: 40)
        addSubview(self.lblLoading2)
        
    }
    
    public func startAnimation(){
        self.isHidden = false
        
        self.lblLoading.alpha = 1
        
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
    
    public func stopAnimation(){
        self.isHidden = true
        self.lblLoading.alpha = 1
        
        // Удаляем все анимации
        self.lblLoading.layer.removeAllAnimations()
        self.lblLoading1.layer.removeAllAnimations()
        self.lblLoading2.layer.removeAllAnimations()
        
        // Возвращаем все на свои места
        self.lblLoading.backgroundColor = .white
        self.lblLoading.layer.cornerRadius = 7.5
        self.lblLoading.layer.borderWidth = 2
        self.lblLoading.layer.borderColor = UIColor.gray.cgColor
    }
}
