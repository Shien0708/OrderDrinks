//
//  CartTableViewController.swift
//  OrderDrinks
//
//  Created by Shien on 2022/6/12.
//

import UIKit

class CartTableViewController: UITableViewController {
    @IBOutlet weak var drinkImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var countsLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var sugarLabel: UILabel!
    @IBOutlet weak var iceLabel: UILabel!
    @IBOutlet var toppingsLabels: [UILabel]!
    
    var pickerField = UITextField()
    var newDrink: NewDrinks?
    var newDrinkID: String?
    var groupPickerView = UIPickerView()
    @IBOutlet weak var selectedGroupLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        fetchID()
        setPickerView()
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
                    while list.records[index].fields.priority != totalCustomers {
                        index += 1
                    }
                    self.newDrinkID = list.records[index].id
                }
                catch { print("fetch id \(error)")}
            }
        }.resume()
    }
    
   
    func setPickerView() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 10))
        toolBar.items = [UIBarButtonItem(title:"取消", primaryAction: UIAction(handler: { action in
            if let group = self.newDrink?.records[0].fields.group {
                self.selectedGroupLabel.text = group
            } else {
                self.selectedGroupLabel.text = "無群組"
            }
           
            self.view.endEditing(true)
                      })),
                           UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
                           UIBarButtonItem(title:"選擇" ,primaryAction: UIAction(handler: { action in
            if self.selectedGroupLabel.text == "無群組" {
                self.updateGroup(group: AddNewGroup(records: [AddNewGroup.AddGroupRecord(id: self.newDrinkID!, fields: AddNewGroup.AddGroupFields(group: "", priority: totalCustomers))]))
            } else {
                self.updateGroup(group: AddNewGroup(records: [AddNewGroup.AddGroupRecord(id: self.newDrinkID!, fields: AddNewGroup.AddGroupFields(group: self.selectedGroupLabel.text!, priority: totalCustomers))]))
            }
           
            self.view.endEditing(true)
        }))
                         ]
        toolBar.sizeToFit()
        
        groupPickerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 200)
        groupPickerView.delegate = self
        groupPickerView.dataSource = self
        view.addSubview(pickerField)
        pickerField.inputView = groupPickerView
        pickerField.inputAccessoryView = toolBar
    }
    
    
    func updateUI() {
        if let newDrink = newDrink {
            let drink = newDrink.records[0].fields
            drinkImageView.image = try? UIImage(data: Data(contentsOf: drink.image[0]!.url!))
            nameLabel.text = drink.drink!
            countsLabel.text = "\(drink.counts!) 杯"
            sizeLabel.text = drink.size!
            sugarLabel.text = "甜度：\(drink.sugar!)"
            iceLabel.text = "冰塊：\(drink.ice!)"
            if drink.pearls! {
                toppingsLabels[0].isHidden = false
            }
            if drink.honey! {
                toppingsLabels[1].isHidden = false
            }
            if drink.grass_jelly! {
                toppingsLabels[2].isHidden = false
            }
            for record in newDrink.records {
                if let group = record.fields.group {
                   if !allGroups.contains(group){
                        allGroups.append(group)
                   }
                }
            }
        }
    }
    
    func updateGroup(group: AddNewGroup) {
        var request = URLRequest(url: URL(string: "https://api.airtable.com/v0/appZTYancUlU6PvfX/Table%201")!)
        request.httpMethod = "patch"
        request.setValue("Bearer key9YLmddN4gQwWdP", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoder = JSONEncoder()
        do {
            request.httpBody = try encoder.encode(group)
            
        } catch {print(error)}
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse {
                print("update \(response.statusCode)")
            }
        }.resume()
    }
    
    // add new group
    @IBAction func addNewGroup(_ sender: Any) {
        let controller = UIAlertController(title: "建立新團體", message: nil, preferredStyle: .alert)
        controller.addTextField()
        controller.textFields![0].placeholder = "輸入團體名稱"
        controller.addAction(UIAlertAction(title: "確認", style: .default, handler: { action in
            for group in allGroups {
                guard group != controller.textFields![0].text! else {
                    let alert = UIAlertController(title: "名稱已存在", message: "請重新命名", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                    return
                }
            }
            self.newDrink!.records[0].fields.group = controller.textFields![0].text!
            self.selectedGroupLabel.text = controller.textFields![0].text!
            allGroups.append(controller.textFields![0].text!)
            self.groupPickerView.reloadAllComponents()
            for i in 0...self.newDrink!.records.count-1 {
                self.newDrink!.records[i].fields.group = controller.textFields![0].text!
            }
            self.performSegue(withIdentifier: "addNewGroup", sender: nil)
            self.updateGroup(group: AddNewGroup(records: [AddNewGroup.AddGroupRecord(id: self.newDrinkID!, fields: AddNewGroup.AddGroupFields(group: controller.textFields![0].text!, groupHost: currentAccounts.0, priority: totalCustomers))]))
        }))
        controller.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(controller, animated: true)
    }
    
    @IBSegueAction func showNewGroup(_ coder: NSCoder) -> UITableViewController? {
        let controller = GroupTableViewController(coder: coder)
        if let newDrink = newDrink {
            controller?.drinks = newDrink
        }
        return controller
    }
    
    //show all groups
    
    @IBAction func showAllGroups(_ sender: Any) {
        pickerField.becomeFirstResponder()
    }
}


extension CartTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        allGroups.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        allGroups[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedGroupLabel.text = allGroups[row]
    }
}
