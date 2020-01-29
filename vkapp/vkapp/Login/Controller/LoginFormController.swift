//
//  LoginFormController.swift
//  VKApp
//
//  Created by Григорий Мартюшин on 17.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit
import WebKit

class LoginFormController: UIViewController {
    // MARK: Контроллер анимации
    @IBOutlet var loadingControl: LoadingViewControl!
    
    // MARK: WebKit для работы логина
    @IBOutlet weak var wkVKLogin: WKWebView! {
        didSet {
            wkVKLogin.navigationDelegate = self
        }
    }
    
    let sessionData = AppSession.shared
    let vkService = VKService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Если это найтмод, то цвет background'а будет черный
        if isDarkMode {
            view.backgroundColor = .black
        }
        
        // Сначала попробуем получить токен из Realm
        wkVKLogin.isHidden = true
        
        // Сразу включим анимацию, потому как если пользователь залогинен мы пойдем дальше
        loadingControl.startAnimation()
        
        // Проверять токены будем в бэкграунде
        DispatchQueue.global().async {
            // Попытуаемся загрузить токен из реалм (либо он вернется либо вернется пустая строка)
            if let token = self.sessionData.getToken() {
                self.vkService.checkToken(token: token) { result in
                    // Дальше работаем в главном поток
                    DispatchQueue.main.async {
                        if result == true {
                            self.loadingControl.stopAnimation()
                            self.showFriendScreen()
                            
                        } else {
                            // Показываем окно браузера
                            self.wkVKLogin.isHidden = false
                            
                            // Получаем сформированный запрос для получения токена
                            let request = self.vkService.getOAuthRequest()
                            
                            // Загружаем страницу логина в VK
                            self.wkVKLogin.load(request)
                        }
                        
                    }
                }
            } else {
                // Дальше работаем в главном поток
                DispatchQueue.main.async {
                    // Показываем окно браузера
                    self.wkVKLogin.isHidden = false
                    
                    // Получаем сформированный запрос для получения токена
                    let request = self.vkService.getOAuthRequest()
                    
                    // Загружаем страницу логина в VK
                    self.wkVKLogin.load(request)
                }
            }
        }
    }
    
    @IBAction func logoutClick(segue: UIStoryboardSegue) {
        // Очищаем сессию
        sessionData.logout()
        
        // Включаем вебвью
        wkVKLogin.isHidden = false
        
        // Удаляем куки
        wkLogout()
        
        // Загружаем страницу входа
        let request = vkService.getOAuthRequest()
        wkVKLogin.load(request)

    }
}

extension LoginFormController {
    private func showFriendScreen(){
        let friendVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController")
        friendVC.modalTransitionStyle = .coverVertical
        friendVC.modalPresentationStyle = .overFullScreen
        self.present(friendVC, animated: true, completion: nil)
    }
    
    func wkLogout (){
        // Хранилище кук
        let storage = wkVKLogin.configuration.websiteDataStore.httpCookieStore
        
        // Для логаута нам надо удалить куки
        storage.getAllCookies { cookies in
            for cookie in cookies {
                if cookie.domain.contains(".vk.com") {
                    storage.delete(cookie)
                }
            }
        }
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
        
        // Запускаем анимацию
        loadingControl.startAnimation()
        
        // Прячем веб-вью - оно нам больше не нужно
        wkVKLogin.isHidden = true

        if url!.path == "/error" {
            // Очищаем сессию
            sessionData.logout()
            
            // Включаем вебвью
            wkVKLogin.isHidden = false
            
            // Удаляем куки
            wkLogout()
            
            // Загружаем страницу входа
            let request = vkService.getOAuthRequest()
            wkVKLogin.load(request)
            
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
                    // Обновляем токен в сессии
                    sessionData.setToken(token: token)
                    
                    // Тормозим анимацию и переходим на экран со списком друзей
                    loadingControl.stopAnimation()
                    showFriendScreen()
                    
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
