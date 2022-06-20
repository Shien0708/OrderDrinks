//
//  GroupTableViewCell.swift
//  OrderDrinks
//
//  Created by Shien on 2022/6/13.
//

import UIKit

class GroupTableViewCell: UITableViewCell {

    @IBOutlet weak var drinkNameLabel: UILabel!
    @IBOutlet weak var drinkImageView: UIImageView!
    @IBOutlet weak var personNameLabel: UILabel!
    @IBOutlet var toppingsLabels: [UILabel]!
    @IBOutlet weak var iceLabel: UILabel!
    @IBOutlet weak var sugarLabel: UILabel!
    @IBOutlet weak var countsLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
