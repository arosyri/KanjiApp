infinity)
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
