//
//  GroupsListController.swift
//  vkapp
//
//  Created by Григорий Мартюшин on 04.05.2020.
//  Copyright © 2020 Григорий Мартюшин. All rights reserved.
//

import UIKit

class GroupsListController: UIViewController {
    // MARK: Properties
    var groupListView: GroupListView {
        return view as! GroupListView
    }
    
    var tableView: UITableView!
    var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    
    var groupList = [Group]()
    var recomendedGroupList = [Group]()
    
    // MARK: Lifecycle
    override func loadView() {
        super.loadView()
        self.view = GroupListView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Style.groupScreen.background
        self.title = NSLocalizedString("Groups", comment: "")
        
        // Инициализируем таблицу
        tableView = groupListView.tableView
        tableView.delegate = self
        tableView.dataSource = self
        
        // Регистрируем класс ячейки
        tableView.register(GroupListCell.self, forCellReuseIdentifier: "groupListCell")
        searchBar = groupListView.serachController.searchBar
        
        // Загружаем список групп пользователя
        VKService.shared.getGroupList { [weak self] response in
            guard let self = self else { return }
            
            switch response {
            case .success(let groups):
                self.groupList = groups
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                break
                
            case .failure(_):
                DispatchQueue.main.async {
                    self.showErrorMessage(message: NSLocalizedString("Something went wrong", comment: ""))
                }
                
                break
            }
        }
        
        // TODO: Кнопка выхода      
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Logout", comment: ""), style: .plain, target: self, action: #selector(logout(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3"), style: .plain, target: self, action: #selector(toggleMenu(_:)))
    }

    @objc func logout(_ sender: UIBarButtonItem) {
        AppManager.shared.logout()
    }
    
    @objc func toggleMenu(_ sender: UIBarButtonItem) {
        AppManager.shared.toggleMenu()
    }
}

extension GroupsListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Выбрать группу из списка пользователя нельзя
        if (tableView.numberOfSections == 1 || indexPath.section == 1) {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        } else {
            // Перемещаем группу из рекомендованного списка в список групп пользователя
            let recomendedGroup = recomendedGroupList[indexPath.row]
            recomendedGroupList.remove(at: indexPath.row)
            groupList.append(recomendedGroup)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return ((tableView.numberOfSections > 1 && indexPath.section == 1) || (tableView.numberOfSections == 1 && indexPath.section == 0))
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            groupList.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
}

extension GroupsListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // Заголовок для секций ставим только когда есть секция с рекомендациями
        if tableView.numberOfSections > 1 {
            return (section == 0 ? NSLocalizedString("Recomended groups", comment: "") : NSLocalizedString("Your groups", comment: ""))
        }
        
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Если есть рекомендованные группы значит надо создать еще одну секцию
        return recomendedGroupList.count > 0 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.numberOfSections > 1 {
            return (section == 0 ? recomendedGroupList.count : groupList.count)
        } else {
            return groupList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "groupListCell") as? GroupListCell else {
            preconditionFailure("Error")
        }
        
        // Настраиваем ячейку
        if (tableView.numberOfSections == 1 || indexPath.section == 1) {
            cell.configureFrom(group: groupList[indexPath.row])
        } else {
            cell.configureFrom(group: recomendedGroupList[indexPath.row])
        }
        
        return cell
    }
}

extension GroupsListController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            VKService.shared.getGroupListBy(query: searchText) { [weak self] result in
                guard let self = self else { return }

                // Перед поиском удаляем все рекомендованные группы
                self.recomendedGroupList.removeAll()
                
                switch result {
                case .success(let groups):
                    self.recomendedGroupList = groups
                    break
                case .failure(_):
                    break
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        } else {
            recomendedGroupList.removeAll()
            tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        recomendedGroupList.removeAll()
        tableView.reloadData()
    }
}

extension GroupsListController: TabBarScrollToTop {
    func doScroll() {
        tableView.setContentOffset(.zero, animated: true)
    }
}
