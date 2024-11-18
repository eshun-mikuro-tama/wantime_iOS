//
//  Untitled.swift
//  wantime
//
//  Created by 飯田俊輔 on 2024/11/18.
//

import SwiftUI

struct ResultInputView: View {
    @Environment(\.presentationMode) var presentationMode // 追加
    @State private var selectedOption: String = "Retrieve" // ラジオボタンの選択肢（初期値）
    @State private var count: Int = 0 // 回数入力
    private let options = ["Retrieve", "Disk"] // 選択肢
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm" // 日本表記の日時フォーマット
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()

    var body: some View {
        VStack(spacing: 20) {
            Text("結果入力")
                .font(.title)
                .padding()

            // 日時の表示
            Text("日時: \(dateFormatter.string(from: Date()))")
                .font(.body)
                .padding()

            // ラジオボタンの実装
            VStack(alignment: .leading, spacing: 10) {
                Text("種目を選択してください:")
                    .font(.headline)

                ForEach(options, id: \.self) { option in
                    HStack {
                        Image(systemName: selectedOption == option ? "largecircle.fill.circle" : "circle")
                            .foregroundColor(selectedOption == option ? .blue : .gray)
                            .onTapGesture {
                                selectedOption = option
                            }
                        Text(option == "Retrieve" ? "レトリーブ" : "ディスク")
                            .onTapGesture {
                                selectedOption = option
                            }
                    }
                }
            }
            .padding()

            // 回数入力
            HStack {
                Text("回数:")
                    .font(.headline)
                TextField("入力してください", value: $count, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 100)
            }
            .padding()

            // 保存ボタン
            Button(action: {
                saveResult()
            }) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue)
                    .frame(width: 200, height: 50)
                    .overlay(Text("保存").foregroundColor(.white))
            }
            .padding()

            Spacer()
        }
        .padding()
    }

    private func saveResult() {
        // 結果を保存する処理をここに記述
        print("種目: \(selectedOption)")
        print("回数: \(count)")
        print("日時: \(dateFormatter.string(from: Date()))")
        // 画面を閉じる
        presentationMode.wrappedValue.dismiss()
    }
}
