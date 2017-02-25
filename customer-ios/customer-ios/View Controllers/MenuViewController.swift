//
//  MenuViewController.swift
//  customer-ios
//
//  Created by Akram Hussein on 25/02/2017.
//  Copyright © 2017 deepstreamHub GmbH. All rights reserved.
//

import UIKit

let Menu = [
    "espresso",
    "machiatto",
    "cappuccino",
    "latte",
    "americano"
]

class MenuViewController: UIViewController {

    var selectedMenuItem : String?
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showOrderViewController") {
            
            guard let vc = segue.destination as? OrderViewController else {
                return
            }
            
            // Pass selected menu item
            vc.menuItem = self.selectedMenuItem
        }
    }
    
}

extension MenuViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let menuItem = Menu[indexPath.row]
        self.selectedMenuItem = menuItem
        
        self.performSegue(withIdentifier: "showOrderViewController", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView( _ tableView: UITableView, heightForHeaderInSection section: Int ) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}

extension MenuViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "MenuTableViewCell")
        
        let menuItem = Menu[indexPath.row]
        cell.textLabel?.text = "\(menuItem)"
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Menu.count
    }
    
}
