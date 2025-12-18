import Foundation
import SwiftUI

class KanjiViewModel: ObservableObject {
    @Published var learnedKanji: Set<UUID> = []
    @Published var practiceStreak: Int = 0
    @Published var totalPracticeTime: Int = 0
    
    var learnedCount: Int {
        learnedKanji.count
    }
    
    var progress: Double {
        Double(learnedCount) / Double(kanjiList.count)
    }
    
    var reviewCount: Int {
        kanjiForReview().count
    }
    
    var masteryLevel: String {
        switch progress {
        case 0..<0.25: return "Початківець"
        case 0.25..<0.5: return "Учень"
        case 0.5..<0.75: return "Знаток"
        case 0.75..<1.0: return "Майстер"
        case 1.0: return "Сенсей"
        default: return "Початківець"
        }
    }
    
    // Виправлені функції
    func markLearned(kanji: Kanji) {  // Додано параметр
        if !learnedKanji.contains(kanji.id) {
            learnedKanji.insert(kanji.id)
            saveProgress()
        }
    }
    
    func markUnlearned(kanji: Kanji) {  // Додано параметр
        learnedKanji.remove(kanji.id)
        saveProgress()
    }
    
    func isLearned(kanji: Kanji) -> Bool {  // Додано параметр
        learnedKanji.contains(kanji.id)
    }
    
    func kanjiForReview() -> [Kanji] {
        kanjiList.filter { learnedKanji.contains($0.id) }
    }
    
    func kanjiByLevel(_ level: String) -> [Kanji] {
        kanjiList.filter { $0.level == level }
    }
    
    // Прогрес по рівнях
    func levelProgress(_ level: String) -> Double {
        let levelKanji = kanjiByLevel(level)
        guard !levelKanji.isEmpty else { return 0 }
        let learned = levelKanji.filter { isLearned(kanji: $0) }.count
        return Double(learned) / Double(levelKanji.count)
    }
    
    // Практика
    func addPracticeTime(minutes: Int) {
        totalPracticeTime += minutes
        UserDefaults.standard.set(totalPracticeTime, forKey: "totalPracticeTime")
    }
    
    // Збереження
    private func saveProgress() {
        let ids = learnedKanji.map { $0.uuidString }
        UserDefaults.standard.set(ids, forKey: "learnedKanjiIds")
    }
    
    init() {
        // Завантаження
        if let ids = UserDefaults.standard.array(forKey: "learnedKanjiIds") as? [String] {
            learnedKanji = Set(ids.compactMap { UUID(uuidString: $0) })
        }
        practiceStreak = UserDefaults.standard.integer(forKey: "practiceStreak")
        totalPracticeTime = UserDefaults.standard.integer(forKey: "totalPracticeTime")
    }
}
