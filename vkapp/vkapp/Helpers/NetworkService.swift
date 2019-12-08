//
//  VKApiClass.swift
//  weather
//
//  Created by Григорий Мартюшин on 07.12.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import Foundation
import Alamofire

class VK {
    private let APIUrl = "api.vk.com"
    private let APIUriSuffix = "/method"
    let APIVersion = "5.103"
    
    private let OAuthURL = "oauth.vk.com"
    private let OAuthUriSuffix = "/authorize"
    private let OAuthBackLink = "https://oauth.vk.com/blank.html"
    
    private let APISchema = "https"
    private let ClientID = "7238798"
    
    // Сделаем синглом
    static let shared = VK()
    
    public func getOAuthRequest () -> URLRequest {
        // Готовим запрос
        var urlComponents = URLComponents()
        urlComponents.scheme = self.APISchema
        urlComponents.host = self.OAuthURL
        urlComponents.path = self.OAuthUriSuffix
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: self.ClientID),
            URLQueryItem(name: "display", value: "mobile"),
            URLQueryItem(name: "redirect_url", value: OAuthBackLink),
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "scope", value: "262150")
        ]
        
        return URLRequest(url: urlComponents.url!)
    }
    
    public func setCommand (_ apiMethod: String, param: Parameters?, completion: ((AFDataResponse<Any>) -> Void)? ) {
        let url = self.APISchema + "://" + self.APIUrl + self.APIUriSuffix + "/" + apiMethod
                
        AF.request(url, method: .get, parameters: param).responseJSON { response in
            completion?(response)
        }
    }
    
}
