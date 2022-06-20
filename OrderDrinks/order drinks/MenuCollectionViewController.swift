//
//  MenuCollectionViewController.swift
//  OrderDrinks
//
//  Created by Shien on 2022/6/10.
//

import UIKit

private let reuseIdentifier = "\(MenuCollectionViewCell.self)"

class MenuCollectionViewController: UICollectionViewController {
    private var url = URL(string:"https://api.airtable.com/v0/app7pSZ1CHcBMcs1a/%E7%B6%93%E5%85%B8%E5%8E%9F%E8%8C%B6")
    //main menu
    var drinks = [MenuRecord]()
    var menu: Menu?
    let topDrinksView = DrinksCollectionReusableView()
    var topDrink = topDrinks[0]
    var isTopDrink = false
    //loading
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingView.isHidden = false
        resizeCell()
        fetchMenu()
        currentURL = url!
    }
    
   
    func resizeCell() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20
        layout.itemSize = CGSize(width: (view.bounds.width-20)/2, height: 274)
        layout.minimumLineSpacing = 10
        collectionView.collectionViewLayout = layout as UICollectionViewLayout
    }
    
    @IBAction func changeMenu(_ sender: UISegmentedControl) {
        url = URL(string: "https://api.airtable.com/v0/app7pSZ1CHcBMcs1a/\(String(describing: sender.titleForSegment(at: sender.selectedSegmentIndex)!))".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        currentURL = url!
        menuIndices.0 = sender.selectedSegmentIndex
        drinkTypeIndex = sender.selectedSegmentIndex
        fetchMenu()
    }
    
    func fetchMenu() {
        loadingView.isHidden = false
        if let url = url {
            var request = URLRequest(url: url)
            request.httpMethod = "get"
            request.setValue("Bearer key9YLmddN4gQwWdP", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    let decoder = JSONDecoder()
                    do {
                        self.menu = try decoder.decode(Menu.self, from: data)
                        self.drinks = self.menu!.records
                        DispatchQueue.main.async {
                            self.collectionView.reloadData()
                            self.loadingView.isHidden = true
                        }
                    }
                    catch { print("fetch menu \(error)") }
                }
            }.resume()
        }
    }
    
    
    @IBAction func showDrinksDetails(_ sender: UIButton) {
        isTopDrink = false
        touchedButtonIndex = Int(sender.titleLabel!.text!)!
        performSegue(withIdentifier: "showTopDrinks", sender: nil)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return drinks.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? MenuCollectionViewCell else {
            return MenuCollectionViewCell()
        }
    
        let drink = drinks[indexPath.item].fields
        cell.chNameLabel.text = drink.name
        cell.enNameLabel.text = drink.english_name
        cell.drinkButton.setTitle("\(indexPath.item)", for: .normal)
        cell.drinksImageView.image = UIImage(systemName: "photo")
        fetchImage(url: drink.image[0].url, completion: { image in
            DispatchQueue.main.async {
                if let image = image {
                    if indexPath == collectionView.indexPath(for: cell) {
                        cell.drinksImageView.image = image
                    }
                } else {
                    cell.drinksImageView.image = UIImage(systemName: "photo")
                }
            }
        })
        for info in cell.infoImageViews {
            info.isHidden = true
        }
        if let info = drink.info, !info.isEmpty {
            for (i, info) in drink.info!.enumerated() {
                cell.infoImageViews[i].isHidden = false
                switch info {
                case MenuInfo.best.rawValue:
                    cell.infoImageViews[i].image = UIImage(named: "best")
                case MenuInfo.cold.rawValue:
                    cell.infoImageViews[i].image = UIImage(named: "cold")
                case MenuInfo.hot.rawValue:
                    cell.infoImageViews[i].image = UIImage(named: "hot")
                case MenuInfo.limited.rawValue:
                    cell.infoImageViews[i].image = UIImage(named: "limited")
                default:
                    print("no info")
                }
            }
        }
        return cell
    }
    
    
    @IBAction func selectTopDrinks(_ sender: UIButton) {
        isTopDrink = true
        touchedButtonIndex = Int((sender.titleLabel?.text)!)!
        performSegue(withIdentifier: "showTopDrinks", sender: nil)
    }
    
    @IBSegueAction func showTopDrinksDetails(_ coder: NSCoder) -> DetailTableViewController? {
        
        let  controller = DetailTableViewController(coder: coder)
        if isTopDrink {
            topDrink = topDrinks[touchedButtonIndex]
            controller?.selectedButtonIndex = touchedButtonIndex
            controller!.drink = topDrink
            menuIndices.0 = topDrinksIndices[touchedButtonIndex].0
            menuIndices.1 = topDrinksIndices[touchedButtonIndex].1
        } else {
            controller!.drink = drinks[touchedButtonIndex].fields
            menuIndices.1 = touchedButtonIndex
        }
        loadingView.isHidden = true
        return controller
    }
    
    
    @IBAction func backToMenu(_ segue: UIStoryboardSegue) {
    }
    
}

extension MenuCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.bounds.width, height: 268)
    }
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headView = collectionView.dequeueReusableSupplementaryView(ofKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: "reuseableView", for: indexPath) as? DrinksCollectionReusableView else {
            return DrinksCollectionReusableView()
        }
        headView.typeSegmentedControl.frame = CGRect(x: 0, y: 238, width: self.view.bounds.width, height: 30)
        return headView
    }
    
    
    
}


