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
    
    // UI Labels
    @IBOutlet weak var receivedLabel: UILabel! {
        didSet {
            self.receivedLabel.textColor = greenColor
        }
    }
    
    @IBOutlet weak var inProgressLabel: UILabel!
    @IBOutlet weak var readyLabel: UILabel!
    @IBOutlet weak var deliveredLabel: UILabel!
    
    // State icons
    @IBOutlet weak var receivedIcon: UILabel!
    @IBOutlet weak var inProgressIcon: UILabel!
    @IBOutlet weak var readyIcon: UILabel!
    @IBOutlet weak var deliveredIcon: UILabel!
    
    
    var menuItem : String?
    
    private var client : DeepstreamClient?
    private var ordersList : List?
    var orderRecord : Record?
    
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
        guard let orderRecord = self.client?.record.getRecord("coffee/\(uuid)") else {
            print("ERROR: Unable to get record")
            return
        }
        
        self.orderRecord = orderRecord
        
        // Subscribe to changes
        let _ = self.orderRecord?.subscribe("stage",
                                       recordPathChangedCallback: OrderRecordPathChangedCallback(callback: { (data) in
                
                // Update the progress UI
                DispatchQueue.main.async {
                    if let stage = OrderViewController.orderStage(rawValue: data.getAsString()!) {
                        switch (stage) {
                        case .received:
                            self.receivedLabel.fadeToColor(greenColor)
                            self.inProgressLabel.fadeToColor(.lightGray)
                            self.readyLabel.fadeToColor(.lightGray)
                            self.deliveredLabel.fadeToColor(.lightGray)
                            
                            self.receivedIcon.fadeToCheckMark()
                            self.inProgressIcon.fadeToCross()
                            self.readyIcon.fadeToCross()
                            self.deliveredIcon.fadeToCross()
                            
                        case .inProgress:
                            self.receivedLabel.fadeToColor(greenColor)
                            self.inProgressLabel.fadeToColor(greenColor)
                            self.readyLabel.fadeToColor(.lightGray)
                            self.deliveredLabel.fadeToColor(.lightGray)
                            
                            self.receivedIcon.fadeToCheckMark()
                            self.inProgressIcon.fadeToCheckMark()
                            self.readyIcon.fadeToCross()
                            self.deliveredIcon.fadeToCross()
                        case .ready:
                            self.receivedLabel.fadeToColor(greenColor)
                            self.inProgressLabel.fadeToColor(greenColor)
                            self.readyLabel.fadeToColor(greenColor)
                            self.deliveredLabel.fadeToColor(.lightGray)
                            
                            self.receivedIcon.fadeToCheckMark()
                            self.inProgressIcon.fadeToCheckMark()
                            self.readyIcon.fadeToCheckMark()
                            self.deliveredIcon.fadeToCross()
                        case .delivered:
                            self.receivedLabel.fadeToColor(greenColor)
                            self.inProgressLabel.fadeToColor(greenColor)
                            self.readyLabel.fadeToColor(greenColor)
                            self.deliveredLabel.fadeToColor(greenColor)
                            
                            self.receivedIcon.fadeToCheckMark()
                            self.inProgressIcon.fadeToCheckMark()
                            self.readyIcon.fadeToCheckMark()
                            self.deliveredIcon.fadeToCheckMark()
                            
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
        
        guard let _ = self.orderRecord?.set(order.jsonElement) else {
            print("ERROR: Unable to set record")
            return
        }
        
        let _ = self.ordersList?.addEntry(orderRecord.name())
    }
}

extension UILabel {
    func fadeToColor(_ color: UIColor) {
        UIView.transition(with: self,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: { self.textColor = color },
                          completion: nil)
    }
    
    func fadeText(_ text: String) {
        self.fadeTransition(0.4)
        self.text = text
    }
    
    func fadeToCheckMark() {
        self.fadeText("✓")
        self.fadeToColor(greenColor)
    }
    
    func fadeToCross() {
        self.fadeText("✕")
        self.fadeToColor(.lightGray)
    }
}

extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade
        animation.duration = duration
        layer.add(animation, forKey: kCATransitionFade)
    }
}

