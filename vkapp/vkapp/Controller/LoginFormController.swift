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
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var loadingControl: LoadingViewControl!
    let sessionData = Session.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hideKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        scrollView?.addGestureRecognizer(hideKeyboardGesture)
        
        // Если это найтмод, то цвет background'а будет черный
        if isDarkMode {
            self.view.backgroundColor = .black
        }
    }
    
    private func showFriendScreen(){
        let friendVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController")
        friendVC.modalTransitionStyle = .coverVertical
        friendVC.modalPresentationStyle = .overFullScreen
        self.present(friendVC, animated: true, completion: nil)
    }

    @IBAction func loginButtonClick(_ sender: Any) {
        let login = loginInput.text ?? ""
        let password = passwordInput.text ?? ""
        
        if sessionData.login(login: login, password: password) {
            self.loadingControl.startAnimation()
            
            // Имитация загрузки данных
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                self.loadingControl.stopAnimation()
                self.showFriendScreen()
                //self.performSegue(withIdentifier: "segueMainScreen", sender: nil)
            }
        } else {
            showErrorMessage(message: "Поле логин и пароль должны быть пустыми.")
        }
    }
    
    // Когда клавиатура появляется
    @objc func keyboardWasShown​(notification: Notification) {
        if let _ = scrollView {
            let info = notification.userInfo! as NSDictionary
            let kbSize = (info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: kbSize.height, right: 0.0)
            
            scrollView?.contentInset = contentInsets
            scrollView?.scrollIndicatorInsets = contentInsets
        }
        
    }
    
    // Когда клавиатура исчезает
    @objc func keyboardWillBeHidden(notification: Notification){
        let contentInsets = UIEdgeInsets.zero
        
        scrollView?.contentInset = contentInsets
        scrollView?.scrollIndicatorInsets = contentInsets
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Подписываемся на сообщение когда клавиатура появляется
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown​), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // И когда она исчезает
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func hideKeyboard() {
        scrollView?.endEditing(true)
        
    }
    
    @IBAction func logautClick(segue: UIStoryboardSegue) {
        sessionData.logout()
        navigationController?.popToRootViewController(animated: true)
    }
}
