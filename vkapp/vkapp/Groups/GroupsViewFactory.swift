//
//  GroupsViewFactory.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 05.03.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import Foundation

class GroupsViewFactory {
    public func constructViews (from groups: [Group]) -> [GroupViewModel] {
        return groups.compactMap(self.viewModel)
    }
    
    private func viewModel(from group: Group) -> GroupViewModel {
        return GroupViewModel(name: group.name, image: group.imageString ?? getNotFoundPhoto())
    }
}
