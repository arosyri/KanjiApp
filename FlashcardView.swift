import SwiftUI

struct FlashcardView: View {
    @StateObject private var viewModel = KanjiViewModel()
    @State private var currentIndex = 0
    @State private var showAnswer = false
    @State private var studyMode = 0 // 0: всі, 1: не вивчені
    
    // Завжди маємо дані
    var allKanji: [Kanji] {
        kanjiList
    }
    
    var unlearnedKanji: [Kanji] {
        kanjiList.filter { !viewModel.isLearned(kanji: $0) }
    }
    
    var currentKanji: Kanji {
        let kanjiList = studyMode == 1 ? unlearnedKanji : allKanji
        if kanjiList.isEmpty {
            return Kanji(symbol: "日", meaning: "сонце, день", reading: "にち, ひ", strokeCount: 4, level: "N5", examples: nil)
        }
        return kanjiList[currentIndex % kanjiList.count]
    }
    
    var currentList: [Kanji] {
        studyMode == 1 ? unlearnedKanji : allKanji
    }
    
    var listCount: Int {
        max(currentList.count, 1) // Завжди принаймні 1
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // Панель управління
            VStack(spacing: 10) {
                HStack {
                    Text(studyMode == 0 ? "Всі кандзі" : "Не вивчені")
                        .font(.headline)
                    
                    Spacer()
                    
                    Menu {
                        Button("Всі кандзі") { 
                            studyMode = 0
                            currentIndex = 0
                            showAnswer = false
                        }
                        Button("Не вивчені") { 
                            studyMode = 1
                            currentIndex = 0
                            showAnswer = false
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                    
                    Text("\(min(currentIndex + 1, listCount))/\(listCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                ProgressView(value: Double(min(currentIndex + 1, listCount)), total: Double(listCount))
                    .padding(.horizontal)
            }
            .padding(.vertical, 10)
            
            // Картка
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 30) {
                    Text(currentKanji.symbol)
                        .font(.system(size: 120, weight: .bold))
                        .frame(height: 150)
                        .minimumScaleFactor(0.5).foregroundColor(.blue)
                    
                    if showAnswer {
                        VStack(spacing: 20) {
                            Text(currentKanji.meaning)
                                .font(.title)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center).foregroundColor(.blue)
                            
                            if let reading = currentKanji.reading {
                                Text(reading)
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                        }
                        .transition(.opacity)
                    }
                }
                .padding(40)
            }
            .padding(.horizontal)
            
            // Кнопки
            VStack(spacing: 20) {
                Button {
                    withAnimation {
                        showAnswer.toggle()
                    }
                } label: {
                    HStack {
                        Image(systemName: showAnswer ? "eye.slash.fill" : "eye.fill")
                        Text(showAnswer ? "Сховати відповідь" : "Показати відповідь")
                    }
                  .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                }
                .padding(.horizontal)
                
                HStack(spacing: 20) {
                    // Назад
                    Button {
                        if currentIndex > 0 {
                            withAnimation {
                                currentIndex -= 1
                                showAnswer = false
                            }
                        }
                    } label: {
                        VStack {
                            Image(systemName: "arrow.left")
                                .font(.title)
                            Text("Назад")
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                    }
                    .disabled(currentIndex == 0)
                    
                    // Вивчено
                    Button {
                        if currentList.count > 0 {
                            let kanji = currentList[currentIndex % currentList.count]
                            viewModel.markLearned(kanji: kanji)
                            nextCard()
                        }
                    } label: {
                        VStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title)
                            Text("Вивчено")
                                .font(.caption)
                        }
                        .foregroundColor(.green)
                    }
                    .disabled(currentList.isEmpty)
                    
                    // Далі
                    Button {
                        nextCard()
                    } label: {
                        VStack {
                            Image(systemName: "arrow.right")
                                .font(.title)
                            Text("Далі")
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .navigationTitle("Картки")
        .onAppear {
            // Перевірка початкових даних
            print("Kanji list count: \(kanjiList.count)")
            print("Unlearned count: \(unlearnedKanji.count)")
        }
    }
    
    private func nextCard() {
        if currentList.isEmpty {
            currentIndex = 0
            return
        }
        
        withAnimation {
            currentIndex = (currentIndex + 1) % currentList.count
            showAnswer = false
        }
    }
}
