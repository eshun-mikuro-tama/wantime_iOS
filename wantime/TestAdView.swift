//
//  TestAdView.swift
//  wantime
//
//  Created by 飯田俊輔 on 2025/03/30.
//


import SwiftUI

struct TestAdView: View {
    @EnvironmentObject var adManager: InterstitialAdManager

    var body: some View {
        VStack(spacing: 20) {
            Text("広告テスト画面")
                .font(.title)

            Button("広告を表示する") {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = scene.windows.first?.rootViewController {
                    adManager.showAd(from: rootVC) {
                        print("✅ 広告が閉じられました")
                    }
                }
            }
        }
        .padding()
    }
}

