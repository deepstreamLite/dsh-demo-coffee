//
//  AppDelegate.swift
//  customer-ios
//
//  Created by Akram Hussein on 25/02/2017.
//  Copyright © 2017 deepstreamHub GmbH. All rights reserved.
//

import UIKit

final class RuntimeErrorHandler : NSObject, DSDeepstreamRuntimeErrorHandler {
    func onException(_ topic: DSTopic!, event: DSEvent!, errorMessage: String!) {
        if (errorMessage != nil && topic != nil && event != nil) {
            print("Error: \(errorMessage!) for topic: \(topic!), event: \(event!)")
        }
    }
}

final class AppConnectionStateListener : NSObject, DSConnectionStateListener {
    func connectionStateChanged(_ connectionState: DSConnectionState!) {
        print("Connection state changed \(connectionState!)")
    }
}

// NOTE: REPLACE HOST
let DeepstreamHubURL = "wss://154.deepstreamhub.com/?apiKey=0a599327-0f5d-4a05-b5a5-98188083e909"

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
