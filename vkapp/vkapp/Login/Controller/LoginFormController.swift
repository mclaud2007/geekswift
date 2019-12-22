//
//  LoginFormController.swift
//  weather
//
//  Created by Григорий Мартюшин on 17.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit
import WebKit

class LoginFormController: UIViewController {
    @IBOutlet var loadingControl: LoadingViewControl!
    @IBOutlet weak var VKLogin: WKWebView! {
        didSet {
            VKLogin.navigationDelegate = self
        }
    }
    
    let sessionData = AppSession.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Если это найтмод, то цвет background'а будет черный
        if isDarkMode {
            self.view.backgroundColor = .black
        }
        
        // Сначала попробуем получить токен из Realm
        VKLogin.isHidden = true
        
        // Сразу включим анимацию, потому как если пользователь залогинен мы пойдем дальше
        self.loadingControl.startAnimation()
        
        // Попытуаемся загрузить токен из реалм (либо он вернется либо вернется пустая строка)
        let token = sessionData.getToken()
        
        if token.isEmpty {
            // Показываем окно браузера
            VKLogin.isHidden = false
            
            // Получаем сформированный запрос для получения токена
            let request = VK.shared.getOAuthRequest()
            
            // Загружаем страницу логина в VK
            VKLogin.load(request)
            
        } else {
            // Проверим токен на валидность
            VK.shared.checkToken(token: token) { result in
                if result == true {
                    // Без паузы экран с друзьями не загружается :/
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                        self.loadingControl.stopAnimation()
                        self.showFriendScreen()
                    }
                }
                // Что-то пошло не так - все таки загрузим вебвью
                else {
                    // Показываем окно браузера
                    self.VKLogin.isHidden = false
                    
                    // Получаем сформированный запрос для получения токена
                    let request = VK.shared.getOAuthRequest()
                    
                    // Загружаем страницу логина в VK
                    self.VKLogin.load(request)
                }
            }
            
        }
        
    }
    
    private func showFriendScreen(){
        let friendVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController")
        friendVC.modalTransitionStyle = .coverVertical
        friendVC.modalPresentationStyle = .overFullScreen
        self.present(friendVC, animated: true, completion: nil)
    }
    
    func wkLogout (){
        // Хранилище кук
        let storage = VKLogin.configuration.websiteDataStore.httpCookieStore
        
        // Для логаута нам надо удалить куки
        storage.getAllCookies { cookies in
            for cookie in cookies {
                if cookie.domain.contains(".vk.com") {
                    storage.delete(cookie)
                }
            }
        }
    }

    @IBAction func loginButtonClick(_ sender: Any) {
        VKLogin.isHidden = false
    }
    
    @IBAction func logoutClick(segue: UIStoryboardSegue) {
        // Очищаем сессию
        sessionData.logout()
        
        // Включаем вебвью
        VKLogin.isHidden = false
        
        // Удаляем куки
        self.wkLogout()
        
        // Загружаем страницу входа
        let request = VK.shared.getOAuthRequest()
        VKLogin.load(request)
        
        // Переходим на главный экран
        navigationController?.popToRootViewController(animated: true)
    }
}

extension LoginFormController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        let url = navigationResponse.response.url
               
        if url != nil {
            if (url!.path != "/blank.html" && url!.path != "/error") {
                decisionHandler(.allow)
                return
            }
            
        } else {
            decisionHandler(.allow)
            return
        }

        if url!.path == "/error" {
            // Очищаем сессию
            sessionData.logout()
            
            // Включаем вебвью
            VKLogin.isHidden = false
            
            // Удаляем куки
            self.wkLogout()
            
            // Загружаем страницу входа
            let request = VK.shared.getOAuthRequest()
            VKLogin.load(request)
            
            // Ну и обрадуем пользователя
            showErrorMessage(message: "Произошла ошибка получения токена. Попробуйте ввести логин и пароль еще раз.")
            
        } else {
            if let fragment = url?.fragment {
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
                    
                    // Обновляем токен в сессии
                    sessionData.setToken(token: token)
                    
                    // Тормозим анимацию и переходим на экран со списком друзей
                    self.loadingControl.stopAnimation()
                    self.showFriendScreen()
                    
                } else {
                    showErrorMessage(message: "Не удалось получить токен")
                }
            } else {
                decisionHandler(.allow)
                return
            }
        }
        
        decisionHandler(.cancel)
    }
}
