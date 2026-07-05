import SnapKit
import UIKit

final class SnapKitQuoteTableViewCell: UITableViewCell {
    private let cardView = UIView()
    private let nameLabel = UILabel()
    private let metaLabel = UILabel()
    private let priceLabel = UILabel()
    private let changeLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
        configureConstraints()
    }

    // `required` 是因为父类/协议要求子类必须提供这个初始化方法。
    // `coder` 用于 storyboard/xib 反序列化创建控件；当前 Cell 是纯代码创建，所以这里不实现。
    // `init?` 表示可失败初始化器，理论上初始化失败时可以返回 nil。
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with quote: MarketQuote) {
        nameLabel.text = quote.name
        metaLabel.text = "\(quote.symbol) · \(quote.exchange) · 量\(quote.volumeText)"
        priceLabel.text = quote.lastPrice
        changeLabel.text = quote.changePercentText

        let change = Double(quote.changeText) ?? 0
        let trendColor = change > 0 ? UIColor(hex: 0xD93025) : (change < 0 ? UIColor(hex: 0x188038) : UIColor(hex: 0x6B7280))
        priceLabel.textColor = trendColor
        changeLabel.backgroundColor = trendColor
    }

    private func configureViews() {
        backgroundColor = .clear
        selectionStyle = .none

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 8
        cardView.layer.masksToBounds = true
        contentView.addSubview(cardView)

        configure(label: nameLabel, font: .boldSystemFont(ofSize: 16), color: UIColor(hex: 0x111827), alignment: .left)
        configure(label: metaLabel, font: .systemFont(ofSize: 12), color: UIColor(hex: 0x6B7280), alignment: .left)
        // monospacedDigitSystemFont 使用等宽数字，价格上下刷新时更容易对齐。
        configure(label: priceLabel, font: .monospacedDigitSystemFont(ofSize: 18, weight: .semibold), color: UIColor(hex: 0x111827), alignment: .right)
        // 涨跌幅也是数字，使用等宽数字能减少宽度变化带来的视觉跳动。
        configure(label: changeLabel, font: .monospacedDigitSystemFont(ofSize: 12, weight: .semibold), color: .white, alignment: .center)

        changeLabel.layer.cornerRadius = 4
        changeLabel.layer.masksToBounds = true

        [nameLabel, metaLabel, priceLabel, changeLabel].forEach(cardView.addSubview)
    }

    private func configureConstraints() {
        cardView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(12)
            make.top.bottom.equalToSuperview().inset(5)
        }

        priceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().inset(14)
            make.width.equalTo(112)
            make.height.equalTo(24)
        }

        changeLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(3)
            make.trailing.equalTo(priceLabel)
            make.width.equalTo(76)
            make.height.equalTo(22)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(12)
            make.trailing.equalTo(priceLabel.snp.leading).offset(-12)
            make.height.equalTo(22)
        }

        metaLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.height.equalTo(18)
        }
    }

    private func configure(label: UILabel, font: UIFont, color: UIColor, alignment: NSTextAlignment) {
        label.font = font
        label.textColor = color
        label.textAlignment = alignment
        label.lineBreakMode = .byTruncatingTail
    }
}
