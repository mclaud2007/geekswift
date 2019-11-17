//
//  LoadingViewControl.swift
//  weather
//
//  Created by Григорий Мартюшин on 12.11.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class LoadingViewControl: UIView {
    var lblLoading: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }

    private func setupView(){
        print(bounds.width)
        self.lblLoading = UILabel()
        self.lblLoading.frame = CGRect(x: 25, y: 0, width: bounds.width, height: bounds.height)
        self.lblLoading.textAlignment = .center
        self.lblLoading.font = UIFont.systemFont(ofSize: 36)
        self.lblLoading.textColor = .white
        self.lblLoading.text = ">>> ... <<<"
        
        addSubview(self.lblLoading)
    }
    
    public func startAnimation(){
        self.lblLoading.alpha = 1
        
        UIView.animate(withDuration: 1, delay: 0.2, options: [.repeat, .autoreverse], animations: {
            self.lblLoading.alpha = 0.1
        } )
    }
}
