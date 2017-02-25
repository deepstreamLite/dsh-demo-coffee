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
let DeepstreamHubURL = "127.0.0.1:6020/deepstream"

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
        guard let client = DeepstreamFactory.getInstance().getClient(DeepstreamHubURL) else {
            print("Unable to initialize client")
            return true
        }
        
        // Set up a 'Runtime' handler that will catch any issues and process them for us
        client.setRuntimeErrorHandler(RuntimeErrorHandler())
        
        // Set up a 'Connection State' Listener to listen to changes in connection
        client.addConnectionChange(AppConnectionStateListener())
        
        // Authenticate your connection. We haven't activated auth,
        // so this method can be called without arguments
        
        // Get login result to confirm successful connection
        guard let loginResult = client.login() else {
            print("Unable to get login result")
            return true
        }
        
        // Check a successful login
        if (loginResult.getErrorEvent() == nil) {
            print("Successfully logged in")
        } else {
            print("Error: Failed to log in...exiting")
            return true
        }
        
        return true
    }
}

