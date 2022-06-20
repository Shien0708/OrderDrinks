//
//  WebViewController.swift
//  OrderDrinks
//
//  Created by Shien on 2022/6/16.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    var url: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    

}
