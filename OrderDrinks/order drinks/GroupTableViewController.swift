//
//  GroupTableViewController.swift
//  OrderDrinks
//
//  Created by Shien on 2022/6/12.
//

import UIKit
class GroupTableViewController: UITableViewController {
    var drinks: NewDrinks?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return drinks?.records.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? GroupTableViewCell else { return GroupTableViewCell() }
        
        if let drinks = drinks {
            let theDrink = drinks.records[indexPath.row].fields
            cell.drinkNameLabel.text = theDrink.drink!
            fetchImage(url: theDrink.image[0]?.url) { image in
                DispatchQueue.main.async {
                    if let image = image {
                        cell.drinkImageView.image = image
                    }
                }
            }
            cell.sugarLabel.text = "甜度 \(theDrink.sugar!)"
            cell.iceLabel.text = "冰塊 \(theDrink.ice!)"
            cell.sizeLabel.text = theDrink.size!
            cell.countsLabel.text = "\(theDrink.counts!) 杯"
            if theDrink.pearls == true {
                cell.toppingsLabels[0].isHidden = false
            }
            if theDrink.honey == true {
                cell.toppingsLabels[1].isHidden = false
            }
            if theDrink.grass_jelly == true {
                cell.toppingsLabels[2].isHidden = false
            }
            cell.personNameLabel.text = theDrink.name!
        }
        
        return cell
    }

}
