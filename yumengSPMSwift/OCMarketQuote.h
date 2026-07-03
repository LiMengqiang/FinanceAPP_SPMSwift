#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCMarketQuote : NSObject <NSCopying>

@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *exchange;
@property (nonatomic, copy) NSString *lastPrice;
@property (nonatomic, copy) NSString *changeText;
@property (nonatomic, copy) NSString *changePercentText;
@property (nonatomic, copy) NSString *volumeText;

+ (instancetype)quoteWithSymbol:(NSString *)symbol name:(NSString *)name exchange:(NSString *)exchange;
+ (NSArray<OCMarketQuote *> *)defaultFutures;

@end

NS_ASSUME_NONNULL_END
