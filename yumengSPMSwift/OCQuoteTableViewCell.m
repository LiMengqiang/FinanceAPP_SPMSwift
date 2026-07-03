#import "OCQuoteTableViewCell.h"
#import "OCMarketQuote.h"

@interface OCQuoteTableViewCell ()

@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *metaLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *changeLabel;

@end

@implementation OCQuoteTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        _cardView = [[UIView alloc] initWithFrame:CGRectZero];
        _cardView.backgroundColor = UIColor.whiteColor;
        _cardView.layer.cornerRadius = 8;
        _cardView.layer.masksToBounds = YES;
        [self.contentView addSubview:_cardView];

        _nameLabel = [self labelWithFont:[UIFont boldSystemFontOfSize:16] color:[self colorWithHex:0x111827] alignment:NSTextAlignmentLeft];
        _metaLabel = [self labelWithFont:[UIFont systemFontOfSize:12] color:[self colorWithHex:0x6B7280] alignment:NSTextAlignmentLeft];
        _priceLabel = [self labelWithFont:[UIFont monospacedDigitSystemFontOfSize:18 weight:UIFontWeightSemibold] color:[self colorWithHex:0x111827] alignment:NSTextAlignmentRight];
        _changeLabel = [self labelWithFont:[UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightSemibold] color:UIColor.whiteColor alignment:NSTextAlignmentCenter];
        _changeLabel.layer.cornerRadius = 4;
        _changeLabel.layer.masksToBounds = YES;

        [_cardView addSubview:_nameLabel];
        [_cardView addSubview:_metaLabel];
        [_cardView addSubview:_priceLabel];
        [_cardView addSubview:_changeLabel];
    }
    return self;
}

- (UILabel *)labelWithFont:(UIFont *)font color:(UIColor *)color alignment:(NSTextAlignment)alignment {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = font;
    label.textColor = color;
    label.textAlignment = alignment;
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    return label;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat marginX = 12;
    CGFloat marginY = 5;
    self.cardView.frame = CGRectMake(marginX, marginY, CGRectGetWidth(self.contentView.bounds) - marginX * 2, CGRectGetHeight(self.contentView.bounds) - marginY * 2);

    CGFloat padding = 14;
    CGFloat rightWidth = 112;
    CGFloat leftWidth = CGRectGetWidth(self.cardView.bounds) - padding * 2 - rightWidth - 12;
    self.nameLabel.frame = CGRectMake(padding, 12, leftWidth, 22);
    self.metaLabel.frame = CGRectMake(padding, 36, leftWidth, 18);
    self.priceLabel.frame = CGRectMake(CGRectGetWidth(self.cardView.bounds) - padding - rightWidth, 10, rightWidth, 24);
    self.changeLabel.frame = CGRectMake(CGRectGetWidth(self.cardView.bounds) - padding - 76, 37, 76, 22);
}

- (void)configureWithQuote:(OCMarketQuote *)quote {
    self.nameLabel.text = quote.name;
    self.metaLabel.text = [NSString stringWithFormat:@"%@ · %@ · 量%@", quote.symbol, quote.exchange, quote.volumeText];
    self.priceLabel.text = quote.lastPrice;
    self.changeLabel.text = quote.changePercentText;

    double change = quote.changeText.doubleValue;
    UIColor *trendColor = [self colorWithHex:0x6B7280];
    if (change > 0) {
        trendColor = [self colorWithHex:0xD93025];
    } else if (change < 0) {
        trendColor = [self colorWithHex:0x188038];
    }

    self.priceLabel.textColor = trendColor;
    self.changeLabel.backgroundColor = trendColor;
}

- (UIColor *)colorWithHex:(NSUInteger)hex {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0
                           green:((hex >> 8) & 0xFF) / 255.0
                            blue:(hex & 0xFF) / 255.0
                           alpha:1.0];
}

@end
