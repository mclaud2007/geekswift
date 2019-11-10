//
//  NewsFormController.swift
//  weather
//
//  Created by Григорий Мартюшин on 09.11.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit



class NewsFormController: UIViewController {
    let NewsList = [
                    News(title: "Сервис Apple TV+ уже доступен",
                         content: "Сервис Apple TV+ доступен в приложении Apple TV по подписке за 199 рублей в месяц или бесплатно при покупке нового устройства Apple либо при подписке на тарифный план Apple Music для студентов",
                         date: "1.11.2019",
                         picture: UIImage(named: "first_news")!,
                         likes: 10, views: 255, comments: 5, shared: 30,
                         isLiked: false, avatar: UIImage(named: "arnold")!),
                    News(title: "Состоялась премьера сериала Apple",
                    content: "Роли в новом сериале исполнили Дженнифер Энистон, Риз Уизерспун, Стив Карелл, Билли Крудап, Марк Дюпласс, Гугу Мбата-Роу, Нестор Карбонелл, Бел Паули, Карен Питтман, ДеШон К. Терри и Джанина Гаванкар.",
                    date: "3.11.2019",
                    picture: UIImage(named: "second_news")!,
                    likes: 5, views: 12, comments: 51, shared: 3,
                    isLiked: true, avatar: UIImage(named: "bruce")!)
    ]

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Регистрируем xib в качестве прототипа ячейки
        tableView.register(UINib(nibName: "NewsTableCell", bundle: nil), forCellReuseIdentifier: "NewsTableCell")
        
        self.title = "Новости"
    }
}

extension NewsFormController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NewsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableCell", for: indexPath) as! NewsTableCell
    
        let NewsCell: News = NewsList[indexPath.row]
        
        cell.lblNewsTitle.text = NewsCell.title
        cell.lblNewsDate.text = NewsCell.date
        cell.lblNewsContent.text = NewsCell.content
        cell.lblShare.text = String(NewsCell.shared!)
        cell.lblViews.text = String(NewsCell.views!)
        cell.lblComments.text = String(NewsCell.comments!)
        cell.lblLikeControl.initLikes(likes: NewsCell.likes!, isLiked: NewsCell.isLiked!)
        cell.imgNewsPicture.image = NewsCell.picture
        cell.imgAvatarView.showImage(image: NewsCell.avatar!)
        
        return cell
    }
}
