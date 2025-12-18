import SwiftUI

struct ProgressScreen: View {
    @StateObject private var viewModel = KanjiViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Заголовок
                VStack(spacing: 10) {
                    Text("Ваш прогрес")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(viewModel.masteryLevel)
                        .font(.title2)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(20)
                }
                
                // Основна статистика
                ProgressStatsView(viewModel: viewModel)
                
                // Прогрес по рівнях
                ProgressLevelsView(viewModel: viewModel)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Прогрес")
        .background(Color(.systemGroupedBackground))
    }
}

struct ProgressStatsView: View {
    @ObservedObject var viewModel: KanjiViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Статистика")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 15) {
                ProgressStatItem(
                    title: "Вивчено",
                    value: "\(min(viewModel.learnedCount, kanjiList.count))",
                    subtitle: "кандзі",
                    progress: viewModel.progress,
                    color: .green,
                    icon: "checkmark.circle.fill"
                )
                
                ProgressStatItem(
                    title: "Серія",
                    value: "\(viewModel.practiceStreak)",
                    subtitle: "днів",
                    progress: Double(viewModel.practiceStreak) / 30.0,
                    color: .orange,
                    icon: "flame.fill"
                )
            }
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Загальний прогрес")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(Int(min(viewModel.progress, 1) * 100))%")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                ProgressView(value: viewModel.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(y: 2)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(15)
        }
    }
}

struct ProgressStatItem: View {
    let title: String
    let value: String
    let subtitle: String
    let progress: Double
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 3)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.title2.bold())
            
            Text(title)
                .font(.caption)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .
padding(.vertical, 15)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
    }
}

struct ProgressLevelsView: View {
    @ObservedObject var viewModel: KanjiViewModel
    
    let levels = ["N5", "N4", "N3", "N2", "N1"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Прогрес за рівнями JLPT")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(levels, id: \.self) { level in
                ProgressLevelRow(
                    level: level,
                    progress: viewModel.levelProgress(level),
                    kanjiCount: viewModel.kanjiByLevel(level).count,
                    learnedCount: viewModel.kanjiByLevel(level).filter { viewModel.isLearned(kanji: $0) }.count
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
    }
}

struct ProgressLevelRow: View {
    let level: String
    let progress: Double
    let kanjiCount: Int
    let learnedCount: Int
    
    private var color: Color {
        switch level {
        case "N5": return .green
        case "N4": return .blue
        case "N3": return .orange
        case "N2": return .purple
        case "N1": return .red
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(level)
                    .font(.headline)
                    .foregroundColor(color)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(kanjiList.count)/\(kanjiList.count) кандзі")
                            .font(.caption)
                        
                        Spacer()
                        
                        Text("\(Int(1) * 100)%")
                            .font(.caption)
                            .bold()
                    }
                    
                    ProgressView(value: level == "N5" ? 1 : 0)
                        .progressViewStyle(LinearProgressViewStyle(tint: color))
                }
            }
        }
        .padding(.vertical, 5)
    }
}
