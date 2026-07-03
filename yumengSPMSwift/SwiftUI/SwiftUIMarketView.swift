import SwiftUI

final class SwiftUIMarketViewModel: ObservableObject {
    @Published var quotes = MarketQuote.defaultFutures
    @Published var statusText = "新浪实时行情"
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let quoteService = SwiftQuoteService()

    func refresh() {
        isLoading = true
        quoteService.fetchQuotes { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let quotes):
                self.quotes = quotes
                self.statusText = "新浪实时行情 · 已更新 \(Self.timeText())"
            case .failure:
                self.errorMessage = "SwiftUI行情刷新失败，请稍后重试"
            }
        }
    }

    private static func timeText() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
}

struct SwiftUIMarketView: View {
    @StateObject private var viewModel = SwiftUIMarketViewModel()

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text("SwiftUI + Alamofire")
                        .font(.system(size: 21, weight: .bold))
                        .foregroundColor(Color(hex: 0x111827))
                    Text(viewModel.statusText)
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: 0x6B7280))
                }
                .listRowBackground(Color(hex: 0xF3F6FA))
                .listRowSeparator(.hidden)
            }

            Section {
                ForEach(viewModel.quotes, id: \.symbol) { quote in
                    SwiftUIQuoteRow(quote: quote)
                        .listRowBackground(Color(hex: 0xF3F6FA))
                        .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
        .background(Color(hex: 0xF3F6FA))
        .scrollContentBackground(.hidden)
        .navigationTitle("SwiftUI行情")
        .toolbar {
            Button {
                viewModel.refresh()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .disabled(viewModel.isLoading)
        }
        .refreshable {
            viewModel.refresh()
        }
        .alert("提示", isPresented: errorPresented) {
            Button("知道了", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear {
            if viewModel.statusText == "新浪实时行情" {
                viewModel.refresh()
            }
        }
    }

    private var errorPresented: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )
    }
}

private struct SwiftUIQuoteRow: View {
    let quote: MarketQuote

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(quote.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: 0x111827))
                    .lineLimit(1)
                Text("\(quote.symbol) · \(quote.exchange) · 量\(quote.volumeText)")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: 0x6B7280))
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 4) {
                Text(quote.lastPrice)
                    .font(.system(size: 18, weight: .semibold, design: .monospaced))
                    .foregroundColor(trendColor)
                    .lineLimit(1)
                Text(quote.changePercentText)
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
                    .frame(width: 76, height: 22)
                    .background(trendColor)
                    .cornerRadius(4)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(8)
    }

    private var trendColor: Color {
        let change = Double(quote.changeText) ?? 0
        if change > 0 {
            return Color(hex: 0xD93025)
        }
        if change < 0 {
            return Color(hex: 0x188038)
        }
        return Color(hex: 0x6B7280)
    }
}

private extension Color {
    init(hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xff) / 255.0,
            green: Double((hex >> 8) & 0xff) / 255.0,
            blue: Double(hex & 0xff) / 255.0
        )
    }
}
