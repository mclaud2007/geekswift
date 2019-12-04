//
//  LoginFormController.swift
//  weather
//
//  Created by Григорий Мартюшин on 17.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit
import WebKit

extension LoginFormController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        guard let url = navigationResponse.response.url, url.path == "/blank.html", let fragment = url.fragment else {
            decisionHandler(.allow)
            return
        }
        
        let params = fragment
                     .components(separatedBy: "&")
                     .map { $0.components(separatedBy: "=") }
            .reduce([String: String]()) { result, param in
                    var dict = result
                    let key = param[0]
                    let value = param[1]
                    dict[key] = value
                    return dict
            }
           
        if let token = params["access_token"] {
            VKLogin.isHidden = true
            
            sessionData.setToken(token: token)
            self.loadingControl.startAnimation()
            
            // Имитация загрузки данных
            self.loadingControl.stopAnimation()
            self.showFriendScreen()
            
        } else {
            showErrorMessage(message: "Не удалось получить токен")
        }
        
        decisionHandler(.cancel)
    }
}

class LoginFormController: UIViewController {
    @IBOutlet var loadingControl: LoadingViewControl!
    @IBOutlet weak var VKLogin: WKWebView! {
        didSet {
            VKLogin.navigationDelegate = self
        }
    }
    
    let sessionData = Session.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Если это найтмод, то цвет background'а будет черный
        if isDarkMode {
            self.view.backgroundColor = .black
        }
        
        // Сразу включим анимацию, потому как если пользователь залогинен мы пойдем дальше
        self.loadingControl.startAnimation()
        
        // Токен надо будет где-то сохранить на устройстве, если он не пустой
        // то идем сразу на экран друзей, в противном случае покажем кнопку
        // вход, которая покажет WebView
        if sessionData.getToken().isEmpty {
            // Готовим запрос
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.host = "oauth.vk.com"
            urlComponents.path = "/authorize"
            urlComponents.queryItems = [
                URLQueryItem(name: "client_id", value: "7230104"),
                URLQueryItem(name: "display", value: "mobile"),
                URLQueryItem(name: "redirect_url", value: "https://oauth.vk.com/blank.html"),
                URLQueryItem(name: "response_type", value: "token")
            ]
            
            let request = URLRequest(url: urlComponents.url!)
            VKLogin.isHidden = true
            
            // Загружаем страницу логина в VK
            VKLogin.load(request)
        } else {
            self.loadingControl.stopAnimation()
            self.showFriendScreen()
        }
        
    }
    
    private func showFriendScreen(){
        let friendVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController")
        friendVC.modalTransitionStyle = .coverVertical
        friendVC.modalPresentationStyle = .overFullScreen
        self.present(friendVC, animated: true, completion: nil)
    }

    @IBAction func loginButtonClick(_ sender: Any) {
        VKLogin.isHidden = false
        /*let login = loginInput.text ?? ""
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
        }*/
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func logautClick(segue: UIStoryboardSegue) {
        sessionData.logout()
        navigationController?.popToRootViewController(animated: true)
    }
}
