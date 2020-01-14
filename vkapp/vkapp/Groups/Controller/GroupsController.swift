//
//  GroupsController.swift
//  VKApp
//
//  Created by Григорий Мартюшин on 24.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit
import RealmSwift

class GroupsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: Outlets
    @IBOutlet weak var btnLogout: UIBarButtonItem!
    
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
    
    // MARK: Properties
    // Список групп пользователя
    var groupsList = [Group]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    // Рекомендованные групп
    var recommendedGroups = [Group]()
    
    var token: NotificationToken?
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.title = NSLocalizedString("Groups", comment: "")
        btnLogout.title = NSLocalizedString("Logout", comment: "")
        btnLogout.tintColor = DefaultStyle.self.Colors.tint
        
        // Подписываемся на изменение данных
        subscribeToRealmChanges()
        
        // Загрузка информации о группах
        VK.shared.getGroupsList()
    }
    
    // MARK: Data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return groupsList.count
        } else {
            return recommendedGroups.count
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
            currentGroup = groupsList[indexPath.row]
        } else {
            currentGroup = recommendedGroups[indexPath.row]
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
                groupsList.remove(at: indexPath.row)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return NSLocalizedString("Your groups", comment: "")
        } else {
            if recommendedGroups.count > 0 {
                return NSLocalizedString("Recomended groups", comment: "")
            } else {
                return ""
            }
        }
    }
    
    // MARK: Table view delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if recommendedGroups.indices.contains(indexPath.row) {
                groupsList.append(recommendedGroups[indexPath.row])
                recommendedGroups.remove(at: indexPath.row)
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
    
    // MARK: Cestom methods
    fileprivate func subscribeToRealmChanges () {
        do {
            let groups = try RealmService.get(Group.self).sorted(byKeyPath: "name", ascending: true)
            
            // Подписываемся на изменения групп
            self.token = groups.observe { [weak self] (changes: RealmCollectionChange) in
                guard let self = self else { return }
                
                var localGroupsList = self.groupsList
                
                switch changes {
                case let .initial(result):
                    localGroupsList.removeAll()
                    
                    for item in result {
                        localGroupsList.append(item)
                    }
                    
                case let .update(res, del, ins, mod):
                    // Из базы пропала запись
                    if (del.count > 0) {
                        // Удаление из базы
                        for i in 0..<del.count {
                            if localGroupsList.indices.contains(del[i]) {
                                localGroupsList.remove(at: del[i])
                            }
                        }
                        
                    } else if ins.count > 0 {
                        // Добавление записи
                        for i in 0..<ins.count {
                            if res.indices.contains(ins[i]) {
                                localGroupsList.append(res[ins[i]])
                            }
                        }
                        
                    } else if mod.count > 0 {
                        // Запись обновилась
                        for i in 0..<mod.count {
                            if (localGroupsList.indices.contains(mod[i]) && res.indices.contains(mod[i])) {
                                // Проще удалить старую запись
                                localGroupsList.remove(at: mod[i])

                                // И добавить новую
                                localGroupsList.append(res[mod[i]])
                            }
                        }
                    }
                    
                case let .error(err):
                    self.showErrorMessage(message: err.localizedDescription)
                }
                
                // Обновляем данные
                self.groupsList.removeAll()
                self.groupsList = localGroupsList
            }
            
        } catch let err {
            showErrorMessage(message: err.localizedDescription)
        }
    }
}

// MARK: Search bar delegate
extension GroupsController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count >= 2 {
            // Покажем кнопку отмены
            searchBar.showsCancelButton = true
            
            // Загрузка информации о группах
            VK.shared.getGroupSearch(query: searchText) { result in
                switch result {
                case let .success(groups):
                    self.recommendedGroups = groups
                    self.tableView.reloadData()
                case .failure(_):
                    self.showErrorMessage(message: "Произошла ошибка загрузки данных")
                }
            }
        } else {
            if searchText.count == 0 {
                // Спрячем кнопку отмены
                searchBar.showsCancelButton = false
                
                recommendedGroups.removeAll()
            } else {
                // Покажем кнопку отмены
                searchBar.showsCancelButton = true
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

        // Спрячем кнопку отмены
        searchBar.showsCancelButton = false
        
        // Очищаем фильтрованный список
        recommendedGroups.removeAll()
        
        tableView.reloadData()
    }
}
