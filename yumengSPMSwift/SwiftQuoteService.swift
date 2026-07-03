import Alamofire
import CoreFoundation
import Foundation

final class SwiftQuoteService {
    func fetchQuotes(completion: @escaping (Result<[MarketQuote], Error>) -> Void) {
        let baseQuotes = MarketQuote.defaultFutures
        let symbols = baseQuotes.map { $0.symbol }.joined(separator: ",")
        let url = "https://hq.sinajs.cn/list=\(symbols)"
        let headers: HTTPHeaders = [
            "Referer": "https://finance.sina.com.cn/",
            "User-Agent": "Mozilla/5.0 iPhone yumengSPMSwift"
        ]

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

    private static func decodeSinaPayload(data: Data) -> String {
        let gbEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        if let text = String(data: data, encoding: String.Encoding(rawValue: gbEncoding)) {
            return text
        }
        return String(data: data, encoding: .utf8) ?? ""
    }

    private static func parse(payload: String, baseQuotes: [MarketQuote]) -> [MarketQuote] {
        let baseBySymbol = Dictionary(uniqueKeysWithValues: baseQuotes.map { ($0.symbol, $0) })
        let pattern = #"var hq_str_([^=]+)="([^"]*)";"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }

        return payload.split(separator: "\n").compactMap { line in
            let text = String(line)
            let range = NSRange(text.startIndex..<text.endIndex, in: text)
            guard let match = regex.firstMatch(in: text, range: range),
                  let symbolRange = Range(match.range(at: 1), in: text),
                  let fieldsRange = Range(match.range(at: 2), in: text),
                  var quote = baseBySymbol[String(text[symbolRange])] else {
                return nil
            }

            fill(quote: &quote, fields: String(text[fieldsRange]).components(separatedBy: ","))
            return quote
        }
    }

    private static func fill(quote: inout MarketQuote, fields: [String]) {
        guard !fields.isEmpty else { return }
        let firstFieldIsName = Double(fields[0]) == nil

        if firstFieldIsName {
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
        quote.changeText = String(format: "%+.2f", change)
        quote.changePercentText = String(format: "%+.2f%%", change / previousValue * 100.0)
    }

    private static func nonEmpty(_ text: String?, fallback: String) -> String {
        let value = text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return value.isEmpty ? fallback : value
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
