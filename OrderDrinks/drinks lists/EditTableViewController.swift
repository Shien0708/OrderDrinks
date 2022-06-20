//
//  EditTableViewController.swift
//  OrderDrinks
//
//  Created by Shien on 2022/6/14.
//

import UIKit

class EditTableViewController: UITableViewController {
    private var url = URL(string:"https://api.airtable.com/v0/app7pSZ1CHcBMcs1a/%E7%B6%93%E5%85%B8%E5%8E%9F%E8%8C%B6")
    var menu: Menu?
    var drink: NewDrinks.NewDrinksRecord.NewDrinksFields?
    var drinkID: String?
    var actions = [UIAction]()
    var loadingView = UIActivityIndicatorView()
    var per_price = 0
    var counts = 0
    
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var groupButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var drinkImageView: UIImageView!
    @IBOutlet weak var enDrinkNameLabel: UILabel!
    @IBOutlet weak var drinkNameLabel: UILabel!
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet var toppingsButtons: [UIButton]!
    @IBOutlet weak var iceButton: UIButton!
    @IBOutlet weak var sugarButton: UIButton!
    @IBOutlet weak var sizeButton: UIButton!
    @IBOutlet weak var countStepper: UIStepper!
    @IBOutlet weak var countLabel: UILabel!
    var listRefreshControl: UIRefreshControl?
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchID()
        fetchMenu()
        showLoadingView()
    }
   
    func showLoadingView() {
        loadingView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        loadingView.backgroundColor = UIColor(red: 246/255, green: 244/255, blue: 229/255, alpha: 1)
        loadingView.isHidden = false
        tableView.addSubview(loadingView)
    }
    
    func fetchID() {
        let url = URL(string: "https://api.airtable.com/v0/appZTYancUlU6PvfX/Table%201")!
        var request = URLRequest(url: url)
        request.setValue("Bearer key9YLmddN4gQwWdP", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) {data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let list = try decoder.decode(AddNewGroup.self, from: data)
                    print(list.records)
                    var index = 0
                    while list.records[index].fields.priority != self.drink?.priority {
                        index += 1
                    }
                    self.drinkID = list.records[index].id
                }
                catch { print("fetch id \(error)")}
            }
        }.resume()
    }
    
    func updateNewDrinks(drinks: UpdateDrinks) {
        let url = URL(string: "https://api.airtable.com/v0/appZTYancUlU6PvfX/Table%201")!
        var request = URLRequest(url: url)
        request.httpMethod = "patch"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer key9YLmddN4gQwWdP", forHTTPHeaderField: "Authorization")
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(drinks)
        } catch {
            print(error)
        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse {
                print("updateNewDrinks \(response.statusCode)")
            }
        }.resume()
    }
   
    func fetchMenu() {
        if let url = URL(string: "https://api.airtable.com/v0/app7pSZ1CHcBMcs1a/\(typeNames[menuIndices.0])".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
            var request = URLRequest(url: url)
            request.httpMethod = "get"
            request.setValue("Bearer key9YLmddN4gQwWdP", forHTTPHeaderField: "Authorization")
            print("has url")
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    let decoder = JSONDecoder()
                    do {
                        self.menu = try decoder.decode(Menu.self, from: data)
                        DispatchQueue.main.async {
                            self.updateUI()
                            self.tableView.reloadData()
                        }
                    }
                    catch { print("fetch menu\(error)") }
                }
            }.resume()
        }
    }
    
    func updateUI() {
        print(menuIndices)
        if let drink = drink, let menu = menu {
            per_price = drink.per_price!
            counts = drink.counts!
            fetchImage(url: drink.image[0]?.url!) { image in
                DispatchQueue.main.async {
                    self.drinkImageView.image = image
                }
            }
            totalPriceLabel.text = "\(drink.total_price!)"
            nameTextField.text = drink.name!
            drinkNameLabel.text = menu.records[menuIndices.1].fields.name
            enDrinkNameLabel.text = menu.records[menuIndices.1].fields.english_name
            countLabel.text = "\(drink.counts!)"
            countStepper.value = Double(drink.counts!)
            setSugarButton()
            sugarButton.setTitle(drink.sugar!, for: .normal)
            setGroupButton()
            if drink.groupHost == nil {
                groupButton.isEnabled = true
            } else {
                groupButton.isEnabled = false
            }
            if let group = drink.group {
                groupButton.setTitle(group, for: .normal)
            }
            
            if menu.records[menuIndices.1].fields.large_price != nil {
                setSizeButton()
                sizeButton.setTitle(drink.size!, for: .normal)
            } else {
                sizeButton.setTitle(sizeNames[0], for: .normal)
                sizeButton.isEnabled = false
            }
            if menu.records[menuIndices.1].fields.info?.contains(MenuInfo.hot.rawValue) == true {
                iceButton.isEnabled = false
                iceButton.setTitle("熱", for: .normal)
            } else if menu.records[menuIndices.1].fields.info?.contains(MenuInfo.cold.rawValue) == true {
                iceButton.isEnabled = false
                iceButton.setTitle("正常冰", for: .normal)
            } else {
                setIceButton()
                iceButton.setTitle(drink.ice!, for: .normal)
            }
            
            for (i, button) in toppingsButtons.enumerated() {
                button.configuration?.baseBackgroundColor = UIColor(red: 246/255, green: 244/255, blue: 229/255, alpha: 1)
                button.configuration?.baseForegroundColor = UIColor(red: 148/255, green: 82/255, blue: 0, alpha: 1)
                switch i {
                case 0:
                    if drink.pearls == true {
                        button.configuration?.baseBackgroundColor = .black
                        button.configuration?.baseForegroundColor = .white
                    } else {
                        button.isEnabled = false
                    }
                case 1:
                    if drink.honey == true {
                        button.configuration?.baseBackgroundColor = .black
                        button.configuration?.baseForegroundColor = .white
                    } else {
                        button.isEnabled = false
                    }
                case 2:
                    if drink.grass_jelly == true {
                        button.configuration?.baseBackgroundColor = .black
                        button.configuration?.baseForegroundColor = .white
                    } else {
                        button.isEnabled = false
                    }
                default:
                    print("no topping button in editing page")
                }
            }
            loadingView.isHidden = true
        }
    }
    
    @IBAction func changeCount(_ sender: UIStepper) {
        drink!.total_price = per_price * Int(sender.value)
        totalPriceLabel.text = "\(String(describing: drink!.total_price!))"
        countLabel.text = "\(Int(sender.value))"
        counts = Int(sender.value)
    }
    
    func setIceButton() {
        iceButton.showsMenuAsPrimaryAction = true
        actions.removeAll()
        for i in iceNames {
            actions.append(UIAction(title: i, handler: { action in
                self.iceButton.setTitle(i, for: .normal)
            }))
        }
        iceButton.menu = UIMenu(children: actions)
    }

    func setSugarButton() {
        sugarButton.showsMenuAsPrimaryAction = true
        actions.removeAll()
        for name in sugarNames {
            actions.append(UIAction(title: name, handler: { action in
                self.sugarButton.setTitle(name, for: .normal)
            }))
        }
        sugarButton.menu = UIMenu(children: actions)
    }
    
    func setSizeButton() {
        sizeButton.showsMenuAsPrimaryAction = true
        actions.removeAll()
        for name in sizeNames {
            actions.append(UIAction(title: name, handler: { [self] action in
                self.sizeButton.setTitle(name, for: .normal)
                if name == "中杯" {
                    per_price -= menu!.records[menuIndices.1].fields.large_price!
                    per_price += menu!.records[menuIndices.1].fields.medium_price
                } else {
                    per_price -= menu!.records[menuIndices.1].fields.medium_price
                    per_price += menu!.records[menuIndices.1].fields.large_price!
                }
                drink!.total_price! = per_price * counts
                totalPriceLabel.text = "\(drink!.total_price!)"
            }))
        }
        sizeButton.menu = UIMenu(children: actions)
    }
    
    func setGroupButton() {
        groupButton.showsMenuAsPrimaryAction = true
        actions.removeAll()
        for group in allGroups {
            actions.append(UIAction(title: group, handler: { action in
                self.groupButton.setTitle(group, for: .normal)
                if group == "無群組" {
                    self.drink?.group = ""
                    print("無群組")
                } else {
                    self.drink?.group = group
                }
            }))
        }
        groupButton.menu = UIMenu(children: actions)
    }
    
    @IBAction func chooseToppings(_ sender: UIButton) {
            if sender.configuration?.baseBackgroundColor == .black {
                sender.configuration?.baseBackgroundColor = UIColor(red: 246/255, green: 244/255, blue: 229/255, alpha: 1)
                sender.configuration?.baseForegroundColor = UIColor(red: 148/255, green: 82/255, blue: 0, alpha: 1)
                switch sender {
                case toppingsButtons[0]:
                    drink?.pearls = false
                    per_price -= 10
                case toppingsButtons[1]:
                    drink?.honey = false
                    per_price -= 10
                case toppingsButtons[2]:
                    drink?.grass_jelly = false
                    per_price -= 15
                default:
                    print("something wrong with toppings in editing page")
                }
            } else {
                sender.configuration?.baseBackgroundColor = .black
                sender.configuration?.baseForegroundColor = .white
                switch sender {
                case toppingsButtons[0]:
                    drink?.pearls = true
                    per_price += 10
                case toppingsButtons[1]:
                    drink?.honey = true
                    per_price += 10
                case toppingsButtons[2]:
                    drink?.grass_jelly = true
                    per_price += 15
                default:
                    print("something wrong with toppings in editing page")
                }
            }
        drink!.total_price! = counts * per_price
        totalPriceLabel.text = "\(String(describing: drink!.total_price!))"
        
    }
    
    @IBAction func saveEditing(_ sender: Any) {
        self.updateNewDrinks(drinks: UpdateDrinks(records: [UpdateDrinks.UpdateDrinksRecord(id: drinkID!, fields: UpdateDrinks.UpdateDrinksFields(name: nameTextField.text!, counts: counts, size: sizeButton.titleLabel?.text!, drink: drink?.drink!, ice: iceButton.titleLabel?.text!, sugar: sugarButton.titleLabel?.text, per_price: per_price, total_price: drink!.total_price!, pearls: drink?.pearls, honey: drink?.honey, grass_jelly: drink?.grass_jelly, image: [UpdateDrinks.UpdateDrinksFields.NewDrinksImage(url: drink?.image[0]?.url!)], group: drink?.group, priority: drink!.priority, account_name: drink!.account_name, type_index: drink?.type_index!, item_index: drink?.item_index!))]))
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
    }
    
}
