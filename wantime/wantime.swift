//
//  wantime.swift
//  wantime
//
//  Created by 飯田俊輔 on 2024/11/18.
//

import SwiftUI

@main
struct wantime: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate // ← これが必要！


    let persistenceController = PersistenceController.shared
    @StateObject private var historyManager = HistoryManager()
    @StateObject private var adManager = InterstitialAdManager() // ✅ 追加

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(historyManager)
                .environmentObject(adManager) // ✅ 追加

        }
    }
}
