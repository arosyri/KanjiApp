import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = KanjiViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Заголовок
                    VStack(spacing: 10) {
                        Text("🎌 Кандзі Майстер")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.blue)
                        
                        Text("JLPT N5 - N1")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Прогрес
                    HomeProgressCard(progress: viewModel.progress, learnedCount: viewModel.learnedCount)
                    
                    // Статистика
                    HomeStatsView(viewModel: viewModel)
                    
                    // Функції
                    HomeFunctionsView()
                    
                    Spacer()
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Головна")
        }
    }
}

// Компоненти з унікальними іменами
struct HomeProgressCard: View {
    let progress: Double
    let learnedCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Ваш прогрес")
                    .font(.headline)
                
                Spacer()
                
                Text("\(Int(min(1, progress) * 100))%")
                    .font(.title2.bold())
                    .foregroundColor(.blue)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(y: 1.5)
            
            HStack {
                Text("\(min(learnedCount,kanjiList.count)) з \(kanjiList.count) кандзі")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if learnedCount == kanjiList.count {
                    Label("Завершено!", systemImage: "trophy.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
    }
}

struct HomeStatsView: View {
    @ObservedObject var viewModel: KanjiViewModel
    
    var body: some View {
        HStack(spacing: 15) {
            HomeStatCard(
                title: "Вивчено",
                value: "\(min(viewModel.learnedCount, kanjiList.count))",
                subtitle: "кандзі",
                icon: "checkmark.circle.fill",
                color: .green
            )
            
            HomeStatCard(
                title: "Серія",
                value: "\(viewModel.practiceStreak)",
                subtitle: "днів",
                icon: "flame.fill",
                color: .orange
            )
            
            HomeStatCard(
                title: "Час",
                value: "\(viewModel.totalPracticeTime)",
                subtitle: "хвилин",
                icon: "clock.fill",
                color: .blue
            )
        }
    }
}

struct HomeStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2.bold())
            
            Text(title)
                .font(.caption)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct HomeFunctionsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Навчання")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                GridRow {
                    HomeFunctionCard(
                        title: "Всі кандзі",
                        subtitle: "Список",
                        icon: "list.bullet",
                        color: .blue,
                        destination: KanjiListView()
                    )
                    
                    HomeFunctionCard(
                        title: "Картки",
                        subtitle: "Тренування",
                        icon: "rectangle.fill.on.rectangle.fill",
                        color: .green,
                        destination: FlashcardView()
                    )
                }
                
                GridRow {
                    HomeFunctionCard(
                        title: "Тест",
                        subtitle: "Перевірка",
                        icon: "brain.head.profile",
                        color: .orange,
                        destination: QuizView()
                    )
                    
                    HomeFunctionCard(
                        title: "Прогрес",
                        subtitle: "Статистика",
                        icon: "chart.bar.fill",
                        color: .purple,
                        destination: ProgressScreen()
                    )
                }
                
                GridRow {
                    HomeFunctionCard(
                        title: "Повторення",
                        subtitle: "Сьогодні",
                        icon: "arrow.clockwise",
                        color: .red,
                        destination: ReviewView()
                    )
                }
            }
        }
    }
}

struct HomeFunctionCard<Destination: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(height: 30)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
