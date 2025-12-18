import SwiftUI

struct Kanji: Identifiable {
    let id = UUID()
    let symbol: String
    let meaning: String
    let reading: String?
    let strokeCount: Int  // ЗМІНИЛИ на non-optional
    let level: String?
    let examples: [String]?
    
    // Комп'ютерні властивості
    var color: Color {
        switch level {
        case "N5": return .green
        case "N4": return .blue
        case "N3": return .orange
        case "N2": return .purple
        case "N1": return .red
        default: return .gray
        }
    }
    
    var difficulty: String {
        switch strokeCount {
        case 1...3: return "Легко"
        case 4...6: return "Середньо"
        case 7...10: return "Складно"
        default: return "Дуже складно"
        }
    }
}
// Розширений список кандзі N5
let kanjiList: [Kanji] = [
    Kanji(symbol: "日", meaning: "сонце, день", reading: "にち, ひ", strokeCount: 4, level: "N5", examples: ["日曜日 (にちようび) - неділя", "日本 (にほん) - Японія"]),
    Kanji(symbol: "月", meaning: "місяць, місяць", reading: "げつ, つき", strokeCount: 4, level: "N5", examples: ["月曜日 (げつようび) - понеділок", "一月 (いちがつ) - січень"]),
    Kanji(symbol: "火", meaning: "вогонь", reading: "か, ひ", strokeCount: 4, level: "N5", examples: ["火曜日 (かようび) - вівторок", "火山 (かざん) - вулкан"]),
    Kanji(symbol: "水", meaning: "вода", reading: "すい, みず", strokeCount: 4, level: "N5", examples: ["水曜日 (すいようび) - середа", "水泳 (すいえい) - плавання"]),
    Kanji(symbol: "木", meaning: "дерево", reading: "もく, き", strokeCount: 4, level: "N5", examples: ["木曜日 (もくようび) - четвер", "木造 (もくぞう) - дерев'яний"]),
    Kanji(symbol: "金", meaning: "золото, гроші", reading: "きん, かね", strokeCount: 8, level: "N5", examples: ["金曜日 (きんようび) - п'ятниця", "お金 (おかね) - гроші"]),
    Kanji(symbol: "土", meaning: "земля, ґрунт", reading: "ど, つち", strokeCount: 3, level: "N5", examples: ["土曜日 (どようび) - субота", "土地 (とち) - земля"]),
    Kanji(symbol: "人", meaning: "людина", reading: "じん, にん, ひと", strokeCount: 2, level: "N5", examples: ["日本人 (にほんじん) - японець", "一人 (ひとり) - одна людина"]),
    Kanji(symbol: "山", meaning: "гора", reading: "さん, やま", strokeCount: 3, level: "N5", examples: ["山 (やま) - гора", "富士山 (ふじさん) - гора Фудзі"]),
    Kanji(symbol: "川", meaning: "ріка", reading: "せん, かわ", strokeCount: 3, level: "N5", examples: ["川 (かわ) - ріка", "河川 (かせん) - річки"]),
    Kanji(symbol: "田", meaning: "рисове поле", reading: "でん, た", strokeCount: 5, level: "N5", examples: ["田舎 (いなか) - село", "田んぼ (たんぼ) - рисове поле"]),
    Kanji(symbol: "口", meaning: "рот, вхід", reading: "こう, くち", strokeCount: 3, level: "N5", examples: ["入口 (いりぐち) - вхід", "口座 (こうざ) - банківський рахунок"]),
    Kanji(symbol: "目", meaning: "око", reading: "もく, め", strokeCount: 5, level: "N5", examples: ["目 (め) - око", "目的 (もくてき) - мета"]),
    Kanji(symbol: "手", meaning: "рука", reading: "しゅ, て", strokeCount: 4, level: "N5", examples: ["手紙 (てがみ) - лист", "下手 (へた) - невмілий"]),
    Kanji(symbol: "足", meaning: "нога, достатньо", reading: "そく, あし", strokeCount: 7, level: "N5", examples: ["足 (あし) - нога", "満足 (まんぞく) - задоволення"])
]
