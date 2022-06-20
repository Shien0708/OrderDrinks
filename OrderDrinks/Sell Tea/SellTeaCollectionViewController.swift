//
//  SellTeaCollectionViewController.swift
//  OrderDrinks
//
//  Created by Shien on 2022/6/16.
//

import UIKit

private let reuseIdentifier = "cell"

class SellTeaCollectionViewController: UICollectionViewController {
    var tea: Tea?
    var teaButtons = [UIButton]()
    var loadingView = UIActivityIndicatorView()
    var touchedTeaButtonIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoadingView()
        resize()
        fetchTea()
    }
    
    func showLoadingView() {
        loadingView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        loadingView.startAnimating()
        loadingView.backgroundColor = UIColor(red: 244/255, green: 247/255, blue: 231/255, alpha: 1)
        loadingView.isHidden = false
        collectionView.addSubview(loadingView)
    }
    func resize() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (view.bounds.width-10)/2, height: 280)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 15
        collectionView.collectionViewLayout = layout as UICollectionViewLayout
    }
    
    func fetchTea() {
        let url = URL(string: "https://api.airtable.com/v0/appChr1FX2nkigbNs/Table%201")!
        var request = URLRequest(url: url)
        request.setValue("Bearer key9YLmddN4gQwWdP", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let results = try decoder.decode(Tea.self, from: data)
                    self.tea = results
                    DispatchQueue.main.async {
                        self.teaButtons.removeAll()
                        self.collectionView.reloadData()
                        self.loadingView.isHidden = true
                        self.loadingView.stopAnimating()
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    
    @IBAction func press(_ sender: UIButton) {
        touchedTeaButtonIndex = Int((sender.titleLabel?.text!)!)!
        performSegue(withIdentifier: "showTeaWeb", sender: nil)
    }
    
    
    @IBSegueAction func showTeaWeb(_ coder: NSCoder) -> WebViewController? {
        let controller = WebViewController(coder: coder)
        controller!.url = tea?.records[touchedTeaButtonIndex].fields.url
        return controller
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return tea?.records.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? SellTeaCollectionViewCell else {
            return SellTeaCollectionViewCell()
        }
        
        if let tea = tea {
            let fields = tea.records[indexPath.item].fields
            fetchImage(url: fields.image[0].url) { image in
                DispatchQueue.main.async {
                    cell.teaImageView.image = image
                }
            }
            cell.teaNameLabel.text = fields.name
            cell.priceLabel.text = "$ \(fields.price)"
            if !teaButtons.contains(cell.webButton) {
                teaButtons.append(cell.webButton)
            }
            cell.webButton.setTitle("\(indexPath.item)", for: .normal)
        }
        
        return cell
    }

}
