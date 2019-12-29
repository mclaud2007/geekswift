//
//  GroupsController.swift
//  weather
//
//  Created by Григорий Мартюшин on 24.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseAuth
import FirebaseDatabase

class GroupsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var GroupsList = [Group]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var RecommendedGroups = [Group]()
    
    var GroupsFiltered: [Group] = []
    
    var token: NotificationToken?
    
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
        
        do {
            let groups = try RealmService.get(Group.self).sorted(byKeyPath: "name", ascending: true)
            
            // Подписываемся на изменения групп
            self.token = groups.observe { [weak self] (changes: RealmCollectionChange) in
                guard let self = self else { return }
                
                var localGroupsList = self.GroupsList
                
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
                self.GroupsList.removeAll()
                self.GroupsList = localGroupsList
            }
            
        } catch let err {
            showErrorMessage(message: err.localizedDescription)
        }
        
        // Загрузка информации о группах
        VK.shared.getGroupsList()
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
                
                // Записываем группу в Firebase
                if let uid = Auth.auth().currentUser?.uid {
                    let gid = UUID.init().uuidString
                    let ref = Database.database().reference(withPath: "db/group-\(gid)")
                    ref.setValue(["userId": uid, "groupName": RecommendedGroups[indexPath.row].name])
                }
                
                
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
