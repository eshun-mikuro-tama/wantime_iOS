//
//  AppDelegate.swift
//  wantime
//
//  Created by 飯田俊輔 on 2025/03/22.
//

import UIKit
import GoogleMobileAds

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // 🔰 AdMob 初期化
        MobileAds.shared.start()
        print("✅ AdMob 初期化完了")
        return true
    }
}
