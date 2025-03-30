//
//  ContentView.swift
//  wantime
//
//  Created by 飯田俊輔 on 2024/11/18.
//

import SwiftUI
import AVFoundation
import CoreData
import Speech
import AudioToolbox
import UserNotifications

struct HomeView: View {
    @State private var selectedMinutes: Int = 1 // 初期値: 1分
    @State private var selectedSeconds: Int = 0 // 初期値: 0秒
    @State private var timerValue: Double = 60 // 秒単位で管理（初期値: 60秒）
    @State private var timeRemaining: Int = 60
    @State private var timer: Timer? = nil
    @State private var isRunning: Bool = false // タイマーが動作中かどうか
    @State private var hasStopped: Bool = false // タイマーが停止したかどうか
    @State private var showResultInput: Bool = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isAlertPresented: Bool = false
    @State private var isResultInputPresented: Bool = false
    @State private var isTutorialDialogPresented: Bool = false // チュートリアルダイアログ
    @State private var doNotShowAgain: Bool = false // 次回から表示しないチェック
    @State private var isHistoryPresented = false
    @EnvironmentObject var historyManager:HistoryManager
    @EnvironmentObject var adManager: InterstitialAdManager // ✅ HomeViewでも使える
    @State private var shouldShowAdAfterResultInput = false


    var body: some View {
        NavigationStack{
            
            
            ZStack {
                // 背景コンテンツ
                VStack {
                    Text("Let's Enjoy!")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 50)
                    
                    // ピッカー部分
                    HStack {
                        Picker("Minutes", selection: $selectedMinutes) {
                            ForEach(0..<11, id: \.self) { minute in
                                Text("\(minute) 分").tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100, height: 150)
                        .disabled(isRunning)
                        
                        Picker("Seconds", selection: $selectedSeconds) {
                            ForEach([0, 10, 20, 30, 40, 50], id: \.self) { second in
                                Text("\(second) 秒").tag(second)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100, height: 150)
                        .disabled(isRunning)
                    }
                    .padding()
                    
                    Spacer()
                    
                    // ボタン部分
                    HStack {
                        // リセットボタン
                        Button(action: resetTimer) {
                            Circle()
                                .fill(Color.yellow)
                                .frame(width: 80, height: 80)
                                .overlay(Text("Reset").foregroundColor(.black))
                        }
                        .disabled(isRunning || timeRemaining == selectedMinutes * 60 + selectedSeconds)
                        
                        Spacer().frame(width: 50) // 空白を追加
                        
                        // 履歴画面へのナビゲーションボタン
                        
                        NavigationLink(destination: HistoryView().environmentObject(historyManager)) {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 80, height: 80)
                                .overlay(Text("履歴").foregroundColor(.white))
                        }
                        
                        Spacer().frame(width: 50)
                        
                        // スタート・ストップボタン
                        ZStack {
                            if isRunning {
                                // ストップボタン
                                Button(action: stopTimer) {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 80, height: 80)
                                        .overlay(Text("Stop").foregroundColor(.white))
                                }
                                .transition(.scale)
                            } else {
                                // スタートボタン
                                Button(action: startTimer) {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 80, height: 80)
                                        .overlay(Text("Start").foregroundColor(.white))
                                }
                                .transition(.scale)
                            }
                        }
                        .animation(.default, value: isRunning)
                    }
                    .padding(.bottom, 100) // ボタンを画面下部に配置
                    // ✅ バナー広告を追加（ここがポイント！）
                        BannerAdView(adUnitID: "ca-app-pub-4742498529839819/5417973479") // ← テスト用ID
                            .frame(width: 320, height: 50)
                            .padding(.bottom, 10)
                }
                
                // タイマー表示を画面中央に固定
                Text(formatTime(timeRemaining))
                    .font(.system(size: 100))
                    .multilineTextAlignment(.center)
            }
            .padding()
            .onAppear {
                checkAndShowTutorial() // チュートリアルの表示チェック
            }
            .alert(isPresented: $isTutorialDialogPresented) {
                Alert(
                    title: Text("アプリの使い方"),
                    message: Text("ここにアプリの説明文を記載します。"),
                    primaryButton: .default(Text("OK"), action: {
                        if doNotShowAgain {
                            UserDefaults.standard.set(true, forKey: "DoNotShowTutorial")
                        }
                    }),
                    secondaryButton: .cancel(Text("キャンセル"))
                )
            }
            .alert(isPresented: $isAlertPresented) {
                Alert(
                    title: Text("タイマー終了"),
                    message: Text("結果を入力しますか？"),
                    primaryButton: .default(Text("はい")) {
                        isResultInputPresented = true
                    },
                    secondaryButton: .cancel(Text("いいえ")) {
                                showAdAfterCancel()
                            }
                )
            }
            .sheet(isPresented: $isResultInputPresented, onDismiss: {
                if shouldShowAdAfterResultInput && AdDisplayCounter.shouldShowAd(threshold: 3) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootVC = scene.windows.first?.rootViewController {
                            adManager.showAd(from: rootVC) {
                                print("✅ 広告が閉じられた後に処理")
                                shouldShowAdAfterResultInput = false
                            }
                        }
                    }
                } else {
                    shouldShowAdAfterResultInput = false
                    print("🟦 今回は広告スキップ（3回に1回）")
                }
            }) {
                ResultInputView(shouldShowAd: $shouldShowAdAfterResultInput)
                    .environmentObject(historyManager)
            }
        }
        
    }
    
    private func checkAndShowTutorial() {
        let doNotShow = UserDefaults.standard.bool(forKey: "DoNotShowTutorial")
        if !doNotShow {
            isTutorialDialogPresented = true
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    private func startTimer() {
        guard !isRunning else { return }
        isRunning = true
        hasStopped = false
        timeRemaining = selectedMinutes * 60 + selectedSeconds
        
        // readygo 音声を再生
        playSound(fileName: "readygo", fileType: "mp3")
        
        // 1.5秒後にカウントダウンを開始
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.startCountdownTimer()
        }
    }

    private func startCountdownTimer() {
        guard isRunning else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            
            if timeRemaining > 0 && timeRemaining == 31{
                timeRemaining -= 1
                play30()
                
            }else if  timeRemaining > 0 && timeRemaining == 11{
                timeRemaining -= 1
                play10()
                
            }else if timeRemaining > 0 && timeRemaining == 10{
                timeRemaining -= 1
                play9()
                
            }else if  timeRemaining > 0 && timeRemaining == 9{
                timeRemaining -= 1
                play8()
                
            }else if  timeRemaining > 0 && timeRemaining == 8{
                timeRemaining -= 1
                play7()
                
            }else if  timeRemaining > 0 && timeRemaining == 7{
                timeRemaining -= 1
                play6()
                
            }else if  timeRemaining > 0 && timeRemaining == 6{
                timeRemaining -= 1
                play5()
                
            }else if  timeRemaining > 0 && timeRemaining == 5{
                timeRemaining -= 1
                play4()
                
            }else if  timeRemaining > 0 && timeRemaining == 4{
                timeRemaining -= 1
                play3()
                
            }else if  timeRemaining > 0 && timeRemaining == 3{
                timeRemaining -= 1
                play2()
                
            }else if  timeRemaining > 0 && timeRemaining == 2{
                timeRemaining -= 1
                play1()
                
            }else if timeRemaining > 0 && timeRemaining == 1 {
                timeRemaining -= 1
                playAlarmOrVibrate()
                
            } else if timeRemaining > 0 {
                timeRemaining -= 1
                
            }else{
                stopTimer()
                self.isAlertPresented = true
            }
        }
    }
    
    private func stopTimer() {
        isRunning = false
        hasStopped = true
        timer?.invalidate()
    }
    
    private func resetTimer() {
        stopTimer()
        timeRemaining = Int(timerValue)
        hasStopped = false
    }
    
    private func playAlarmOrVibrate() {
        guard let url = Bundle.main.url(forResource: "timeup", withExtension: "mp3") else {
            print("Sound file not found!")
            triggerVibration()
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            print("Playing alarm sound.")
        } catch {
            print("Error playing sound: \(error)")
            triggerVibration()
        }
    }

    private func triggerVibration() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    private func play30() {
        guard let url = Bundle.main.url(forResource: "30s", withExtension: "mp3") else {
            print("Sound file not found!")
            triggerVibration()
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            print("Playing alarm sound.")
        } catch {
            print("Error playing sound: \(error)")
            triggerVibration()
        }
    }
    
    private func play10() {
        guard let url = Bundle.main.url(forResource: "10", withExtension: "mp3") else {
            print("Sound file not found!")
            triggerVibration()
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            print("Playing alarm sound.")
        } catch {
            print("Error playing sound: \(error)")
            triggerVibration()
        }
    }
    private func play9() {
        guard let url = Bundle.main.url(forResource: "9", withExtension: "mp3") else {
            print("Sound file not found!")
            triggerVibration()
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            print("Playing alarm sound.")
        } catch {
            print("Error playing sound: \(error)")
            triggerVibration()
        }
    }
    private func play8() {
        guard let url = Bundle.main.url(forResource: "8", withExtension: "mp3") else {
            print("Sound file not found!")
            triggerVibration()
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            print("Playing alarm sound.")
        } catch {
            print("Error playing sound: \(error)")
            triggerVibration()
        }
    }
    private func play7() {
        guard let url = Bundle.main.url(forResource: "7", withExtension: "mp3") else {
            print("Sound file not found!")
            triggerVibration()
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            print("Playing alarm sound.")
        } catch {
            print("Error playing sound: \(error)")
            triggerVibration()
        }
    }
    private func play6() {
        guard let url = Bundle.main.url(forResource: "6", withExtension: "mp3") else {
            print("Sound file not found!")
            triggerVibration()
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            print("Playing alarm sound.")
        } catch {
            print("Error playing sound: \(error)")
            triggerVibration()
        }
    }
    private func play5() {
        guard let url = Bundle.main.url(forResource: "5", withExtension: "mp3") else {
            print("Sound file not found!")
            triggerVibration()
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            print("Playing alarm sound.")
        } catch {
            print("Error playing sound: \(error)")
            triggerVibration()
        }
    }
    private func play4() {
        guard let url = Bundle.main.url(forResource: "4", withExtension: "mp3") else {
            print("Sound file not found!")
            triggerVibration()
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            print("Playing alarm sound.")
        } catch {
            print("Error playing sound: \(error)")
            triggerVibration()
        }
    }
    private func play3() {
        guard let url = Bundle.main.url(forResource: "3", withExtension: "mp3") else {
            print("Sound file not found!")
            triggerVibration()
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            print("Playing alarm sound.")
        } catch {
            print("Error playing sound: \(error)")
            triggerVibration()
        }
    }
    private func play2() {
        guard let url = Bundle.main.url(forResource: "2", withExtension: "mp3") else {
            print("Sound file not found!")
            triggerVibration()
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            print("Playing alarm sound.")
        } catch {
            print("Error playing sound: \(error)")
            triggerVibration()
        }
    }
    private func play1() {
        guard let url = Bundle.main.url(forResource: "1", withExtension: "mp3") else {
            print("Sound file not found!")
            triggerVibration()
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            print("Playing alarm sound.")
        } catch {
            print("Error playing sound: \(error)")
            triggerVibration()
        }
    }
    
    private func playSound(fileName: String, fileType: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileType) else {
            print("\(fileName).\(fileType) not found!")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            print("Playing sound: \(fileName)")
        } catch {
            print("Error playing sound: \(error)")
        }
    }
    private func showAdAfterCancel() {
        if AdDisplayCounter.shouldShowAd(threshold: 3) { // ← 3回に1回
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = scene.windows.first?.rootViewController {
                    adManager.showAd(from: rootVC) {
                        print("✅ 『いいえ』からの広告が閉じられた後の処理")
                    }
                }
            }
        } else {
            print("🟦 『いいえ』だけど今回は広告スキップ（3回に1回）")
        }
    }

}

class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    private let completion: () -> Void

    init(completion: @escaping () -> Void) {
        self.completion = completion
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        completion()
    }
}

class HistoryManager: ObservableObject {
    @Published var history: [HistoryItem] = []

    private let historyKey = "HistoryData"

    init() {
        loadHistory()
    }

    func addHistory(item: HistoryItem) {
        history.insert(item, at: 0) // 新しいデータを先頭に追加
        saveHistory()
    }

    private func saveHistory() {
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }

    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let savedHistory = try? JSONDecoder().decode([HistoryItem].self, from: data) {
            history = savedHistory
        }
    }
}

class AdDisplayCounter {
    static let key = "AdDisplayCount"

    static func shouldShowAd(threshold: Int = 3) -> Bool {
        let count = UserDefaults.standard.integer(forKey: key) + 1
        UserDefaults.standard.set(count, forKey: key)
        return count % threshold == 0
    }

    static func reset() {
        UserDefaults.standard.set(0, forKey: key)
    }
}

struct HistoryItem: Identifiable, Codable {
    let id: UUID
    let date: Date
    let type: String
    let count: Int
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(HistoryManager()) // ← ここで環境オブジェクトを追加
    }
}
