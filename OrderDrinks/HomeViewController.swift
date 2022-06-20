//
//  HomeViewController.swift
//  OrderDrinks
//
//  Created by Shien on 2022/6/16.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var teaScrollView: UIScrollView!
    @IBOutlet weak var teaPageControl: UIPageControl!
    @IBOutlet var webButtons: [UIButton]!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    let urlStrings = ["https://www.tenren.com.tw/Content/Messagess/contents.aspx?&SiteID=10&MmmID=654044340127752375&MSID=1162152104142522237",
        "https://www.tenren.com.tw/Content/Messagess/contents.aspx?&SiteID=10&MmmID=654044340127752375&MSID=1162152157476430326",
        "https://www.tenren.com.tw/Content/Messagess/contents.aspx?&SiteID=10&MmmID=654044340127752375&MSID=1162152133372704400",
        "https://www.tenren.com.tw/Content/Messagess/contents.aspx?&SiteID=10&MmmID=654044340127752375&MSID=1162133510464266300"]
    
    @IBAction func changePage(_ sender: UIPageControl) {
        teaScrollView.setContentOffset(CGPoint(x: Int(teaScrollView.bounds.width)*sender.currentPage, y: 0), animated: true)
    }
    
    
    
    @IBAction func press(_ sender: Any) {
        performSegue(withIdentifier: "showWeb", sender: nil)
    }
    
    @IBSegueAction func showWeb(_ coder: NSCoder) -> WebViewController? {
        let controller = WebViewController(coder: coder)
        var index = 0
        while !webButtons[index].isTouchInside {
            index += 1
        }
        controller?.url = URL(string: urlStrings[index])
        return controller
    }
}


extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var page = 0
        page = Int(scrollView.contentOffset.x/scrollView.bounds.width)
        teaPageControl.currentPage = page
    }
    
}
