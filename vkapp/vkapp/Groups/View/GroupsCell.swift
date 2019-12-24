//
//  GroupsCell.swift
//  weather
//
//  Created by Григорий Мартюшин on 26.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class GroupsCell: UITableViewCell {
    @IBOutlet weak var lblGroupsName: UILabel!
    @IBOutlet weak var lblGroupsImage: AvatarView!

    override func prepareForReuse() {
        lblGroupsName.text = "..."
        lblGroupsImage.showImage(image: getNotFoundPhoto())
    }
    
    public func configure(with group: Group){
        // Название группы
        lblGroupsName.text = group.name
        
        //  Фотография может быть как UIImage так и строка
        if let image = group.imageString {
            lblGroupsImage.showImage(imageURL: image)
        } else {
            lblGroupsImage.showImage(image: getNotFoundPhoto())
        }
    }
}
