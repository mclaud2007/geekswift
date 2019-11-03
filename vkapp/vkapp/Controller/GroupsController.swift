//
//  GroupsController.swift
//  weather
//
//  Created by Григорий Мартюшин on 24.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class GroupsController: UITableViewController {
    
    var GroupsList = [Groups(name: "80-е", image: UIImage(named: "eighties")),
                      Groups(name: "90-е", image: UIImage(named: "nineties")),
                      Groups(name: "2000-2010")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.title = "Группы"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.topItem?.title = "Группы"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GroupsList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupsCell", for: indexPath) as? GroupsCell else {
            preconditionFailure("Error")
        }

        // Configure the cell...
        cell.lblGroupsName.text = GroupsList[indexPath.row].name
        
        if GroupsList[indexPath.row].image != nil {
            cell.lblGroupsImage.image = GroupsList[indexPath.row].image
        } else {
            cell.lblGroupsImage.image = UIImage(named: "photonotfound")
        }
        
        return cell
    }
    
    @IBAction func addGroupClick(segue: UIStoryboardSegue){
        if segue.identifier == "addGroups" {
            // Отсюда возмем название группы для добавления
            let AllGroupsController = segue.source as! AllGroupsController
            
            if let indexPath = AllGroupsController.tableView.indexPathForSelectedRow {
                let GroupToAdd = AllGroupsController.GroupsListArray[indexPath.row]
                
                if GroupsList.contains(where: { $0.name == GroupToAdd.name }) == false {
                    GroupsList.append(GroupToAdd)
                    tableView.reloadData()
                }
                
            }
            
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            GroupsList.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

}
