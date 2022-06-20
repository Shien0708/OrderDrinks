//
//  DetailTableViewController.swift
//  OrderDrinks
//
//  Created by Shien on 2022/6/11.
//

import UIKit

class DetailTableViewController: UITableViewController {
    var drink: MenuFields?
    var selectedButtonIndex = 0
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var enNameLabel: UILabel!
    @IBOutlet weak var chNameLabel: UILabel!
    @IBOutlet weak var drinksImageView: UIImageView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var sizeButton: UIButton!
    @IBOutlet var toppingsButtons: [UIButton]!
    @IBOutlet weak var sugarButton: UIButton!
    @IBOutlet weak var iceButton: UIButton!
    
    var hasToppings = [Bool](repeating: false, count: 3)
    var isMedium = true
    var totalCounts = 1
    var totalPrice = 0
    var perPrice = 0
    var actions = [UIAction]()
    var loadingView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
        selectSize()
        selectSugar()
    }
    
    func showLoadingView() {
        loadingView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        loadingView.isHidden = false
        tableView.addSubview(loadingView)
    }

    // MARK: - Table view data source

    //table view
    func updateUI() {
        if let drink = drink {
            chNameLabel.text = drink.name
            enNameLabel.text = drink.english_name
            
            fetchImage(url: drink.image[0].url) { image in
                if let image = image {
                    DispatchQueue.main.async {
                        self.drinksImageView.image = image
                    }
                } else {
                    DispatchQueue.main.async {
                        self.drinksImageView.image = UIImage(systemName: "photo")
                    }
                }
            }
            
            totalPrice = drink.medium_price
            perPrice = drink.medium_price
            totalPriceLabel.text = "\(totalPrice)"
            
            if let info = drink.info {
                if info.contains("Cold Drinks Only") {
                    iceButton.isEnabled = false
                    iceButton.setTitle("正常", for: .normal)
                } else if info.contains("Hot Drinks Only") {
                    iceButton.isEnabled = false
                    iceButton.setTitle("熱", for: .normal)
                } else {
                    selectIce()
                }
            } else {
                selectIce()
            }
            
            if chNameLabel.text!.contains("珍珠") {
                toppingsButtons[0].isEnabled = false
            }
            if chNameLabel.text!.contains("蜂蜜") {
                toppingsButtons[1].isEnabled = false
            }
            if chNameLabel.text!.contains("仙草") {
                toppingsButtons[2].isEnabled = false
            }
        } else {
            print("no drink")
        }
    }
   
    //stepper
    @IBAction func adjustCount(_ sender: UIStepper) {
        countLabel.text = "\(Int(sender.value))"
        totalCounts = Int(sender.value)
        totalPrice = perPrice * totalCounts
        totalPriceLabel.text = "\(totalPrice)"
    }
    
    //buttons
    func selectSize() {
        actions.removeAll()
        sizeButton.showsMenuAsPrimaryAction = true
        if let largePrice = drink?.large_price {
            for (i, name) in sizeNames.enumerated() {
                actions.append(UIAction(title: name, handler: { action in
                    if i == 0 {
                        self.isMedium = true
                        self.perPrice -= largePrice
                        self.perPrice += self.drink!.medium_price
                    } else {
                        self.isMedium = false
                        self.perPrice -= self.drink!.medium_price
                        self.perPrice += largePrice
                    }
                    self.sizeButton.setTitle(name, for: .normal)
                    self.totalPrice = self.perPrice * self.totalCounts
                    self.totalPriceLabel.text = "\(self.totalPrice)"
                }))
            }
        } else {
            actions.append(UIAction(title: sizeNames[0], handler: { action in
                self.totalPrice = self.perPrice * self.totalCounts
                self.totalPriceLabel.text = "\(self.totalPrice)"
            }))
        }
        sizeButton.menu = UIMenu(children: actions)
    }
    
    func selectSugar() {
        actions.removeAll()
        sugarButton.showsMenuAsPrimaryAction = true
        for sugar in sugarNames {
            actions.append(UIAction(title: sugar,handler: { action in
                self.sugarButton.setTitle(sugar, for: .normal)
            }))
        }
        sugarButton.menu = UIMenu(children: actions)
    }
    
    func selectIce() {
        actions.removeAll()
        iceButton.showsMenuAsPrimaryAction = true
        for iceName in iceNames {
            actions.append(UIAction(title:iceName, handler: { action in
                self.iceButton.setTitle(iceName, for: .normal)
            }))
        }
        iceButton.menu = UIMenu(children: actions)
    }
    
    @IBAction func addToppings(_ sender: UIButton) {
        if sender.configuration?.baseBackgroundColor != .black {
            sender.configuration?.baseBackgroundColor = .black
            sender.configuration?.baseForegroundColor = .white
        } else {
            sender.configuration?.baseBackgroundColor = UIColor(red: 246/255, green: 244/255, blue: 229/255, alpha: 1)
            sender.configuration?.baseForegroundColor = UIColor(red: 148/255, green: 82/255, blue: 0, alpha: 1)
        }
        switch sender {
        case toppingsButtons[0]:
            if sender.configuration?.baseBackgroundColor == .black {
                perPrice += 10
                hasToppings[0] = true
            } else {
                perPrice -= 10
                hasToppings[0] = false
            }
        case toppingsButtons[1]:
            if sender.configuration?.baseBackgroundColor == .black{ perPrice += 10
                hasToppings[1] = true
            } else {
                perPrice -= 10
                hasToppings[1] = false
            }
        case toppingsButtons[2]:
            if sender.configuration?.baseBackgroundColor == .black{ perPrice += 15
                hasToppings[2] = true
            } else {
                perPrice -= 15
                hasToppings[2] = false
            }
        default:
            print("no button")
        }
        self.totalPrice = self.perPrice * self.totalCounts
        totalPriceLabel.text = "\(totalPrice)"
    }
    
    //keyboard
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
    }
    
    //add to cart
    @IBAction func doubleCheck(_ sender: Any) {
        var controller = UIAlertController(title: "確認儲存訂單？", message: nil, preferredStyle: .alert)
        guard nameTextField.text?.isEmpty == false else {
            controller = UIAlertController(title: "請輸入您的暱稱", message: nil, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .default))
            present(controller, animated: true)
            return
        }
        controller.addAction(UIAlertAction(title: "確認", style: .default, handler: { action in
            self.performSegue(withIdentifier: "addToCart", sender: nil)
        }))
        controller.addAction(UIAlertAction(title: "繼續編輯", style: .cancel))
        present(controller, animated: true)
    }
    
    func postNewDrinks(newDrinks: NewDrinks) {
        var request = URLRequest(url: URL(string: "https://api.airtable.com/v0/appZTYancUlU6PvfX/Table%201")!)
        request.httpMethod = "post"
        request.setValue("Bearer key9YLmddN4gQwWdP", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()
        let data = try? encoder.encode(newDrinks)
        request.httpBody = data!
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse {
                print(response.statusCode)
                DispatchQueue.main.async {
                    self.loadingView.isHidden = true
                }
            } 
        }.resume()
    }
    
    @IBSegueAction func addToCart(_ coder: NSCoder) -> CartTableViewController? {
        showLoadingView()
        totalCustomers += 1
        let controller = CartTableViewController(coder: coder)
        controller?.newDrink = NewDrinks(records: [NewDrinks.NewDrinksRecord(fields: NewDrinks.NewDrinksRecord.NewDrinksFields(name:nameTextField.text! , counts: totalCounts, size: sizeButton.titleLabel?.text!, drink: chNameLabel.text!, ice: iceButton.titleLabel?.text!, sugar: sugarButton.titleLabel?.text!, per_price: perPrice, total_price: totalPrice, pearls: hasToppings[0], honey: hasToppings[1], grass_jelly: hasToppings[2], image: [NewDrinks.NewDrinksRecord.NewDrinksFields.NewDrinksImage(url: drink?.image[0].url)], priority: totalCustomers, account_name: currentAccounts.0, type_index: menuIndices.0, item_index: menuIndices.1))])
        postNewDrinks(newDrinks: (controller?.newDrink)!)
        return controller
    }
}


