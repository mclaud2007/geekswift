//
//  NetworkService.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 04.05.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation

class NetworkService {
    private(set) var configuration = URLSessionConfiguration.default
    let session: URLSession!
    
    enum NetworkServiceError: Error {
        case UnknownCode
        case Forbidden
        case NotFound
        case ServerError
        case EmptyResult
    }
    
    init (configuration: URLSessionConfiguration?) {
        if let configuration = configuration {
            self.configuration = configuration
        }
        
        self.session = URLSession(configuration: self.configuration)
    }
    
    func getDataFrom(url: URL, with emptyResult: Bool = false, complition: @escaping (Swift.Result<Data?, Error>) -> Void){
        let task = session.dataTask(with: url) { (data, response, error) in
            if let resp = response as? HTTPURLResponse {
                // Код ответа 200 - возвращаем данные
                if resp.statusCode == 200 {
                    // По-умолчанию пустой результат это ошибка
                    if (emptyResult == false && data == nil) {
                        complition(.failure(NetworkServiceError.EmptyResult))
                    } else {
                        complition(.success(data))
                    }
                    
                } else {
                    var returnNetworkError: Error
                    
                    switch resp.statusCode {
                    case 404:
                        returnNetworkError = NetworkServiceError.NotFound
                    case 403:
                        returnNetworkError = NetworkServiceError.Forbidden
                    case 500:
                        returnNetworkError = NetworkServiceError.ServerError
                    default:
                        returnNetworkError = error ?? NetworkServiceError.UnknownCode
                    }
                    
                    complition(.failure(returnNetworkError))
                }
                
            } else {
                complition(.failure(NetworkServiceError.UnknownCode))
            }
        }
        
        task.resume()
    }
    
//    func getJsonBy(url: URL, complition: @escaping (Swift.Result<JSON, Error>) -> Void) {
//        self.getDataFrom(url: url) { result in
//            switch result {
//            case .success(let data):
//                let json = JSON(data!)                
//                complition(.success(json))
//                break
//            case .failure(let error):
//                complition(.failure(error))
//                break
//            }
//        }
//    }
}
