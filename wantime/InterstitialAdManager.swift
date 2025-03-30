//
//  InterstitialAdManager.swift
//  wantime
//
//  Created by 飯田俊輔 on 2025/03/22.
//

import GoogleMobileAds
import SwiftUI

class InterstitialAdManager: NSObject, FullScreenContentDelegate, ObservableObject {
    @Published var interstitial: InterstitialAd? = nil
    private let adUnitID = "ca-app-pub-4742498529839819/6611819426" // テスト用
    private var adDismissCompletion: (() -> Void)? = nil // ✅ 追加

    override init() {
        super.init()
        loadAd()
    }

    func loadAd() {
        let request = Request()
        InterstitialAd.load(with: adUnitID, request: request) { ad, error in
            if let error = error {
                print("❌ 広告のロードに失敗: \(error.localizedDescription)")
                return
            }
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
            print("✅ インタースティシャル広告のロード成功")
        }
    }

    func showAd(from rootViewController: UIViewController, completion: @escaping () -> Void) {
        if let ad = interstitial {
            print("📢 広告を表示します")
            adDismissCompletion = completion
            ad.fullScreenContentDelegate = self // ✅ ← もう一度ここでdelegate設定！
            ad.present(from: rootViewController)
            interstitial = nil // 忘れずnilに
        } else {
            print("⚠️ 広告がまだロードされていません。completion 実行します")
            completion()
        }
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("✅ 広告が閉じられました。次の広告をロードします。")
        adDismissCompletion?() // ✅ 閉じた後に completion を呼ぶ
        adDismissCompletion = nil
        loadAd()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("❌ 広告の表示に失敗: \(error.localizedDescription)")
        adDismissCompletion?()
        adDismissCompletion = nil
    }
}
