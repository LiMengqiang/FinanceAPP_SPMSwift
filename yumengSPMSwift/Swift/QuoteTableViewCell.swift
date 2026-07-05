import UIKit

final class QuoteTableViewCell: UITableViewCell {
    private let cardView = UIView()
    private let nameLabel = UILabel()
    private let metaLabel = UILabel()
    private let priceLabel = UILabel()
    private let changeLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 8
        cardView.layer.masksToBounds = true
        contentView.addSubview(cardView)

        configure(label: nameLabel, font: .boldSystemFont(ofSize: 16), color: UIColor(hex: 0x111827), alignment: .left)
        configure(label: metaLabel, font: .systemFont(ofSize: 12), color: UIColor(hex: 0x6B7280), alignment: .left)
        configure(label: priceLabel, font: .monospacedDigitSystemFont(ofSize: 18, weight: .semibold), color: UIColor(hex: 0x111827), alignment: .right)
        configure(label: changeLabel, font: .monospacedDigitSystemFont(ofSize: 12, weight: .semibold), color: .white, alignment: .center)
        changeLabel.layer.cornerRadius = 4
        changeLabel.layer.masksToBounds = true

        [nameLabel, metaLabel, priceLabel, changeLabel].forEach(cardView.addSubview)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let marginX: CGFloat = 12
        let marginY: CGFloat = 5
        cardView.frame = CGRect(x: marginX, y: marginY, width: contentView.bounds.width - marginX * 2, height: contentView.bounds.height - marginY * 2)

        let padding: CGFloat = 14
        let rightWidth: CGFloat = 112
        let leftWidth = cardView.bounds.width - padding * 2 - rightWidth - 12
        nameLabel.frame = CGRect(x: padding, y: 12, width: leftWidth, height: 22)
        metaLabel.frame = CGRect(x: padding, y: 36, width: leftWidth, height: 18)
        priceLabel.frame = CGRect(x: cardView.bounds.width - padding - rightWidth, y: 10, width: rightWidth, height: 24)
        changeLabel.frame = CGRect(x: cardView.bounds.width - padding - 76, y: 37, width: 76, height: 22)
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

    private func configure(label: UILabel, font: UIFont, color: UIColor, alignment: NSTextAlignment) {
        label.font = font
        label.textColor = color
        label.textAlignment = alignment
        label.lineBreakMode = .byTruncatingTail
    }
}

extension UIColor {
    // 允许用 16 进制颜色创建 UIColor，例如 UIColor(hex: 0xD93025)。
    // 0xD93025 可以拆成三段：D9 是红色，30 是绿色，25 是蓝色。
    // `convenience init` 是便利初始化方法：提供一个更好用的入口，内部还是调用 UIColor 原有的初始化方法。
    convenience init(hex: UInt) {
        self.init(
            // `hex >> 16` 把红色段移动到最后，再用 `& 0xff` 只保留最后 8 位。
            // 除以 255.0 是因为 UIColor 的 red/green/blue 取值范围是 0.0 到 1.0。
            red: CGFloat((hex >> 16) & 0xff) / 255.0,
            // `hex >> 8` 取绿色段。
            green: CGFloat((hex >> 8) & 0xff) / 255.0,
            // 不右移，直接用 `& 0xff` 取蓝色段。
            blue: CGFloat(hex & 0xff) / 255.0,
            // alpha 是透明度，1 表示完全不透明。
            alpha: 1
        )
    }
}
