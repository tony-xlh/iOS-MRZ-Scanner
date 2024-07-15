//
//  AppDelegate.swift
//  mrzscanner
//
//  Created by xulihang on 2024/7/9.
//

import UIKit
import DynamsoftLicense

@main
class AppDelegate: UIResponder, UIApplicationDelegate, LicenseVerificationListener  {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        let vc = ViewController()
        let navController = UINavigationController(rootViewController: vc)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        LicenseManager.initLicense("DLS2eyJoYW5kc2hha2VDb2RlIjoiMTAwMjI3NzYzLVRYbE5iMkpwYkdWUWNtOXEiLCJtYWluU2VydmVyVVJMIjoiaHR0cHM6Ly9tbHRzLmR5bmFtc29mdC5jb20iLCJvcmdhbml6YXRpb25JRCI6IjEwMDIyNzc2MyIsInN0YW5kYnlTZXJ2ZXJVUkwiOiJodHRwczovL3NsdHMuZHluYW1zb2Z0LmNvbSIsImNoZWNrQ29kZSI6LTM5MDUxMjkwOH0=", verificationDelegate:self)
        return true
    }
    
    func onLicenseVerified(_ isSuccess: Bool, error: Error?) {
        print(isSuccess)
        if(error != nil)
        {
            if let msg = error?.localizedDescription {
                print("Server license verify failed, error:\(msg)")
            }
        }
     }
}

