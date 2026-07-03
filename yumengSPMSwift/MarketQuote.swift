import Foundation

struct MarketQuote {
    let symbol: String
    var name: String
    let exchange: String
    var lastPrice: String
    var changeText: String
    var changePercentText: String
    var volumeText: String

    static let defaultFutures: [MarketQuote] = [
        MarketQuote(symbol: "nf_SC0", name: "上海原油连续", exchange: "上期能源"),
        MarketQuote(symbol: "nf_AU0", name: "沪金连续", exchange: "上期所"),
        MarketQuote(symbol: "nf_RB0", name: "螺纹钢连续", exchange: "上期所"),
        MarketQuote(symbol: "nf_CU0", name: "沪铜连续", exchange: "上期所"),
        MarketQuote(symbol: "nf_M0", name: "豆粕连续", exchange: "大商所"),
        MarketQuote(symbol: "nf_Y0", name: "豆油连续", exchange: "大商所"),
        MarketQuote(symbol: "nf_IF0", name: "沪深300股指连续", exchange: "中金所"),
        MarketQuote(symbol: "nf_IH0", name: "上证50股指连续", exchange: "中金所"),
        MarketQuote(symbol: "nf_IC0", name: "中证500股指连续", exchange: "中金所")
    ]

    init(symbol: String, name: String, exchange: String) {
        self.symbol = symbol
        self.name = name
        self.exchange = exchange
        lastPrice = "--"
        changeText = "--"
        changePercentText = "--"
        volumeText = "--"
    }
}
