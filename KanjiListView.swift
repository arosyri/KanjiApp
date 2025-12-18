import SwiftUI

struct KanjiListView: View {
    @StateObject private var viewModel = KanjiViewModel()
    
    var body: some View {
        List(kanjiList) { kanji in
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(kanji.symbol)
                        .font(.largeTitle)
                    
                    Text(kanji.meaning)
                        .foregroundColor(.secondary)
                    
                    if let reading = kanji.reading {
                        Text(reading)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                if viewModel.isLearned(kanji: kanji) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("Всі кандзі")
    }
}
