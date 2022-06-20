//
//  MyGroupsTableViewCell.swift
//  OrderDrinks
//
//  Created by Shien on 2022/6/16.
//

import UIKit

class MyGroupsTableViewCell: UITableViewCell {
    @IBOutlet weak var drinksCountsLabel: UILabel!
    @IBOutlet weak var gruopNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
