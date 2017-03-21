//
//  AppDelegate.swift
//  customer-ios
//
//  Created by Akram Hussein on 25/02/2017.
//  Copyright © 2017 deepstreamHub GmbH. All rights reserved.
//

import UIKit

final class RuntimeErrorHandler : NSObject, DeepstreamRuntimeErrorHandler {
    func onException(_ topic: Topic!, event: Event!, errorMessage: String!) {
        if (errorMessage != nil && topic != nil && event != nil) {
            print("Error: \(errorMessage!) for topic: \(topic!), event: \(event!)")
        }
    }
}

final class AppConnectionStateListener : NSObject, ConnectionStateListener {
    func connectionStateChanged(_ connectionState: ConnectionState!) {
        print("Connection state changed \(connectionState!)")
    }
}

// NOTE: REPLACE HOST
let DeepstreamHubURL = "wss://xxx.deepstreamhub.com?apiKey=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        /************************************
         * Connect and login to deepstreamHub
         ************************************/

        // Establish a connection.
        // You can find your endpoint url in the deepstreamhub dashboard

        // Use the DeepstreamFactory to setup the client and then we can retreive this anywhere
        // in our app later without re-configuring
        IOSDeepstreamFactory.getInstance().getClient(DeepstreamHubURL, callback: { (client) in
            // Set up a 'Runtime' handler that will catch any issues and process them for us
            client!.setRuntimeErrorHandler(RuntimeErrorHandler())

            // Set up a 'Connection State' Listener to listen to changes in connection
            client!.addConnectionChange(AppConnectionStateListener())

            // Authenticate your connection. We haven't activated auth,
            // so this method can be called without arguments

            // Get login result to confirm successful connection
            let loginResult = client!.login()

            // Check a successful login
            if (loginResult!.getErrorEvent() == nil) {
                print("Successfully logged in")
            } else {
                print("Failed to log in")
            }
        })
        return true
    }
}
