//
//  LoginViewController.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 30.04.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit
import WebKit

class LoginViewController: UIViewController {
    // MARK: Services
    private let service = VKService.shared
    private let session = AppSession.shared
    
    // MARK: Controls
    private var wkWebView: WKWebView?
    private var buttonRetry: UIButton?
    private var notConnectedLabel: UILabel?
    private var labelAnimation: LoadingViewControl?
    
    // Количество попыток, на четвертой - удалим куки попросим залогинится еще раз
    private var retryCount: Int = 0
    
    // MARK: Lyfecycle
    // Загружаем кастомную вьюху
    override func loadView() {
        self.view = LoginView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Закастим текущую вьюху как LoginView, если не получилось - то дальше идти смысла нет
        guard let view = self.view as? LoginView else { return }
        
        // Анимашка загрузки
        labelAnimation = view.labelAnimations
        
        // Текст о том что не получилось приконнектится
        notConnectedLabel = view.notConnectLabel
        notConnectedLabel?.isHidden = true
        
        // Кнопка повторить авторизацию
        buttonRetry = view.buttonRetry
        buttonRetry?.addTarget(self, action: #selector(retryGetLoggedIn(_:)), for: .touchUpInside)
        
        // Запоминаем вебвью оно дальше пригодится, чтобы вью не кастить постоянно
        wkWebView = view.wkWebView
        
        // По-умолчанию окно скрыто. Будем его показывать только, если страница загрузилась
        wkWebView?.isHidden = true
        
        // Проверяем залогинен ли пользователь
        checkLoggedInStatus()
        
        // Устанавливаем делегат для WebKit на себя
        wkWebView?.navigationDelegate = self
        
        // Устанавливаем цвет фона
        view.backgroundColor = Style.loginScreen.background
    }
    
    // MARK: Methods
    public func checkLoggedInStatus() {
        // Стартуем анимацию
        labelAnimation?.isHidden = false
        labelAnimation?.startAnimation()
        
        // Проверяем залогинен ли пользователь
        service.getCheckLogedIn { [weak self] logged in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if !logged {
                    self.wkWebView?.load(self.service.getOAuthRequest())
                } else {
                    self.showFriendScreen()
                }
            }
        }
    }
    
    // Пробуем повторно пройти авторизацию
    @objc public func retryGetLoggedIn(_ sender: UIButton) {
        // Прячем кнопку
        buttonRetry?.isHidden = true
        notConnectedLabel?.isHidden = true
        
        // Увеличиваем количество повторений
        retryCount += 1
        
        // Если это четвертый раз - для начала удалим куки
        if retryCount >= 4 {
            wkLogout()
            retryCount = 0
        }
        
        // И пробуем еще раз
        checkLoggedInStatus()
    }
    
    fileprivate func showFriendScreen() {
        // создаем контейнер с боковым меню, которое запустит остальное приложение
        AppManager.shared.showApplicationContainer()
    }
    
    public func wkLogout(){
        // Хранилище кук
        if let storage = self.wkWebView?.configuration.websiteDataStore.httpCookieStore {
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
}

// MARK: NavigationDelegate
extension LoginViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        // Адрес который мы пытаемся загрузить не может быть пустым
        guard let url = navigationResponse.response.url else {
            decisionHandler(.cancel)
            return
        }
        
        // Мы ждём редирект на страницу blank.html или error
        if (url.path != "/blank.html" && url.path != "/error") {
            wkWebView?.isHidden = false
            decisionHandler(.allow)
            return
            
        } else if (url.path == "/error") {
            showErrorMessage(message: NSLocalizedString("Token recieve error. Try again later.", comment: ""))
            wkWebView?.isHidden = true
            wkLogout()
            // Загружаем по новому страницу с авторизацией
            wkWebView?.load(service.getOAuthRequest())
            
        } else if (url.path == "/blank.html") {
            if let fragment = url.fragment {
                let params = fragment
                    .components(separatedBy: "&")
                    .map { $0.components(separatedBy: "=") }
                    .reduce([String: String]()) { result, param in
                        var dict = result
                        dict[param[0]] = param[1]
                        return dict
                }
                
                if let token = params["access_token"] {
                    // Скрываем вебвью
                    wkWebView?.isHidden = true
                    
                    // Сохраняем токен в сессию
                    session.setToken(token: token)
                                        
                    // Загружаем информацию о пользователе
                    service.getUserInfo { [weak self] result in
                        guard let self = self else { return }
                        
                        switch result {
                        case .success(let info):
                            // Сохраняем информацию о пользователе в сессию
                            self.session.setUserInfoBy(info)
                            
                            // Открываем страницу со списком друзей
                            DispatchQueue.main.async {
                                self.showFriendScreen()
                            }
                            
                            break
                        case .failure(_):
                            // TODO: Добавить кнопку "Повторить"!
                            DispatchQueue.main.async {
                                self.showErrorMessage(message: NSLocalizedString("Auth error. Try again later.", comment: ""))
                            }
                            break
                        }
                    }
                    
                    // Отменим загрузку текущей страницы - она больше не нужна
                    decisionHandler(.cancel)
                    return
                    
                } else {
                    showErrorMessage(message: NSLocalizedString("Auth error. Try again later.", comment: ""))
                    decisionHandler(.cancel)
                    return
                    
                }
                
            } else {
                wkWebView?.isHidden = false
                decisionHandler(.allow)
                return
            }
        }
        
        // В любой непонятной ситуации выби выбиваем ошибку
        decisionHandler(.cancel)
        return
        
    }
    
    // Вызывается когда страница загружена (десижен хэндлер нот кэнселд)
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        notConnectedLabel?.isHidden = true
        labelAnimation?.stopAnimation()
        labelAnimation?.isHidden = true
    }
    
    // Вызывается при любой ошибке загрузки страницы, кроме отмены загрузки
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if let err = error as? URLError {
            if err.code != .cancelled {
                showErrorMessage(message: NSLocalizedString("Auth page loading error. Try again later.", comment: ""))
                
                // Показываем кнопку и надпись что ничего не вышло
                buttonRetry?.isHidden = false
                notConnectedLabel?.isHidden = false
                labelAnimation?.stopAnimation()
                labelAnimation?.isHidden = true
            }
        
        }
    }
}
