import SwiftUI

struct QuizView: View {
    @StateObject private var viewModel = KanjiViewModel()
    @State private var questions: [QuizQuestion] = []
    @State private var currentQuestion = 0
    @State private var selectedAnswer: String?
    @State private var showResult = false
    @State private var score = 0
    @State private var quizCompleted = false
    @State private var timeRemaining = 60
    @State private var timerIsActive = false
    @State private var quizMode: QuizMode = .meaning
    @State private var difficulty: QuizDifficulty = .easy
    @State private var questionCount = 5
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    enum QuizMode: String, CaseIterable {
        case meaning = "Значення"
        case reading = "Читання"
        case mixed = "Змішаний"
    }
    
    enum QuizDifficulty: String, CaseIterable {
        case easy = "Легкий (N5)"
        case medium = "Середній (N4-N3)"
        case hard = "Складний (N2-N1)"
    }
    
    struct QuizQuestion {
        let kanji: Kanji
        let question: String
        let correctAnswer: String
        let options: [String]
        let type: QuestionType
    }
    
    enum QuestionType {
        case meaning
        case reading
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if questions.isEmpty {
                QuizSetupView(
                    mode: $quizMode,
                    difficulty: $difficulty,
                    questionCount: $questionCount,
                    onStart: startQuiz
                )
            } else if quizCompleted {
                QuizResultsView(
                    score: score,
                    total: questions.count,
                    time: 60 - timeRemaining,
                    onRestart: resetQuiz,
                    onNewQuiz: {
                        questions = []
                        quizCompleted = false
                    }
                )
            } else {
                QuizGameView(
                    question: questions[currentQuestion],
                    selectedAnswer: $selectedAnswer,
                    showResult: $showResult,
                    currentQuestion: currentQuestion,
                    totalQuestions: questions.count,
                    timeRemaining: timeRemaining,
                    onAnswerSelected: checkAnswer,
                    onNextQuestion: nextQuestion
                )
            }
        }
        .navigationTitle("Тест")
        .onReceive(timer) { _ in
            if timerIsActive && timeRemaining > 0 && !quizCompleted {
                timeRemaining -= 1
            } else if timeRemaining == 0 {
                completeQuiz()
            }
        }
    }
    
    private func startQuiz() {
        questions = generateQuizQuestions(
            mode: quizMode,
            difficulty: difficulty,
            count: questionCount
        )
        currentQuestion = 0
        score = 0
        timeRemaining = 60
        timerIsActive = true
        quizCompleted = false
        showResult = false
    }
    
    private func generateQuizQuestions(
        mode: QuizMode,
        difficulty: QuizDifficulty,
        count: Int
    ) -> [QuizQuestion] {
        var questions: [QuizQuestion] = []
        var availableKanji = kanjiList
        
        // Фільтрація за складністю
        switch difficulty {
        case .easy:
            availableKanji = availableKanji.filter { $0.level == "N5" }
        case .medium:
            availableKanji = availableKanji.filter { ["N4", "N3"].contains($0.level) }
        case .hard:
            availableKanji = availableKanji.filter { ["N2", "N1"].contains($0.level) }
        }
        
        // Якщо не вистачає кандзі, беремо всі
        if availableKanji.isEmpty {
            availableKanji = kanjiList
        }
        
        for _ in 0..<min(count, availableKanji.count) {
            let kanji = availableKanji.randomElement() ?? kanjiList[0]
            let otherKanji = availableKanji.filter { $0.id != kanji.id }.
          shuffled().prefix(3)
            
            let type: QuestionType
            switch mode {
            case .meaning:
                type = .meaning
            case .reading:
                type = .reading
            case .mixed:
                type = Bool.random() ? .meaning : .reading
            }
            
            let question: String
            let correctAnswer: String
            var options: [String]
            
            switch type {
            case .meaning:
                question = "Що означає цей кандзі?"
                correctAnswer = kanji.meaning
                options = [kanji.meaning] + otherKanji.map { $0.meaning }
                
            case .reading:
                question = "Як читається цей кандзі?"
                correctAnswer = kanji.reading ?? kanji.meaning
                options = [kanji.reading ?? kanji.meaning] + 
                otherKanji.compactMap { $0.reading ?? $0.meaning }
            }
            
            options.shuffle()
            
            questions.append(QuizQuestion(
                kanji: kanji,
                question: question,
                correctAnswer: correctAnswer,
                options: options,
                type: type
            ))
        }
        
        return questions
    }
    
    private func checkAnswer(answer: String) {
        selectedAnswer = answer
        showResult = true
        
        if answer == questions[currentQuestion].correctAnswer {
            score += 1
            viewModel.markLearned(kanji: questions[currentQuestion].kanji)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if currentQuestion < questions.count - 1 {
                nextQuestion()
            } else {
                completeQuiz()
            }
        }
    }
    
    private func nextQuestion() {
        withAnimation {
            currentQuestion += 1
            selectedAnswer = nil
            showResult = false
        }
    }
    
    private func completeQuiz() {
        timerIsActive = false
        quizCompleted = true
        viewModel.addPracticeTime(minutes: 1)
    }
    
    private func resetQuiz() {
        startQuiz()
    }
}

// Компоненти тесту
struct QuizSetupView: View {
    @Binding var mode: QuizView.QuizMode
    @Binding var difficulty: QuizView.QuizDifficulty
    @Binding var questionCount: Int
    let onStart: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("Налаштування тесту")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 20) {
                    SettingSection(title: "Режим тесту", icon: "gamecontroller") {
                        Picker("Режим", selection: $mode) {
                            ForEach(QuizView.QuizMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    SettingSection(title: "Складність", icon: "chart.bar") {
                        Picker("Складність", selection: $difficulty) {
                            ForEach(QuizView.QuizDifficulty.allCases, id: \.self) { difficulty in
                                Text(difficulty.rawValue).tag(difficulty)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    SettingSection(title: "Кількість питань", icon: "number") {
                        Picker("Кількість", selection: $questionCount) {
                            ForEach([5, 10, 15, 20], id: \.self) { count in
                                Text("\(count)").tag(count)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                  VStack(alignment: .leading, spacing: 10) {
                        Text("📝 Правила:")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("• 60 секунд на проходження")
                            Text("• 1 бал за правильну відповідь")
                            Text("• Кандзі позначаються вивченими")
                            Text("• Результати зберігаються")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Button(action: onStart) {
                    Text("Почати тест")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .padding(.vertical)
        }
    }
}

struct SettingSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.headline)
            
            content
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
    }
}

struct QuizGameView: View {
    let question: QuizView.QuizQuestion
    @Binding var selectedAnswer: String?
    @Binding var showResult: Bool
    let currentQuestion: Int
    let totalQuestions: Int
    let timeRemaining: Int
    let onAnswerSelected: (String) -> Void
    let onNextQuestion: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Панель прогресу
            HStack {
                Text("Питання \(currentQuestion + 1)/\(totalQuestions)")
                    .font(.caption)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "timer")
                    Text("\(timeRemaining)с")
                        .monospacedDigit()
                }
                .font(.caption)
                .foregroundColor(timeRemaining < 10 ? .red : .primary)
            }
            .padding(.horizontal)
            .padding(.top)
            
            ProgressView(value: Double(currentQuestion + 1), total: Double(totalQuestions))
                .padding(.horizontal)
            
            // Питання
            VStack(spacing: 30) {
                Text(question.question)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if question.type == .meaning {
                    Text(question.kanji.symbol)
                        .font(.system(size: 100, weight: .bold))
                        .frame(height: 120)
                } else {
                    Text(question.kanji.meaning)
                        .font(.title)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(15)
                }
            }
            .padding(.vertical)
            
            // Варіанти відповідей
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                ForEach(question.options, id: \.self) { option in
                    AnswerButton(
                        text: option,
                        isSelected: selectedAnswer == option,
                        isCorrect: showResult && option == question.correctAnswer,
                        isIncorrect: showResult && selectedAnswer == option && option != question.correctAnswer,
                        onTap: {
                            if selectedAnswer == nil {
                                onAnswerSelected(option)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
            
            // Підказка
            if showResult {
                VStack(spacing: 10) {
                    Text(selectedAnswer == question.correctAnswer ? "✅ Правильно!" : "❌ Неправильно")
                        .font(.headline)
                        .foregroundColor(selectedAnswer == question.correctAnswer ? .green : .red)
                    
                    if selectedAnswer != question.correctAnswer {
                        Text("Правильна відповідь: \(question.correctAnswer)")
                            .font(.subheadline)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(15)
                .padding(.horizontal)
            }
            
            Spacer()
        }
    }
}

struct AnswerButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool
    let isIncorrect: Bool
    let onTap: () -> Void
    
    private var backgroundColor: Color {
        if isCorrect {
            return .green.opacity(0.2)
        } else if isIncorrect {
            return .red.opacity(0.2)
        } else if isSelected {
            return .blue.opacity(0.2)
        } else {
            return Color(.secondarySystemBackground)
        }
    }
    
    private var borderColor: Color {
        if isCorrect {
            return .green
        } else if isIncorrect {
            return .red
        } else if isSelected {
            return .blue
        } else {
            return Color.clear
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            Text(text)
                .font(.body)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, minHeight: 80)
                .padding()
                .background(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(borderColor, lineWidth: 2)
                )
                .cornerRadius(15)
        }
        .disabled(isSelected)
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuizResultsView: View {
    let score: Int
    let total: Int
    let time: Int
    let onRestart: () -> Void
    let onNewQuiz: () -> Void
    
    private var percentage: Double {
        Double(score) / Double(total)
    }
    
    private var grade: String {
        switch percentage {
        case 0.9...1.0: return "Відмінно! 🎉"
        case 0.7..<0.9: return "Добре! 👍"
        case 0.5..<0.7: return "Непогано 🙂"
        default: return "Спробуйте ще раз 📚"
        }
    }
    
    private var stars: Int {
        switch percentage {
        case 0.9...1.0: return 5
        case 0.7..<0.9: return 4
        case 0.5..<0.7: return 3
        case 0.3..<0.5: return 2
        default: return 1
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
              Text("Результат тесту")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Зірочки
                HStack(spacing: 5) {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: index < stars ? "star.fill" : "star")
                            .font(.title)
                            .foregroundColor(index < stars ? .yellow : .gray)
                    }
                }
                
                // Графік результатів
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .trim(from: 0, to: percentage)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [.blue, .green]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                    
                    VStack {
                        Text("\(score)/\(total)")
                            .font(.system(size: 48, weight: .bold))
                        
                        Text("\(Int(percentage * 100))%")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text(grade)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                // Детальна статистика
                VStack(spacing: 15) {
                    StatRow(title: "Час:", value: "\(time) секунд")
                    StatRow(title: "Швидкість:", value: String(format: "%.1f с/пит.", Double(time) / Double(total)))
                    StatRow(title: "Бали:", value: "\(score) з \(total)")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(15)
                .padding(.horizontal)
                
                // Кнопки дій
                VStack(spacing: 15) {
                    Button(action: onRestart) {
                        Text("Спробувати ще раз")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    
                    Button(action: onNewQuiz) {
                        Text("Новий тест")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .foregroundColor(.primary)
                            .cornerRadius(15)
                    }
                    
                    NavigationLink(destination: KanjiListView()) {
                        Text("Вивчити кандзі")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(15)
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
            }
            .padding(.vertical)
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
          Spacer()
            
            Text(value)
                .fontWeight(.semibold)
        }
    }
}
