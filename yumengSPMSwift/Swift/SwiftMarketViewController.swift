import UIKit

final class SwiftMarketViewController: UITableViewController {
    private let quoteService = SwiftQuoteService()
    private let statusLabel = UILabel()
    private var quotes = MarketQuote.defaultFutures

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Swift行情"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshQuotes))

        view.backgroundColor = UIColor(hex: 0xF3F6FA)
        tableView.backgroundColor = UIColor(hex: 0xF3F6FA)
        tableView.separatorStyle = .none
        tableView.rowHeight = 74
        tableView.tableHeaderView = makeHeaderView(title: "Alamofire 请求")

        // 创建系统下拉刷新控件。
        refreshControl = UIRefreshControl()
        // `.valueChanged` 表示用户下拉触发刷新时发送的事件，触发后调用 refreshQuotes。
        refreshControl?.addTarget(self, action: #selector(refreshQuotes), for: .valueChanged)
        refreshQuotes()
    }

    private func makeHeaderView(title: String) -> UIView {
        // tableHeaderView 的宽度会跟随 tableView，这里主要设置固定高度 72。
        let header = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 72))
        header.backgroundColor = UIColor(hex: 0xF3F6FA)

        let titleLabel = UILabel(frame: CGRect(x: 16, y: 12, width: 220, height: 24))
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 21)
        titleLabel.textColor = UIColor(hex: 0x111827)
        header.addSubview(titleLabel)

        statusLabel.frame = CGRect(x: 16, y: 40, width: 320, height: 18)
        statusLabel.text = "新浪实时行情"
        statusLabel.font = .systemFont(ofSize: 12)
        statusLabel.textColor = UIColor(hex: 0x6B7280)
        header.addSubview(statusLabel)
        return header
    }

    @objc private func refreshQuotes() {
        quoteService.fetchQuotes { [weak self] result in
            guard let self = self else { return }
            self.refreshControl?.endRefreshing()
            switch result {
            // `.success` 里带着成功返回的 [MarketQuote]；`let quotes` 是把这个关联值取出来使用。
            // quotes 的类型由 fetchQuotes 的 Result<[MarketQuote], Error> 推断，通常不用、也不需要在这里额外写类型。
            case .success(let quotes):
                self.quotes = quotes
                self.statusLabel.text = "新浪实时行情 · 已更新 \(Self.timeText())"
                self.tableView.reloadData()
            // 这里不关心具体 error，只需要提示失败，所以可以省略参数，直接写 `case .failure:`。
            // 如果要拿到错误对象，可以写成 `case .failure(let error):`。
            case .failure:
                self.showMessage("Swift行情刷新失败，请稍后重试")
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwiftQuoteCell") as? QuoteTableViewCell ?? QuoteTableViewCell(style: .default, reuseIdentifier: "SwiftQuoteCell")
        cell.configure(with: quotes[indexPath.row])
        return cell
    }

    private func showMessage(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "知道了", style: .default))
        present(alert, animated: true)
    }

    private static func timeText() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
}
