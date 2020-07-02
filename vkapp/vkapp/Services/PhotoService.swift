//
//  PhotoService.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 06.06.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation
import UIKit

class PhotoService {
    private(set) var network = NetworkService(configuration: nil)
    private let cacheLifetime: TimeInterval = 60 * 60
    private(set) lazy var cachedImages = [String:UIImage]()
    static let shared = PhotoService()
        
    // Путь к дирректории для кэша изображений
    private var cacheDir: URL? {
        let pathName = "images"
        
        // Запрашиваем адрес директории кэша пользователя
        guard let caheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
        
        // Дополняем её названием images
        let url = caheDirectory.appendingPathComponent(pathName)

        // Если её нет пытаемся создать
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        
        return url
    }
    
    // Получаем название файла из url
    private func getCacheFileNameUrlFrom(string: String, category: String?) -> URL? {
        // Получилось получить URL из строки
        guard let url = URL(string: string) else { return nil }
        
        // Нам известна директория с кэшем
        guard var cacheDir = cacheDir else { return nil }
        
        // Возможно указана категория изображения - тогда добавим еще и информацию о ней
        if let category = category {
            cacheDir = cacheDir.appendingPathComponent(category)
            
            // Также создадим её в случае необходимости
            if !FileManager.default.fileExists(atPath: cacheDir.path) {
                try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true, attributes: nil)
            }
        }
        
        // По умолчанию название будет браться из последнего компонента URL
        var fileName = url.lastPathComponent
        
        // Если же оно пустое то попробуем получить иначе
        if (fileName.isEmpty) {
            if let fName = string.split(separator: "/").last {
                fileName = String(fName)
            } else {
                // В самом худшем случае у нас будет таймштамп
                fileName = String(NSDate().timeIntervalSince1970)
            }
        }
        
        return cacheDir.appendingPathComponent(fileName)
    }
    
    // Попытаемся получить закешированные данные
    private func getCachedPhotoBy(urlString: String, category photoCategory: String?) -> UIImage? {
        // Получаем путь к закешированному файлу
        guard let cachedFileName = getCacheFileNameUrlFrom(string: urlString, category: photoCategory),
            let info = try? FileManager.default.attributesOfItem(atPath: cachedFileName.path),
            let modificationDate = info[FileAttributeKey.modificationDate] as? Date else { return nil }

        let lifeTime = Date().timeIntervalSince(modificationDate)
        
        guard lifeTime <= cacheLifetime else { return nil }
        
        // Изображение уже кешировано в ОЗУ
        if let image = self.cachedImages[urlString] {
            return image
            
        } else {
            guard let imageData = try? Data(contentsOf: cachedFileName),
            let image = UIImage(data: imageData) else { return nil }
            
            // Сохраняем изображение в память
            self.cachedImages[urlString] = image
            
            return image
        }
    }
    
    // Попытаемся сохранить загруженное фото в кэш
    private func setPhotoToCache(image: UIImage, urlString: String, category: String?) {
        guard let cachedFilename = getCacheFileNameUrlFrom(string: urlString, category: category) else { return }
        
        if let data = image.pngData() {
            do {
                try data.write(to: cachedFilename)
                
                // Если у нас все получилось - положим изображение в массив в память
                self.cachedImages[urlString] = image
            } catch { }
        }
    }
    
    func getPhotoBy(urlString: String, catrgory: String? = nil, completion: @escaping (UIImage?) -> Void) {
        if let url = URL(string: urlString) {
            // Попытаемся проверить существование кэша
            if let image = getCachedPhotoBy(urlString: urlString, category: catrgory) {
                completion(image)

            } else {
                network.getDataFrom(url: url) { [weak self] result in
                    guard let self = self else { completion(nil); return }
                    
                    switch result {
                    case .success(let data):
                        if let data = data,
                            let image = UIImage(data: data)
                        {
                            // Загрузка удалась - для ускорения следующей загрузки сохраним её в кэш
                            self.setPhotoToCache(image: image, urlString: urlString, category: catrgory)
                            completion(image)
                        } else {
                            completion(nil)
                        }
                        
                        break
                    case .failure(_):
                        completion(nil)
                        break
                    }
                }
            }
        } else {
            completion(nil)
        }
    }
}
