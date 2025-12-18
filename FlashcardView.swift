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
