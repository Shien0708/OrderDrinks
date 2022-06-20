//
//  MyGroupTableViewController.swift
//  OrderDrinks
//
//  Created by Shien on 2022/6/16.
//

import UIKit

class MyGroupTableViewController: UITableViewController {
    var myGroups = [String]()
    var drinksOfGroups = [(String,NewDrinks.NewDrinksRecord)]()
    var loadingView = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAllGroups()
    }
    
    func showLoadingView() {
        loadingView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        loadingView.startAnimating()
        loadingView.isHidden = false
        tableView.addSubview(loadingView)
    }
    
    func fetchAllGroups() {
        showLoadingView()
        let url = URL(string: "https://api.airtable.com/v0/appZTYancUlU6PvfX/Table%201")!
        var request = URLRequest(url: url)
        request.setValue("Bearer key9YLmddN4gQwWdP", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let results = try decoder.decode(NewDrinks.self, from: data)
                    self.myGroups.removeAll()
                    self.drinksOfGroups.removeAll()
                    for drink in results.records {
                        if let group = drink.fields.group, drink.fields.account_name == currentAccounts.0 {
                            if !self.myGroups.contains(group) {
                                self.myGroups.append(group)
                                for drink in results.records {
                                    if drink.fields.group == group {
                                        self.drinksOfGroups.append((group, drink))
                                    }
                                }
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.loadingView.isHidden = false
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
        return myGroups.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MyGroupsTableViewCell else { return MyGroupsTableViewCell() }

        cell.gruopNameLabel.text = "群組名稱：\(myGroups[indexPath.row])"
        var counts = 0
        for drink in drinksOfGroups {
            if drink.0 == myGroups[indexPath.row] {
                counts += 1
            }
        }
        cell.drinksCountsLabel.text = "\(counts) 個訂單"
        
        // Configure the cell...

        return cell
    }
    
    @IBSegueAction func showDrinksOfGroup(_ coder: NSCoder) -> TheGroupTableViewController? {
        let controller = TheGroupTableViewController(coder: coder)
        for drink in drinksOfGroups {
            if drink.0 == myGroups[tableView.indexPathForSelectedRow!.row] {
                controller?.theDrinks.append(drink.1)
            }
        }
        controller?.groupName = myGroups[tableView.indexPathForSelectedRow!.row]
        return controller
    }
    
}
