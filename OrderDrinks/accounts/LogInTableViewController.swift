//
//  LogInTableViewController.swift
//  OrderDrinks
//
//  Created by Shien on 2022/6/14.
//

import UIKit

class LogInTableViewController: UITableViewController {
    var loadingView = UIActivityIndicatorView()
    var allAccounts: [Accounts.AccountsRecord]?
    var isCorrect = false
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAccounts()
        fetchTotalCounts()
        fetchAllGroups()
    }
    
    func showLoadingView() {
        loadingView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        loadingView.isHidden = false
        tableView.addSubview(loadingView)
    }
    
    //得到所有團購群組
    func fetchAllGroups() {
        let url = URL(string: "https://api.airtable.com/v0/appZTYancUlU6PvfX/Table%201")!
        var request = URLRequest(url: url)
        request.setValue("Bearer key9YLmddN4gQwWdP", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let results = try decoder.decode(NewDrinks.self, from: data)
                    for drink in results.records {
                        if let group = drink.fields.group {
                            if !allGroups.contains(group) {
                                allGroups.append(group)
                            }
                        }
                    }
                    print("has \(allGroups) groups")
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    //得到最新一筆客人的順位
    func fetchTotalCounts() {
        let url = URL(string: "https://api.airtable.com/v0/appZTYancUlU6PvfX/Table%201")!
        var request = URLRequest(url: url)
        request.setValue("Bearer key9YLmddN4gQwWdP", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let lists = try decoder.decode(NewDrinks.self, from: data)
                    var priority = 0
                    for drink in lists.records {
                        if drink.fields.priority > priority {
                            priority = drink.fields.priority
                        }
                    }
                    totalCustomers = priority
                    print(lists)
                    print(totalCustomers)
                } catch {
                    print("fetch total count \(error)")
                }
            }
        }.resume()
    }
    
    //取得現有的全部帳號
    func fetchAccounts() {
        let url = URL(string: "https://api.airtable.com/v0/appCOrvZxvwNyd3LT/Table%201?")!
        var request = URLRequest(url: url)
        request.setValue("Bearer key9YLmddN4gQwWdP", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { [self] data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let results = try decoder.decode(Accounts.self, from: data)
                    allAccounts = results.records
                    DispatchQueue.main.async {
                        if let allAccounts = allAccounts {
                            self.checkAccounts(accounts: allAccounts)
                        }
                    }
                } catch {
                    print("fetch account \(error)")
                }
                
            }
        }.resume()
    }
    
    
    func checkAccounts(accounts: [Accounts.AccountsRecord]) {
        isCorrect = false
        if accountTextField.text?.isEmpty == false && passwordTextField.text?.isEmpty == false {
            var index = 0
            while  isCorrect == false && accounts.count-1 >= index {
                if accountTextField.text! == accounts[index].fields.account && passwordTextField.text! == accounts[index].fields.password {
                    isCorrect = true
                    currentAccounts = (accountTextField.text!, passwordTextField.text!)
                }
                index += 1
            }
            if isCorrect {
                performSegue(withIdentifier: "logIn", sender: nil)
            } else {
                let alert = UIAlertController(title: "帳密有誤", message: "請再輸入一次", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                present(alert, animated: true)
                accountTextField.text = ""
                passwordTextField.text = ""
            }
            loadingView.isHidden = true
        }
        loadingView.isHidden = true
    }
    
    
    @IBAction func logIn(_ sender: Any) {
        showLoadingView()
        view.endEditing(true)
        fetchAccounts()
    }
    
    @IBSegueAction func showSignUpPage(_ coder: NSCoder) -> SignUpViewController? {
        let controller = SignUpViewController(coder: coder)
        if let allAccounts = allAccounts {
            controller?.allAccounts = allAccounts
        }
        return controller
    }
    
    // MARK: - Table view data source

    @IBAction func signUp(_ segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func logOut(_ segue: UIStoryboardSegue) {
        accountTextField.text = ""
        passwordTextField.text = ""
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
    }
    
}
