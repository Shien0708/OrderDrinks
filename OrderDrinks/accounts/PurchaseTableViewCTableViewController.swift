//
//  PurchaseTableViewCTableViewController.swift
//  OrderDrinks
//
//  Created by Shien on 2022/6/16.
//

import UIKit

class PurchaseTableViewCTableViewController: UITableViewController {
    var drinks: NewDrinks?
    var storeInfos: StoreInfo?
    var orderedDrinks: [NewDrinks.NewDrinksRecord]?
    var loadingView = UIActivityIndicatorView()
    
    @IBOutlet weak var phoneTextView: UITextView!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var storeButton: UIButton!
    @IBOutlet weak var ordersTextView: UITextView!
    @IBOutlet weak var totalCountsLabel: UILabel!
    @IBOutlet weak var groupNameLabel: UILabel!
    var totalCounts = 0
    var totalPrice = 0
    @IBOutlet weak var totalPriceLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoadingView()
        fetchStoreInfo()
    }
    
    func showLoadingView() {
        loadingView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        loadingView.backgroundColor = UIColor(red: 246/255, green: 244/255, blue: 229/255, alpha: 1)
        loadingView.isHidden = false
        tableView.addSubview(loadingView)
        loadingView.startAnimating()
    }
    
    func setStoreButton() {
        var actions = [UIAction]()
        storeButton.showsMenuAsPrimaryAction = true
        if let stores = storeInfos?.records {
            for store in stores {
                actions.append(UIAction(title:store.fields.name ,handler: { action in
                    self.storeButton.setTitle(store.fields.name, for: .normal)
                    self.addressLabel.text = store.fields.address
                    self.phoneButton.setTitle(store.fields.phone, for: .normal)
                    self.phoneTextView.text = store.fields.phone
                }))
            }
        }
        storeButton.menu = UIMenu(children: actions)
    }
    
    func fetchStoreInfo() {
        let url = URL(string: "https://api.airtable.com/v0/appAOaBqqqP4M4yMS/Table%201")!
        var request = URLRequest(url: url)
        request.setValue("Bearer key9YLmddN4gQwWdP", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let results = try decoder.decode(StoreInfo.self, from: data)
                    DispatchQueue.main.async {
                        self.storeInfos = results
                        self.setStoreButton()
                        self.updateUI()
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
    }

    // MARK: - Table view data source
    func updateUI() {
        if let storeInfos = storeInfos {
            storeButton.setTitle(storeInfos.records[0].fields.name, for: .normal)
            addressLabel.text = storeInfos.records[0].fields.address
            phoneButton.setTitle(storeInfos.records[0].fields.phone, for: .normal)
            phoneTextView.text = storeInfos.records[0].fields.phone
        }
        if let allDrinks = orderedDrinks {
            for drink in allDrinks {
                groupNameLabel.text = drink.fields.group!
                totalCounts += drink.fields.counts!
                totalPrice += drink.fields.total_price!
                ordersTextView.text += "\(drink.fields.counts!) 杯 \(drink.fields.drink!) \(drink.fields.ice!)\(drink.fields.sugar!)"
                if drink.fields.pearls == true {
                    ordersTextView.text += " 加珍珠"
                }
                if drink.fields.honey == true {
                    ordersTextView.text += " 加蜂蜜"
                }
                if drink.fields.grass_jelly == true {
                    ordersTextView.text += " 加仙草"
                }
                ordersTextView.text += "\n\n"
            }
            totalCountsLabel.text = "\(totalCounts)"
            totalPriceLabel.text = "\(totalPrice)"
        }
        loadingView.isHidden = true
        loadingView.stopAnimating()
    }

   
}
