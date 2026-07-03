#import <Foundation/Foundation.h>

@class OCMarketQuote;

NS_ASSUME_NONNULL_BEGIN

typedef void (^OCQuoteCompletion)(NSArray<OCMarketQuote *> *quotes, NSError *_Nullable error);

@interface OCQuoteService : NSObject

- (void)fetchQuotesWithCompletion:(OCQuoteCompletion)completion;

@end

NS_ASSUME_NONNULL_END
