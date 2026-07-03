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
    convenience init(hex: UInt) {
        self.init(
            red: CGFloat((hex >> 16) & 0xff) / 255.0,
            green: CGFloat((hex >> 8) & 0xff) / 255.0,
            blue: CGFloat(hex & 0xff) / 255.0,
            alpha: 1
        )
    }
}
