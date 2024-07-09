//
//  AppDelegate.swift
//  mrzscanner
//
//  Created by xulihang on 2024/7/9.
//

import UIKit
import DynamsoftLabelRecognizer

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
        DynamsoftLicenseManager.initLicense("DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ==",verificationDelegate:self)
        return true
    }
    
    func licenseVerificationCallback(_ isSuccess: Bool, error: Error?) {
        var msg:String? = ""
        if isSuccess {
            print("license valid")
        }
        if(error != nil)
        {
            let err = error as NSError?
            if err?.code == -1009 {
                msg = "Dynamsoft Label Recognizer is unable to connect to the public Internet to acquire a license. Please connect your device to the Internet or contact support@dynamsoft.com to acquire an offline license."
            }else{
                msg = err!.userInfo[NSUnderlyingErrorKey] as? String
                if(msg == nil)
                {
                    msg = err?.localizedDescription
                }
            }
            print(msg ?? "")
        }
    }
}

