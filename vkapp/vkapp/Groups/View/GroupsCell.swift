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
    
    private let imageAvatarWidth: CGFloat = 50
    private let imageAvatarInsets: CGFloat = 10
    private let groupNameInsets: CGFloat = 20
    
    private func getLabelSize(text: String, font: UIFont) -> CGSize {
        let maxWidth = contentView.bounds.width - (imageAvatarWidth + imageAvatarInsets + groupNameInsets)
        let textBlock = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let rect = text.boundingRect(with: textBlock, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        let width = rect.width.rounded(.up)
        let height = rect.height.rounded(.up)
        
        return CGSize(width: width, height: height)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let lblGroupsImageTop = (bounds.height/2).rounded(.up) - (imageAvatarWidth/2).rounded(.up)
        lblGroupsImage.frame = CGRect(x: imageAvatarInsets,
                                      y: lblGroupsImageTop,
                                      width: imageAvatarWidth,
                                      height: imageAvatarWidth)
        
        let groupNameSize = getLabelSize(text: lblGroupsName.text ?? "...", font: lblGroupsName.font)
        let lblGroupsNameTop = (bounds.height/2).rounded(.up) - (groupNameSize.height / 2).rounded(.up)
        
        // Выставляем фрейм названию группы
        lblGroupsName.frame = CGRect(x: (imageAvatarWidth + imageAvatarInsets + groupNameInsets),
                                     y: lblGroupsNameTop,
                                     width: groupNameSize.width,
                                     height: groupNameSize.height)
    }

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
        
        // Нужно перерисовать лайоут
        setNeedsLayout()
    }
}
