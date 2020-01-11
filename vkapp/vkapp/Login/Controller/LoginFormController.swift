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
    
    let networkService = VK.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Если это найтмод, то цвет background'а будет черный
        if isDarkMode {
            self.view.backgroundColor = .black
        }
        
        // Сначала попробуем получить токен из Realm
        wkVKLogin.isHidden = true
        
        // Сразу включим анимацию, потому как если пользователь залогинен мы пойдем дальше
        self.loadingControl.startAnimation()
        
        // Попытуаемся загрузить токен из реалм (либо он вернется либо вернется пустая строка)
        let token = sessionData.getToken()
        
        if token.isEmpty {
            // Показываем окно браузера
            wkVKLogin.isHidden = false
            
            // Получаем сформированный запрос для получения токена
            let request = VK.shared.getOAuthRequest()
            
            // Загружаем страницу логина в VK
            wkVKLogin.load(request)
            
        } else {
            // Проверим токен на валидность
            networkService.checkToken(token: token) { result in
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
                    self.wkVKLogin.isHidden = false
                    
                    // Получаем сформированный запрос для получения токена
                    let request = self.networkService.getOAuthRequest()
                    
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
        let request = VK.shared.getOAuthRequest()
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

        if url!.path == "/error" {
            // Очищаем сессию
            sessionData.logout()
            
            // Включаем вебвью
            wkVKLogin.isHidden = false
            
            // Удаляем куки
            self.wkLogout()
            
            // Загружаем страницу входа
            let request = VK.shared.getOAuthRequest()
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
                    wkVKLogin.isHidden = true
                    
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
