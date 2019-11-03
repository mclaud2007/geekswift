//
//  AllGroupsController.swift
//  weather
//
//  Created by Григорий Мартюшин on 26.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class AllGroupsController: UITableViewController {
    
    let GroupsListArray = [Groups(name: "2010-2015"), Groups(name: "2015-2019")]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Добавить группу"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return GroupsListArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AllGroupCell", for: indexPath) as? AllGroupCell else {
            preconditionFailure("Error")
        }

        // Configure the cell...
        cell.lblAllGroupName.text = GroupsListArray[indexPath.row].name
        
        return cell
    }
}
