//
//  OrderViewController.swift
//  customer-ios
//
//  Created by Akram Hussein on 25/02/2017.
//  Copyright © 2017 deepstreamHub GmbH. All rights reserved.
//

import UIKit

final class OrderRecordPathChangedCallback : NSObject, RecordPathChangedCallback {
    
    private var callback : ((JsonElement) -> Void)!
    
    init(callback: @escaping (JsonElement) -> Void) {
        self.callback = callback
        super.init()
    }
    
    func onRecordPathChanged(_ recordName: String!, path: String!, data: JsonElement!) {
        print("Record '\(recordName!)' changed, data is now: \(data)")
        self.callback(data)
    }
}

let greenColor = UIColor(colorLiteralRed: 81/255, green: 184/255, blue: 115/255, alpha: 1.0)

class OrderViewController: UIViewController {
    
    @IBOutlet weak var receivedLabel: UILabel! {
        didSet {
            self.receivedLabel.textColor = greenColor
        }
    }
    
    @IBOutlet weak var inProgressLabel: UILabel!
    @IBOutlet weak var readyLabel: UILabel!
    @IBOutlet weak var deliveredLabel: UILabel!
    
    var menuItem : String?
    
    private var client : DeepstreamClient?
    private var ordersList : List?
    var record : Record?
    
    enum orderStage : String {
        case received = "received"
        case inProgress = "in-progress"
        case ready = "ready"
        case delivered = "delivered"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Don't allow going back
        self.navigationController!.interactivePopGestureRecognizer!.isEnabled = false
        self.navigationItem.hidesBackButton = true

        guard let client = DeepstreamFactory.getInstance().getClient(DeepstreamHubURL) else {
            print("ERROR: Unable to initialize client")
            return
        }
        
        self.client = client
        
        /////////////////////////////////////////
        
        // Create or retrieve a list with name orders
        
        // Get list
        guard let list = self.client?.record.getList("orders") else {
            return
        }
    
        self.ordersList = list
        
        // Generate unique id for order
        guard let uuid = self.client?.getUid() else {
            print("ERROR: Unable to get Uid")
            return
        }

        // Get record handler
        guard let record = self.client?.record.getRecord("coffee/\(uuid)") else {
            print("ERROR: Unable to get record")
            return
        }
        
        self.record = record
        
        // Subscribe to changes
        let _ = self.record?.subscribe("stage",
                                       recordPathChangedCallback: OrderRecordPathChangedCallback(callback: { (data) in
                
                DispatchQueue.main.async {
                    if let stage = OrderViewController.orderStage(rawValue: data.getAsString()!) {
                        switch (stage) {
                        case .received:
                            self.receivedLabel.textColor = greenColor
                            self.inProgressLabel.textColor = .lightGray
                            self.readyLabel.textColor = .lightGray
                            self.deliveredLabel.textColor = .lightGray
                        case .inProgress:
                            self.receivedLabel.textColor = .lightGray
                            self.inProgressLabel.textColor = greenColor
                            self.readyLabel.textColor = .lightGray
                            self.deliveredLabel.textColor = .lightGray
                        case .ready:
                            self.receivedLabel.textColor = .lightGray
                            self.inProgressLabel.textColor = .lightGray
                            self.readyLabel.textColor = greenColor
                            self.deliveredLabel.textColor = .lightGray
                        case .delivered:
                            self.receivedLabel.textColor = .lightGray
                            self.inProgressLabel.textColor = .lightGray
                            self.readyLabel.textColor = .lightGray
                            self.deliveredLabel.textColor = greenColor
                            
                            let _ = self.navigationController?.popToRootViewController(animated: true)
                        }
                    }
                }
            })
        )

        guard let item = self.menuItem else {
            let _ = self.navigationController?.popToRootViewController(animated: true)
            return
        }
        
        print("Placing order for \(item)")
        
        let order = [
            "type" : item,
            "stage" : orderStage.received.rawValue
        ]
        
        guard let rec = self.record?.set(order.jsonElement) else {
            print("ERROR: Unable to set record")
            return
        }
        
        let _ = self.ordersList?.addEntry(rec.name())
    }
}



