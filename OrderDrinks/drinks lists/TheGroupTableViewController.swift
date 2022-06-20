//
//  TheGroupTableViewController.swift
//  OrderDrinks
//
//  Created by Shien on 2022/6/15.
//

import UIKit

class TheGroupTableViewController: UITableViewController {
    var drinks: NewDrinks?
    var drink: NewDrinks.NewDrinksRecord?
    var theDrinks = [NewDrinks.NewDrinksRecord]()
    var groupName = ""
    var loadingView = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoadingView()
        fetchTheGroup()
    }
    
    func showLoadingView() {
        loadingView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        loadingView.backgroundColor = UIColor(red: 246/255, green: 244/255, blue: 229/255, alpha: 1)
        loadingView.isHidden = false
        tableView.addSubview(loadingView)
        loadingView.startAnimating()
    }
    
    func fetchTheGroup() {
        let url = URL(string: "https://api.airtable.com/v0/appZTYancUlU6PvfX/Table%201")!
        var request = URLRequest(url: url)
        request.httpMethod = "get"
        request.setValue("Bearer key9YLmddN4gQwWdP", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { [self] data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let lists = try decoder.decode(NewDrinks.self, from: data)
                    self.drinks = lists
                    if self.theDrinks.isEmpty {
                        for drink in self.drinks!.records {
                            if let group = drink.fields.group, group == groupName {
                                self.theDrinks.append(drink)
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.navigationItem.title = self.groupName
                        self.loadingView.isHidden = true
                        self.loadingView.stopAnimating()
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return theDrinks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TheGroupTableViewCell else { return TheGroupTableViewCell() }
        
        if !theDrinks.isEmpty {
            let theDrink = theDrinks[indexPath.row].fields
            cell.drinkNameLabel.text = theDrink.drink!
            fetchImage(url: theDrink.image[0]?.url) { image in
                DispatchQueue.main.async {
                    if let image = image {
                        cell.drinkImageView.image = image
                       
                    }
                }
            }
            cell.totalPriceLabel.text = "\(theDrink.total_price!)"
            cell.sugarLabel.text = "甜度: \(theDrink.sugar!)"
            cell.iceLabel.text = "冰塊: \(theDrink.ice!)"
            cell.sizeLabel.text = theDrink.size!
            cell.countLabel.text = "\(theDrink.counts!) 杯"
            if theDrink.pearls == true {
                cell.toppingsLabels[0].isHidden = false
            }
            if theDrink.honey == true {
                cell.toppingsLabels[1].isHidden = false
            }
            if theDrink.grass_jelly == true {
                cell.toppingsLabels[2].isHidden = false
            }
            cell.nameLabel.text = theDrink.name!
        }
        return cell
    }
    
    @IBSegueAction func purchase(_ coder: NSCoder) -> PurchaseTableViewCTableViewController? {
        let controller = PurchaseTableViewCTableViewController(coder: coder)
        if let drinks = drinks {
            controller?.drinks = drinks
        }
        
        controller?.orderedDrinks = theDrinks
        return controller
    }
    
    
    
}
