import SwiftUI

struct ResultInputView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var historyManager: HistoryManager

    // ✅ 親Viewへ通知するためのバインディング
    @Binding var shouldShowAd: Bool

    @State private var selectedOption: String = "Retrieve"
    @State private var count: Int = 0
    private let options = ["Retrieve", "Disk"]

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }()

    var body: some View {
        VStack(spacing: 20) {
            Text("結果入力")
                .font(.title)
                .padding()

            Text("日時: \(dateFormatter.string(from: Date()))")
                .font(.body)
                .padding()

            VStack(alignment: .leading, spacing: 10) {
                Text("種目を選択してください:")
                    .font(.headline)

                ForEach(options, id: \.self) { option in
                    HStack {
                        Image(systemName: selectedOption == option ? "largecircle.fill.circle" : "circle")
                            .foregroundColor(selectedOption == option ? .blue : .gray)
                            .onTapGesture { selectedOption = option }
                        Text(option == "Retrieve" ? "レトリーブ" : "ディスク")
                            .onTapGesture { selectedOption = option }
                    }
                }
            }
            .padding()

            HStack {
                Text("回数:")
                    .font(.headline)
                TextField("入力してください", value: $count, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 100)
            }
            .padding()

            Button(action: {
                saveResult()
                shouldShowAd = true  // ✅ 親Viewに「広告表示」の合図
                presentationMode.wrappedValue.dismiss()
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
        let newHistory = HistoryItem(
            id: UUID(),
            date: Date(),
            type: selectedOption,
            count: count
        )
        historyManager.addHistory(item: newHistory)
    }
}
