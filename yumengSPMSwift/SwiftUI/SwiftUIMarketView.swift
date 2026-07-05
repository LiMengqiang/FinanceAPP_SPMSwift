import SwiftUI // 引入 SwiftUI 框架。

final class SwiftUIMarketViewModel: ObservableObject { // SwiftUI 页面使用的 ViewModel，可被界面观察。
    // `@Published` 表示这个属性变化时会通知观察它的 SwiftUI View。
    // 下面这些属性一变，使用它们的界面会重新计算 body 并刷新显示。
    @Published var quotes = MarketQuote.defaultFutures // 行情列表数据，默认先显示本地基础数据。
    @Published var statusText = "新浪实时行情" // 顶部状态文案。
    @Published var isLoading = false // 是否正在刷新，用来控制按钮是否可点。
    @Published var errorMessage: String? // 错误提示文案；有值时弹窗。

    private let quoteService = SwiftQuoteService() // 负责请求和解析行情数据的服务对象。

    func refresh() { // 刷新行情数据。
        isLoading = true // 开始刷新，标记为加载中。
        quoteService.fetchQuotes { [weak self] result in // 调用服务请求行情；weak self 避免闭包强引用 ViewModel。
            guard let self = self else { return } // 如果 ViewModel 已释放，就不再继续处理回调。
            self.isLoading = false // 请求结束，取消加载中状态。
            switch result { // 根据请求结果分别处理成功和失败。
            case .success(let quotes): // 成功时取出行情数组。
                self.quotes = quotes // 更新行情列表，触发界面刷新。
                self.statusText = "新浪实时行情 · 已更新 \(Self.timeText())" // 更新顶部状态文案和时间。
            case .failure: // 失败时这里不关心具体错误对象。
                self.errorMessage = "SwiftUI行情刷新失败，请稍后重试" // 设置错误文案，触发 alert 显示。
            }
        }
    }

    private static func timeText() -> String { // 生成当前时间字符串。
        let formatter = DateFormatter() // 创建日期格式化对象。
        formatter.dateFormat = "HH:mm:ss" // 设置时间格式：小时:分钟:秒。
        return formatter.string(from: Date()) // 把当前时间转换成字符串。
    }
}

// SwiftUI 的 View 通常写成 struct，因为 View 更像是“界面长什么样”的轻量描述。
// 状态变化时，SwiftUI 会重新计算 body 生成新的界面描述，再由系统高效更新真实界面。
// 需要长期持有和共享状态的对象，通常放到 class ViewModel 里，比如上面的 SwiftUIMarketViewModel。
struct SwiftUIMarketView: View {
    // `@StateObject` 表示这个 View 自己创建并持有这个 ObservableObject。
    // View 重绘时，SwiftUI 会保留同一个 viewModel，不会每次都重新创建。
    @StateObject private var viewModel = SwiftUIMarketViewModel()

    // body 描述这个 SwiftUI View 的界面内容。
    // `some View` 是“不透明返回类型”：对外只说返回某种 View，具体是哪种复杂 View 类型由编译器自己确定。
    var body: some View {
        List { // SwiftUI 列表容器。
            Section { // List 里的一个分区，这里作为顶部标题区域。
                VStack(alignment: .leading, spacing: 4) { // 垂直排列子视图，左对齐，子视图之间间距 4。
                    Text("SwiftUI + Alamofire") // 标题文字。
                        .font(.system(size: 21, weight: .bold)) // 设置系统字体，字号 21，粗体。
                        .foregroundColor(Color(hex: 0x111827)) // 设置文字颜色，深色。
                    Text(viewModel.statusText) // 状态文字，内容来自 viewModel。
                        .font(.system(size: 12)) // 设置系统字体，字号 12。
                        .foregroundColor(Color(hex: 0x6B7280)) // 设置文字颜色，灰色。
                }
                .listRowBackground(Color(hex: 0xF3F6FA)) // 设置这一行在 List 中的背景色。
                .listRowSeparator(.hidden) // 隐藏这一行底部的分割线。
            }

            Section { // 行情列表分区。
                // `id: \.symbol` 是 key path 写法，表示用每个 quote 的 symbol 作为这一行的唯一标识。
                ForEach(viewModel.quotes, id: \.symbol) { quote in // 遍历每个 quote，生成一行。
                    SwiftUIQuoteRow(quote: quote) // 使用自定义 Row 显示单条行情。
//                        如果不设置listRowInsets，是有默认Insets的，看上去比较远
                        .listRowInsets(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10)) // 收紧 List 默认行边距，让白色卡片更靠近四边。
                        .listRowBackground(Color(hex: 0xF3F6FA)) // 设置列表行背景色。
                        .listRowSeparator(.hidden) // 隐藏列表行分割线。
                }
            }
        }
        .listStyle(.plain) // 使用普通列表样式。
        .background(Color(hex: 0xF3F6FA)) // 设置 List 外层背景色。
        .scrollContentBackground(.hidden) // 隐藏系统默认滚动内容背景。
        .navigationTitle("SwiftUI行情") // 设置导航栏标题。
        .toolbar { // 配置导航栏工具按钮。
            Button { // 创建按钮。
                viewModel.refresh() // 点击按钮时刷新行情。
            } label: {
                Image(systemName: "arrow.clockwise") // 使用系统刷新图标。
            }
            .disabled(viewModel.isLoading) // 加载中禁用按钮，避免重复请求。
        }
        .refreshable { // SwiftUI 下拉刷新。
            viewModel.refresh() // 下拉触发刷新行情。
        }
        .alert("提示", isPresented: errorPresented) { // 根据 errorPresented 控制错误弹窗。
            Button("知道了", role: .cancel) {} // 弹窗取消按钮。
        } message: {
            Text(viewModel.errorMessage ?? "") // 弹窗正文，错误为空时显示空字符串。
        }
        .onAppear { // 页面出现时执行。
            if viewModel.statusText == "新浪实时行情" { // 只在初始状态自动刷新一次。
                viewModel.refresh() // 首次进入页面时加载行情。
            }
        }
    }

    // `Binding<Bool>` 是一个可读可写的绑定值，这里用于控制 alert 是否显示。
    // get：errorMessage 有值时显示弹窗；set：弹窗关闭时把 errorMessage 清空。
    private var errorPresented: Binding<Bool> { // 把 errorMessage 转成 alert 需要的 Bool 绑定。
        Binding( // 手动创建 Binding。
            get: { viewModel.errorMessage != nil }, // errorMessage 有值就显示弹窗。
            // set 闭包里的 `$0` 是 SwiftUI 传进来的新 Bool 值；`!$0` 表示它是 false。
            // 当 alert 被关闭时，isPresented 会变成 false，所以这里清空 errorMessage。
            set: { if !$0 { viewModel.errorMessage = nil } } // 弹窗关闭时清空错误。
        )
    }
}

private struct SwiftUIQuoteRow: View { // 单条行情的 SwiftUI 行视图。
    let quote: MarketQuote // 当前行要显示的行情数据。

    var body: some View { // 描述单条行情行的界面。
        HStack(spacing: 12) { // 水平排列左右两块内容，间距 12。// 左侧 VStack 和 Spacer 之间；Spacer 和右侧 VStack 之间
            VStack(alignment: .leading, spacing: 4) { // 左侧垂直排列名称和元信息。
                Text(quote.name) // 合约名称。
                    .font(.system(size: 16, weight: .bold)) // 名称字体，16 号粗体。
                    .foregroundColor(Color(hex: 0x111827)) // 名称文字颜色。
                    .lineLimit(1) // 最多显示一行，超出截断。
                Text("\(quote.symbol) · \(quote.exchange) · 量\(quote.volumeText)") // symbol、交易所和成交量。
                    .font(.system(size: 12)) // 元信息字体，12 号。
                    .foregroundColor(Color(hex: 0x6B7280)) // 元信息文字颜色。
                    .lineLimit(1) // 最多显示一行。
            }

            Spacer(minLength: 8) // 中间弹性空白，最小宽度 8，把价格区域推到右侧。

            VStack(alignment: .trailing, spacing: 4) { // 右侧垂直排列价格和涨跌幅，右对齐。
                Text(quote.lastPrice) // 最新价。
                    .font(.system(size: 18, weight: .semibold, design: .monospaced)) // 半粗等宽数字字体。
                    .foregroundColor(trendColor) // 根据涨跌设置价格颜色。
                    .lineLimit(1) // 最多显示一行。
                Text(quote.changePercentText) // 涨跌幅百分比。
                    .font(.system(size: 12, weight: .semibold, design: .monospaced)) // 涨跌幅使用等宽数字字体。
                    .foregroundColor(.white) // 涨跌幅文字为白色。
                    .frame(width: 76, height: 22) // 固定涨跌幅标签尺寸。
                    .background(trendColor) // 标签背景使用涨跌颜色。
                    .cornerRadius(4) // 标签圆角 4。
            }
        }
        .padding(.horizontal, 14) // 行内容左右内边距 14。
        .padding(.vertical, 12) // 行内容上下内边距 12。
        .background(Color.white) // 行卡片背景白色。
        .cornerRadius(8) // 行卡片圆角 8。
    }

    private var trendColor: Color { // 计算属性；根据涨跌值计算显示颜色。
        let change = Double(quote.changeText) ?? 0 // 把涨跌文本转成数字，失败时按 0 处理。
        if change > 0 { // 大于 0 表示上涨。
            return Color(hex: 0xD93025) // 上涨颜色：红色。
        }
        if change < 0 { // 小于 0 表示下跌。
            return Color(hex: 0x188038) // 下跌颜色：绿色。
        }
        return Color(hex: 0x6B7280) // 不涨不跌颜色：灰色。
    }
}

private extension Color { // 给 SwiftUI 的 Color 增加 16 进制颜色初始化方法。
    init(hex: UInt) { // 允许写 Color(hex: 0xD93025)。
        self.init( // 调用 Color 原有的 RGB 初始化方法。
            red: Double((hex >> 16) & 0xff) / 255.0, // 取红色通道，并转换到 0.0 到 1.0。
            green: Double((hex >> 8) & 0xff) / 255.0, // 取绿色通道，并转换到 0.0 到 1.0。
            blue: Double(hex & 0xff) / 255.0 // 取蓝色通道，并转换到 0.0 到 1.0。
        )
    }
}
