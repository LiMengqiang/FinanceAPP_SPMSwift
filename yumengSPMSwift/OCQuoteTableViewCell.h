#import <UIKit/UIKit.h>

@class OCMarketQuote;

NS_ASSUME_NONNULL_BEGIN

@interface OCQuoteTableViewCell : UITableViewCell

- (void)configureWithQuote:(OCMarketQuote *)quote;

@end

NS_ASSUME_NONNULL_END
