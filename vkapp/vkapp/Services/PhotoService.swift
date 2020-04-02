//
//  PhotoService.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 03.02.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class PhotoService {
    // Время жизни кэша в секундах
    private let cacheLifetime: TimeInterval = 60 * 60
    private static var cachedImages = [String: UIImage]()
    
    // Путь где хранится кэш
    private var cachePath: URL? {
        let pathName: String = "images"
        
        guard let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
       
        let url = cacheDirectory.appendingPathComponent(pathName, isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        
        return url
    }
    
    // Получаем полный путь до файла где будем хранить кэш
    private func getFileName (from urlString: String) -> URL? {
        guard let cacheDirectory = self.cachePath else { return nil }
        
        // Предварительно получим URL от строки
        let urlTarget = URL(string: urlString)
        
        // Здесь будем хранить наше имя файла
        var fileName: String
        
        // Получаем название файла из url
        if let component = urlTarget,
            !component.lastPathComponent.isEmpty
        {
            fileName = component.lastPathComponent
        }
        // В крайнем случае получим просто из строки
        else {
            if let fName = urlString.split(separator: "/").last {
                fileName = String(fName)
            } else {
                fileName = String(NSDate().timeIntervalSince1970)
            }
        }
        
        return cacheDirectory.appendingPathComponent(fileName, isDirectory: false)
    }
    
    private func setPhotoToDisk(for urlString: String, image: UIImage) {
        guard let fileName = getFileName(from: urlString) else { return }
        
        if let data = image.pngData() {
            // Сохраняем изображение в память
            DispatchQueue.main.async {
                PhotoService.cachedImages[fileName.path] = image
            }
            
            do {
                try data.write(to: fileName)
            }
            // Это кэш нет нужды обрабатывать ситуацию когда файл не записался
            // Нет так нет ничего страшного
            catch { }
        }
    }
    
    private func getPhotoFromDisk(by urlString: String) -> UIImage? {
        guard let fileName = getFileName(from: urlString),
            let info = try? FileManager.default.attributesOfItem(atPath: fileName.path),
            let modificationDate = info[FileAttributeKey.modificationDate] as? Date else { return nil }
        
        let lifeTime = Date().timeIntervalSince(modificationDate)
 
        guard lifeTime <= cacheLifetime,
            let image = UIImage(contentsOfFile: fileName.path) else { return nil }
        
        // Сохраняем изображение в память
        PhotoService.cachedImages[fileName.path] = image
        
        return image
    }
    
    public func getPhoto(by urlString: String, complition: @escaping (UIImage?) -> Void) {
        if let fileName = getFileName(from: urlString),
            let image = PhotoService.cachedImages[fileName.path] {
            complition(image)
            
        } else if let image = getPhotoFromDisk(by: urlString) {
            complition(image)
            
        } else {
            if let url = URL(string: urlString) {
                AF.request(url).responseData(queue: .global(qos: .userInitiated)) { resp in
                    if let imageData = resp.data,
                        let image = UIImage(data: imageData)
                    {
                        // Сохраняем фотографию
                        self.setPhotoToDisk(for: urlString, image: image)
                        
                        // Вызываем замыкание
                        complition(image)
                    }
                }
                
            } else {
                complition(nil)
            }
        }
    }
}
