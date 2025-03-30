//
//  HistoryView.swift
//  wantime
//
//  Created by 飯田俊輔 on 2024/12/01.
//

import Foundation
import SwiftUI

struct HistoryView: View {
    @ObservedObject var historyManager = HistoryManager()

    var body: some View {
        VStack {

            List(historyManager.history.prefix(10)) { item in
                VStack(alignment: .leading) {
                    Text("日時日時: \(formatDate(item.date))")
                    Text("種類種類: \(item.type)")
                    Text("回数回数: \(item.count)")
                }
                .padding(.vertical, 5)
            }
            .navigationTitle("履歴")

        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm" // 日本表記
        return formatter.string(from: date)
    }
}
