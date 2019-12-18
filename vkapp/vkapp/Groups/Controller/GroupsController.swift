//
//  GroupsController.swift
//  weather
//
//  Created by Григорий Мартюшин on 24.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

class GroupsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var GroupsList = [Group]()
    
    var RecommendedGroups = [Group]()
    
    var GroupsFiltered: [Group] = []
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.title = "Группы"
        
        // Загрузка информации о группах
        VK.shared.getGroupsList() { result in
            switch result {
            case let .success(groups):
                self.GroupsList = groups
                self.tableView.reloadData()
            case .failure(_):
                self.showErrorMessage(message: "Произошла ошибка загрузки данных")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.topItem?.title = "Группы"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            if GroupsFiltered.count > 0 {
                return GroupsFiltered.count
            }
            
            return GroupsList.count
        } else {
            return RecommendedGroups.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupsCell", for: indexPath) as? GroupsCell else {
            preconditionFailure("Error")
        }
        
        var currentGroup: Group
        
        if indexPath.section == 1 {
            if GroupsFiltered.count > 0 {
                currentGroup = GroupsFiltered[indexPath.row]
            } else {
                currentGroup = GroupsList[indexPath.row]
            }
        } else {
            currentGroup = RecommendedGroups[indexPath.row]
        }

        // Configure the cell...
        cell.configure(with: currentGroup)
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 {
            return true
        } else {
            return false
        }
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == 0 {
                return 
            } else {
                GroupsList.remove(at: indexPath.row)
                // Delete the row from the data source
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Ваши группы"
        } else {
            if RecommendedGroups.count > 0 {
                return "Рекомендованные группы"
            } else {
                return ""
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if RecommendedGroups.count >= indexPath.row {
                GroupsList.append(RecommendedGroups[indexPath.row])
                RecommendedGroups.remove(at: indexPath.row)
                tableView.reloadData()
            } else {
                tableView.deselectRow(at: indexPath, animated: false)
                return
            }
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
            return
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
            
            // Загрузка информации о группах
            VK.shared.getGroupSearch(query: searchText) { result in
                switch result {
                case let .success(groups):
                    self.RecommendedGroups = groups
                    self.tableView.reloadData()
                case .failure(_):
                    self.showErrorMessage(message: "Произошла ошибка загрузки данных")
                }
            }
        } else {
            if searchText.count == 0 {
                RecommendedGroups.removeAll()
            }
        }
        
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.searchTextField.text {
            if searchText.count < 2 {
                showErrorMessage(message: "Для поиска необходимо минимум два символа")
            }
        }
        
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.searchTextField.text = ""
        searchBar.endEditing(true)
        
        // Очищаем фильтрованный список
        GroupsFiltered.removeAll()
        RecommendedGroups.removeAll()
        
        tableView.reloadData()
    }
}
