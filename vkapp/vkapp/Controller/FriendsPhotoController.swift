//
//  FriendsPhotoController.swift
//  weather
//
//  Created by Григорий Мартюшин on 25.10.2019.
//  Copyright © 2019 Григорий Мартюшин. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class FriendsPhotoController: UICollectionViewController {
    var PhotosLists = [UIImage(named: "photonotfound")]

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PhotosLists.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotosCell", for: indexPath) as? PhotosCell else {
            preconditionFailure("Error")
        }
    
        // Configure the cell
        if (PhotosLists[indexPath.row] != nil){
            cell.FriendsPhotoImageView.image = PhotosLists[indexPath.row]
        } else {
            cell.FriendsPhotoImageView.image = UIImage(named: "photonotfound")
        }
        
        return cell
    }
}
