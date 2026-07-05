import SnapKit
import UIKit

final class SnapKitMarketViewController: UITableViewController {
    private let quoteService = SwiftQuoteService()
    private let statusLabel = UILabel()
    private var quotes = MarketQuote.defaultFutures

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SnapKit行情"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshQuotes))

        view.backgroundColor = UIColor(hex: 0xF3F6FA)
        tableView.backgroundColor = UIColor(hex: 0xF3F6FA)
        tableView.separatorStyle = .none
        tableView.rowHeight = 74
        tableView.register(SnapKitQuoteTableViewCell.self, forCellReuseIdentifier: "SnapKitQuoteCell")
        tableView.tableHeaderView = makeHeaderView()

        // 创建系统下拉刷新控件。
        refreshControl = UIRefreshControl()
        // `.valueChanged` 表示用户下拉触发刷新时发送的事件，触发后调用 refreshQuotes。
        refreshControl?.addTarget(self, action: #selector(refreshQuotes), for: .valueChanged)
        refreshQuotes()
    }

    private func makeHeaderView() -> UIView {
        // tableHeaderView 的宽度会跟随 tableView，这里主要设置固定高度 72。
        let header = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 72))
        header.backgroundColor = UIColor(hex: 0xF3F6FA)

        let titleLabel = UILabel()
        titleLabel.text = "SnapKit 约束列表"
        titleLabel.font = .boldSystemFont(ofSize: 21)
        titleLabel.textColor = UIColor(hex: 0x111827)
        header.addSubview(titleLabel)

        statusLabel.text = "新浪实时行情"
        statusLabel.font = .systemFont(ofSize: 12)
        statusLabel.textColor = UIColor(hex: 0x6B7280)
        header.addSubview(statusLabel)

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
            make.trailing.lessThanOrEqualToSuperview().inset(16)
            make.height.equalTo(24)
        }

        statusLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.trailing.lessThanOrEqualToSuperview().inset(16)
            make.height.equalTo(18)
        }

        return header
    }

    @objc private func refreshQuotes() {
        quoteService.fetchQuotes { [weak self] result in
            guard let self = self else { return }
            self.refreshControl?.endRefreshing()
            switch result {
            case .success(let quotes):
                self.quotes = quotes
                self.statusLabel.text = "新浪实时行情 · 已更新 \(Self.timeText())"
                self.tableView.reloadData()
            case .failure:
                self.showMessage("SnapKit行情刷新失败，请稍后重试")
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SnapKitQuoteCell", for: indexPath) as? SnapKitQuoteTableViewCell ?? SnapKitQuoteTableViewCell(style: .default, reuseIdentifier: "SnapKitQuoteCell")
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
