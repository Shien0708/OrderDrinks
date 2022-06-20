//
//  MenuCollectionViewCell.swift
//  OrderDrinks
//
//  Created by Shien on 2022/6/10.
//

import UIKit

class MenuCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var drinkButton: UIButton!
    @IBOutlet weak var drinksImageView: UIImageView!
    @IBOutlet var infoImageViews: [UIImageView]!
    @IBOutlet weak var chNameLabel: UILabel!
    @IBOutlet weak var enNameLabel: UILabel!
}
