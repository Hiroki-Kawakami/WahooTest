//
//  AppDelegate.swift
//  WahooTest
//
//  Created by hiroki on 2020/05/10.
//  Copyright © 2020 hiroki. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        WFHardwareConnector.shared()?.enableBTLE(true)
        WFHardwareConnector.shared()

        return true
    }


}

