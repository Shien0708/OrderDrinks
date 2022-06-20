//
//  MyDrinksListsTableViewController.swift
//  OrderDrinks
//
//  Created by Shien on 2022/6/14.
//

import UIKit
class MyDrinksListsTableViewController: UITableViewController {
    var allDrinks = [NewDrinks.NewDrinksRecord]()
    var myDrinks = [NewDrinks.NewDrinksRecord]()
    var listRefreshControl: UIRefreshControl?
    var drinks: NewDrinks?
    var selectedButtonIndex = 0
    var drinkID = ""
    var loadingView = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoadingView()
        fetchMyDrinks()
        listRefreshControl = UIRefreshControl()
        tableView.addSubview(listRefreshControl!)
        listRefreshControl?.addTarget(self, action: #selector(refetch), for: .valueChanged)
    }
    
    func showLoadingView() {
        loadingView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        loadingView.backgroundColor = UIColor(red: 246/255, green: 244/255, blue: 229/255, alpha: 1)
        loadingView.isHidden = false
        tableView.addSubview(loadingView)
    }
    
    func filterMyDrinks(drinks: [NewDrinks.NewDrinksRecord]) {
        for drink in allDrinks {
            if drink.fields.account_name == currentAccounts.0 {
                myDrinks.append(drink)
            }
        }
        print(myDrinks)
    }
    
    @objc func refetch() {
        fetchMyDrinks()
        _ = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { _ in
            self.listRefreshControl?.endRefreshing()
        })
    }
    
    func fetchMyDrinks() {
        showLoadingView()
        myDrinks.removeAll()
        let url = URL(string: "https://api.airtable.com/v0/appZTYancUlU6PvfX/Table%201")
        var request = URLRequest(url: url!)
        request.setValue("Bearer key9YLmddN4gQwWdP", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let results = try decoder.decode(NewDrinks.self, from: data)
                    self.drinks = results
                    self.allDrinks = results.records
                    self.filterMyDrinks(drinks: self.allDrinks)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.loadingView.isHidden = true
                    }
                } catch {
                    print("fetch my drink \(error)")
                }
            }
        }.resume()
    }
    
    
    @IBSegueAction func showEditor(_ coder: NSCoder) -> EditTableViewController? {
        let controller = EditTableViewController(coder: coder)
        controller?.drink = myDrinks[tableView.indexPathForSelectedRow!.row].fields
        menuIndices = ((controller!.drink!.type_index)!, (controller!.drink!.item_index)!)
        return controller
    }
    
    @IBAction func finishEditing(_ segue: UIStoryboardSegue) {
        showLoadingView()
        _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { _ in
            self.fetchMyDrinks()
        })
    }
    
    //show group of the drink
    
    @IBAction func pressToShowGroup(_ sender: UIButton) {
        if myDrinks[Int((sender.titleLabel?.text!)!)!].fields.group != nil {
            selectedButtonIndex = Int((sender.titleLabel?.text!)!)!
            performSegue(withIdentifier: "showTheGroup", sender: nil)
        } else {
            let alert = UIAlertController(title: "這杯飲料沒有加入任何群組", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    
    @IBSegueAction func showGroupOfDrinks(_ coder: NSCoder) -> TheGroupTableViewController? {
        let controller = TheGroupTableViewController(coder: coder)
        
        controller?.groupName = myDrinks[selectedButtonIndex].fields.group!
        controller?.drinks = drinks!
        return controller
    }
    
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return myDrinks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MyDrinksListsTableViewCell else {
            return MyDrinksListsTableViewCell()
        }
        if myDrinks.count > 0 {
            let drink = myDrinks[indexPath.row].fields
            cell.drinksNameLabel.text = drink.drink!
            cell.countsLabel.text = "\(drink.counts!) 杯"
            cell.sizeLabel.text = drink.size!
            cell.sugarLabel.text = "甜度: \(drink.sugar!)"
            cell.iceLabel.text = "冰塊: \(drink.ice!)"
            if drink.pearls == true {
                cell.toppingsLabels[0].isHidden = false
            } else {
                cell.toppingsLabels[0].isHidden = true
            }
            if drink.honey == true {
                cell.toppingsLabels[1].isHidden = false
            } else {
                cell.toppingsLabels[1].isHidden = true
            }
            if drink.grass_jelly == true {
                cell.toppingsLabels[2].isHidden = false
            } else {
                cell.toppingsLabels[2].isHidden = true
            }
            
            if let url = myDrinks[indexPath.row].fields.image[0]?.url {
                fetchImage(url: url) { image in
                    DispatchQueue.main.async {
                        cell.drinksImageView.image = image
                    }
                }
            }
            cell.groupButton.setTitle("\(indexPath.row)", for: .normal)
        }
        return cell
    }
    
    // delete drinks
    func fetchIDAndDelete(priority: Int) {
        if let url = URL(string: "https://api.airtable.com/v0/appZTYancUlU6PvfX/Table%201") {
            var request = URLRequest(url: url)
            request.setValue("Bearer key9YLmddN4gQwWdP", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: request) { [self] data, response, error in
                if let data = data {
                    let decoder = JSONDecoder()
                    do {
                        let results = try decoder.decode(UpdateDrinks.self, from: data)
                        var index = 0
                        while priority != results.records[index].fields.priority {
                            index += 1
                        }
                        drinkID = results.records[index].id
                        deleteDrink(id: drinkID)
                    } catch {
                        print("fetch id \(error)")
                    }
                }
            }.resume()
        }
    }
    
    
    func deleteDrink(id: String) {
        let url = URL(string: "https://api.airtable.com/v0/appZTYancUlU6PvfX/Table%201/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "delete"
        request.setValue("Bearer key9YLmddN4gQwWdP", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse {
                print("delete drinks \(response.statusCode)")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }.resume()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let priority = myDrinks[indexPath.row].fields.priority
        myDrinks.remove(at: indexPath.row)
        fetchIDAndDelete(priority: priority)
    }
}
