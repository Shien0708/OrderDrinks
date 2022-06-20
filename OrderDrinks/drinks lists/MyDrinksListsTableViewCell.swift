//
//  MyDrinksListsTableViewCell.swift
//  OrderDrinks
//
//  Created by Shien on 2022/6/14.
//

import UIKit

class MyDrinksListsTableViewCell: UITableViewCell {
    @IBOutlet weak var drinksImageView: UIImageView!
    @IBOutlet weak var drinksNameLabel: UILabel!
    
    @IBOutlet weak var countsLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var sugarLabel: UILabel!
    
    @IBOutlet weak var iceLabel: UILabel!
    
    @IBOutlet var toppingsLabels: [UILabel]!
    
    @IBOutlet weak var groupButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
