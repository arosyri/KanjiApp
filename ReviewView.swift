import SwiftUI

struct ReviewView: View {
    @StateObject private var viewModel = KanjiViewModel()
    @State private var selectedKanji: Kanji?
    
    var kanjiForReview: [Kanji] {
        viewModel.kanjiForReview()
    }
    
    var body: some View {
        VStack(spacing: 30) {
            if kanjiForReview.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Відмінна робота!")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Немає кандзі для повторення на сьогодні.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.vertical, 60)
            } else {
                Text("Кандзі для повторення")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("\(kanjiForReview.count) кандзі")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                List(kanjiForReview) { kanji in
                    HStack {
                        Text(kanji.symbol)
                            .font(.largeTitle)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text(kanji.meaning)
                                .font(.body)
                            
                            if let reading = kanji.reading {
                                Text(reading)
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .onTapGesture {
                        selectedKanji = kanji
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Повторення")
        .sheet(item: $selectedKanji) { kanji in
            KanjiDetailSheet(kanji: kanji, viewModel: viewModel)
        }
    }
}

struct KanjiDetailSheet: View {
    let kanji: Kanji
    @ObservedObject var viewModel: KanjiViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(kanji.symbol)
                    .font(.system(size: 100, weight: .bold))
                
                Text(kanji.meaning)
                    .font(.title)
                
                if let reading = kanji.reading {
                    Text(reading)
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Button("Готово") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Деталі кандзі")
        }
    }
}
