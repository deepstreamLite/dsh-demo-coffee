//
//  OrderViewController.swift
//  customer-ios
//
//  Created by Akram Hussein on 25/02/2017.
//  Copyright © 2017 deepstreamHub GmbH. All rights reserved.
//

import UIKit

class OrderViewController: UIViewController {
    
    var menuItem : String?
    
    private var client : DeepstreamClient?
    private var ordersList : List?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let client = DeepstreamFactory.getInstance().getClient(DeepstreamHubURL) else {
            print("Error: Unable to initialize client")
            return
        }
        
        self.client = client
        
        /////////////////////////////////////////
        
        // Create or retrieve a record with the name test/johndoe
        
        // Get list
        guard let list = self.client?.record.getList("orders") else {
            return
        }
    
        self.ordersList = list
        
        guard let item = self.menuItem else {
            let _ = self.navigationController?.popToRootViewController(animated: true)
            return
        }
        
        print("Placing order for \(item)")
        
        let _ = self.ordersList?.addEntry(item)
    }
}

