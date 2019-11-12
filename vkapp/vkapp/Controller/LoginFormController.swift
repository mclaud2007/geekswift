//
//  LoginFormController.swift
//  weather
//
//  Created by Григорий Мартюшин on 17.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class LoginFormController: UIViewController {
    @IBOutlet weak var loginInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var scrolView: UIScrollView!
    @IBOutlet var loadingControl: LoadingViewControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hideKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        scrolView?.addGestureRecognizer(hideKeyboardGesture)
    }

    @IBAction func loginButtonClick(_ sender: Any) {
        let user_login = loginInput.text!
        let user_password = passwordInput.text!
        
        if user_login == "" && user_password == "" {
            performSegue(withIdentifier: "segueMainScreen", sender: nil)
        } else {
            show(message: "Поле логин и пароль должны быть пустыми.")
        }
    }
    
    // Когда клавиатура появляется
    @objc func keyboardWasShown​(notification: Notification) {
        let info = notification.userInfo! as NSDictionary
        let kbSize = (info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: kbSize.height, right: 0.0)
        
        self.scrolView?.contentInset = contentInsets
        scrolView?.scrollIndicatorInsets = contentInsets
    }
    
    // Когда клавиатура исчезает
    @objc func keyboardWillBeHidden(notification: Notification){
        let contentInsets = UIEdgeInsets.zero
        scrolView?.contentInset = contentInsets
        scrolView?.scrollIndicatorInsets = contentInsets
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Прячем полоску навигации, она нам нужна только для того чтобы сделать unwind
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        // Подписываемся на сообщение когда клавиатура появляется
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown​), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // И когда она исчезает
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        loadingControl.startAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func hideKeyboard() {
        self.scrolView?.endEditing(true)
    }
    
    @IBAction func logautClick(segue: UIStoryboardSegue) {
        navigationController?.popToRootViewController(animated: true)
    }
}
