//
//  GroupsController.swift
//  weather
//
//  Created by Григорий Мартюшин on 24.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class GroupsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var GroupsList = [Groups(name: "80-е", image: UIImage(named: "eighties")),
                      Groups(name: "90-е", image: UIImage(named: "nineties")),
                      Groups(name: "2000-2010")
    ]
    
    var GroupsFiltered: [Groups] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.title = "Группы"
        
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.topItem?.title = "Группы"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if GroupsFiltered.count > 0 {
            return GroupsFiltered.count
        }
        
        return GroupsList.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupsCell", for: indexPath) as? GroupsCell else {
            preconditionFailure("Error")
        }
        
        var currentGroup = GroupsList[indexPath.row]
        
        if GroupsFiltered.count > 0 {
            currentGroup = GroupsFiltered[indexPath.row]
        }

        // Configure the cell...
        cell.lblGroupsName.text = currentGroup.name
        
        if currentGroup.image != nil {
            cell.lblGroupsImage.image = currentGroup.image
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
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            GroupsList.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension GroupsController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Очищаем фильтрованный список
        GroupsFiltered.removeAll()
        
        if searchText.count >= 2 {
            for Group in GroupsList {
                if Group.name.contains(searchText) {
                    GroupsFiltered.append(Group)
                }
            }
        }
        
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.searchTextField.text {
            if searchText.count < 2 {
                show(message: "Для поиска необходимо минимум два символа")
            }
        }
        
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.searchTextField.text = ""
        searchBar.endEditing(true)
        
        // Очищаем фильтрованный список
        GroupsFiltered.removeAll()
        tableView.reloadData()
    }
}
