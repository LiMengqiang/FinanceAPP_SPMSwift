import Alamofire
import CoreFoundation
import Foundation

final class SwiftQuoteService {
    func fetchQuotes(completion: @escaping (Result<[MarketQuote], Error>) -> Void) {
        let baseQuotes = MarketQuote.defaultFutures
        let symbols = baseQuotes.map { $0.symbol }.joined(separator: ",")
        let url = "https://hq.sinajs.cn/list=\(symbols)"
//        let headers: HTTPHeaders = [
//            "Referer": "https://finance.sina.com.cn/",
//            "User-Agent": "Mozilla/5.0 iPhone yumengSPMSwift"
//        ]
        let headers: HTTPHeaders = HTTPHeaders([
            "Referer": "https://finance.sina.com.cn/",
            "User-Agent": "Mozilla/5.0 iPhone yumengSPMSwift"
        ])

        AF.request(url, headers: headers)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    let payload = Self.decodeSinaPayload(data: data)
                    let quotes = Self.parse(payload: payload, baseQuotes: baseQuotes)
                    completion(.success(quotes.isEmpty ? baseQuotes : quotes))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

#if DEBUG
    /// 学习调试代码：演示函数参数、闭包参数和 `@escaping` 的关系。
    ///
    /// `callback` 的类型是 `(String) -> Void`，表示：
    /// - 接收一个 `String`
    /// - 不返回值
    ///
    /// 调用方既可以传一个已经定义好的函数，也可以直接传一个匿名闭包。
    /// `doSomething` 会异步延迟执行回调，所以 `callback` 需要标记为 `@escaping`。
    func debugDoSomethingExample() {
        // 函数：有名字的闭包。
        doSomething(callback: printDebugText)

        // 闭包：可以没有名字，也可以捕获外部变量的函数代码块。
        doSomething { text in
            print("闭包收到：\(text)")
        }

        let prefix = "结果："
        // 这里的闭包捕获了外部变量 `prefix`，所以可以在闭包内部继续使用它。
        doSomething { text in
            print(prefix + text)
        }
    }

    /// 这里的 `callback` 是一个会逃逸的闭包参数，也可以接收符合类型的函数。
    private func doSomething(callback: @escaping (String) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            callback("hello")
        }
    }

    /// 这是一个普通函数，因为参数和返回值匹配 `(String) -> Void`，所以可以传给需要 `@escaping` 闭包的 `doSomething`。
    private func printDebugText(_ text: String) {
        print("函数收到：\(text)")
    }
#endif

    private static func decodeSinaPayload(data: Data) -> String {
        let gbEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        if let text = String(data: data, encoding: String.Encoding(rawValue: gbEncoding)) {
            return text
        }
        return String(data: data, encoding: .utf8) ?? ""
    }

    private static func parse(payload: String, baseQuotes: [MarketQuote]) -> [MarketQuote] {
        // 把基础行情数组转成字典，key 是 symbol，方便后面按接口返回的 symbol 快速找到原始行情对象。
        //
        // 下面这句里的 `baseQuotes.map { ($0.symbol, $0) }` 还有几种等价写法：
        //
        // 写法 1：使用闭包参数简写 `$0`
        // let pairs = baseQuotes.map { ($0.symbol, $0) }
        //
        // 写法 2：给闭包参数起名，含义更清楚
        // let pairs = baseQuotes.map { quote in
        //     (quote.symbol, quote)
        // }
        //
        // 写法 3：不用 `map`，用普通循环手动构造字典
        // var dictionary: [String: MarketQuote] = [:]
        // for quote in baseQuotes {
        //     dictionary[quote.symbol] = quote
        // }
        //
        // 写法 4：用 `reduce(into:)` 累积生成字典
        // let dictionary = baseQuotes.reduce(into: [String: MarketQuote]()) { result, quote in
        //     result[quote.symbol] = quote
        // }
        let baseBySymbol: [String: MarketQuote] = Dictionary(uniqueKeysWithValues: baseQuotes.map { ($0.symbol, $0) })
        // 正则捕获组说明：
        // range(at: 0)：整个匹配结果，例如 var hq_str_AU0="黄金,100,200";
        // range(at: 1)：第 1 个小括号 `([^=]+)`，表示 hq_str_ 后面、等号前面的 symbol，例如 AU0。
        // range(at: 2)：第 2 个小括号 `([^"]*)`，表示双引号里的行情字段内容，例如 黄金,100,200。
        let pattern = #"var hq_str_([^=]+)="([^"]*)";"#//#"..."# 原是字符串，可以减少转义符号
        // 根据正则字符串创建正则对象；如果 pattern 写错导致创建失败，就直接返回空数组。
        // `try?` 会把可能抛错的结果转成可选值：成功时得到 regex，失败时得到 nil。（不需要do catch）
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }

        // `compactMap` 是 Swift 集合的方法；这里作用在 `payload.split(separator: "\n")` 得到的每一行上。
        // 闭包返回 quote 时会收集进结果数组，返回 nil 时会自动跳过这一行。
        return payload.split(separator: "\n").compactMap { (line: Substring) in
            let text = String(line)// ex: "var hq_str_nf_SC0=\"上海原油连续,222332,436.600,439.000,435.600,0.000,437.400,437.500,437.400,0.000,439.000,5,17,45706.000,12357,沪,上海原油,2026-07-03,1,,,,,,,,,437.520,0.000,0,0.000,0,0.000,0,0.000,0,0.000,0,0.000,0,0.000,0,0.000,0\";"
            // 把整行文本的 Swift 字符串范围转换成 NSRange，供 NSRegularExpression 使用。
//            ..< 是 Swift 的半开区间运算符。从左边开始，到右边之前结束
            let range = NSRange(text.startIndex..<text.endIndex, in: text)
            // 用正则匹配当前行，并依次取出：
            // 1. match：整行的正则匹配结果。
            // 2. symbolRange：第 1 个捕获组，也就是 hq_str_ 后面的 symbol。
            // 3. fieldsRange：第 2 个捕获组，也就是双引号里的行情字段内容。
            // 4. quote：根据 symbol 从基础行情字典里找到对应的 MarketQuote。
            // 任意一步失败都说明这一行无法解析，返回 nil 后会被 compactMap 自动跳过。
            guard let match: NSTextCheckingResult = regex.firstMatch(in: text, range: range),
                  let symbolRange: Range<String.Index> = Range(match.range(at: 1), in: text),
                  let fieldsRange: Range<String.Index> = Range(match.range(at: 2), in: text),
                  var quote: MarketQuote = baseBySymbol[String(text[symbolRange])] else {
                return nil
            }

            fill(quote: &quote, fields: String(text[fieldsRange]).components(separatedBy: ","))
            return quote
        }
    }

    // `inout` 表示这个参数可以在函数内部被修改，并把修改结果带回调用处。
    // 调用时需要写 `&quote`，表示把 quote 传进去让函数修改。
    // 这里需要 `inout`，是因为 MarketQuote 是 struct，属于值类型。
    private static func fill(quote: inout MarketQuote, fields: [String]) {
        guard !fields.isEmpty else { return }
        // 为了适配新浪接口不同品种返回字段顺序不一致的情况：
        // 如果第一个字段不能转成 Double，说明它更像是名称字段；如果能转成 Double，说明它更像是价格/数值字段。
        let firstFieldIsName = Double(fields[0]) == nil

        if firstFieldIsName {
            // nonEmpty 会优先使用接口字段；如果字段不存在或是空字符串，就使用 fallback 兜底。
            // fields[safe: index] 使用下面 Array 扩展里的安全下标；越界时返回 nil，避免数组越界崩溃。
//            safe 不是 Swift 内置语法，是这个文件里的扩展。
            quote.name = nonEmpty(fields[safe: 0], fallback: quote.name)
            quote.lastPrice = nonEmpty(fields[safe: 8], fallback: nonEmpty(fields[safe: 7], fallback: "--"))
            quote.volumeText = nonEmpty(fields[safe: 13], fallback: "--")
            fillChange(quote: &quote, last: fields[safe: 8], previous: fields[safe: 10])
        } else {
            quote.lastPrice = nonEmpty(fields[safe: 3], fallback: "--")
            quote.volumeText = nonEmpty(fields[safe: 4], fallback: "--")
            quote.name = nonEmpty(fields[safe: 41], fallback: quote.name)
            fillChange(quote: &quote, last: fields[safe: 3], previous: fields[safe: 7])
        }
    }

    private static func fillChange(quote: inout MarketQuote, last: String?, previous: String?) {
        guard let lastValue = Double(last ?? ""),
              let previousValue = Double(previous ?? ""),
              lastValue > 0,
              previousValue > 0 else {
            quote.changeText = "--"
            quote.changePercentText = "--"
            return
        }
        let change = lastValue - previousValue
        // `%+.2f` 表示格式化成带正负号、保留 2 位小数的浮点数：
        // 正数会显示 `+1.23`，负数会显示 `-1.23`，0 会显示 `+0.00`。
        quote.changeText = String(format: "%+.2f", change)
        // 这里先计算百分比，再用 `%+.2f%%` 格式化；`%%` 表示输出一个真正的百分号 `%`。
        quote.changePercentText = String(format: "%+.2f%%", change / previousValue * 100.0)
    }

    // 返回一个非空字符串：
    // - text 有值，并且去掉前后空白后不为空：返回处理后的 text。
    // - text 是 nil，或者去掉空白后为空：返回 fallback。
    private static func nonEmpty(_ text: String?, fallback: String) -> String {
        let value = text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return value.isEmpty ? fallback : value
    }
}

private extension Array {
    // `extension Array` 表示给 Swift 的数组类型增加能力。
    // `private` 表示这个扩展只在当前文件内可见。
    //
    // `subscript` 用来定义“下标访问”的写法。
    // Swift 原生数组可以这样访问：array[index]。
    // 这里我们额外定义了一个带标签的下标：array[safe: index]。
    //
    // `safe` 不是系统内置关键字，只是这个下标的参数标签。
    // 因为这里定义了 `subscript(safe index: Int)`，所以上面才可以写 `fields[safe: 0]`。
    //
    // 返回类型是 `Element?`：
    // - `Element` 表示数组里的元素类型，比如 [String] 的 Element 就是 String。
    // - `?` 表示可选值，可能有值，也可能是 nil。
    //
    // 作用：
    // - index 在数组范围内：返回对应元素。
    // - index 越界：返回 nil，避免直接使用 array[index] 导致数组越界崩溃。
    subscript(safe index: Int) -> Element? {
        // `indices` 是当前数组的有效下标范围；contains(index) 用来判断 index 是否会越界。
        return indices.contains(index) ? self[index] : nil
    }
}
