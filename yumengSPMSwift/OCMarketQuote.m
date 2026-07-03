#import "OCMarketQuote.h"

@implementation OCMarketQuote

+ (instancetype)quoteWithSymbol:(NSString *)symbol name:(NSString *)name exchange:(NSString *)exchange {
    OCMarketQuote *quote = [[OCMarketQuote alloc] init];
    quote.symbol = symbol;
    quote.name = name;
    quote.exchange = exchange;
    quote.lastPrice = @"--";
    quote.changeText = @"--";
    quote.changePercentText = @"--";
    quote.volumeText = @"--";
    return quote;
}

+ (NSArray<OCMarketQuote *> *)defaultFutures {
    return @[
        [OCMarketQuote quoteWithSymbol:@"nf_SC0" name:@"上海原油连续" exchange:@"上期能源"],
        [OCMarketQuote quoteWithSymbol:@"nf_AU0" name:@"沪金连续" exchange:@"上期所"],
        [OCMarketQuote quoteWithSymbol:@"nf_RB0" name:@"螺纹钢连续" exchange:@"上期所"],
        [OCMarketQuote quoteWithSymbol:@"nf_CU0" name:@"沪铜连续" exchange:@"上期所"],
        [OCMarketQuote quoteWithSymbol:@"nf_M0" name:@"豆粕连续" exchange:@"大商所"],
        [OCMarketQuote quoteWithSymbol:@"nf_Y0" name:@"豆油连续" exchange:@"大商所"],
        [OCMarketQuote quoteWithSymbol:@"nf_IF0" name:@"沪深300股指连续" exchange:@"中金所"],
        [OCMarketQuote quoteWithSymbol:@"nf_IH0" name:@"上证50股指连续" exchange:@"中金所"],
        [OCMarketQuote quoteWithSymbol:@"nf_IC0" name:@"中证500股指连续" exchange:@"中金所"]
    ];
}

- (id)copyWithZone:(NSZone *)zone {
    OCMarketQuote *copy = [[[self class] allocWithZone:zone] init];
    copy.symbol = self.symbol;
    copy.name = self.name;
    copy.exchange = self.exchange;
    copy.lastPrice = self.lastPrice;
    copy.changeText = self.changeText;
    copy.changePercentText = self.changePercentText;
    copy.volumeText = self.volumeText;
    return copy;
}

@end
