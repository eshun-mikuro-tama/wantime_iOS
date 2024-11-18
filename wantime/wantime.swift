//
//  wantime.swift
//  wantime
//
//  Created by 飯田俊輔 on 2024/11/18.
//

import SwiftUI

@main
struct wantime: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
