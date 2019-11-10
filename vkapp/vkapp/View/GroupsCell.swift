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
    @IBOutlet weak var lblGroupsImage: UIImageView!

    override func prepareForReuse() {
        lblGroupsName.text = "..."
        lblGroupsImage.image = UIImage(named: "photonotfound")
    }
}
