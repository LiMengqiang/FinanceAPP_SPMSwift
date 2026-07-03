#import "OCQuoteService.h"
#import "OCMarketQuote.h"
@import AFNetworking;

@implementation OCQuoteService

- (void)fetchQuotesWithCompletion:(OCQuoteCompletion)completion {
    NSArray<OCMarketQuote *> *baseQuotes = [OCMarketQuote defaultFutures];
    NSMutableArray<NSString *> *symbols = [NSMutableArray array];
    for (OCMarketQuote *quote in baseQuotes) {
        [symbols addObject:quote.symbol];
    }

    NSString *urlText = [NSString stringWithFormat:@"https://hq.sinajs.cn/list=%@", [symbols componentsJoinedByString:@","]];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10;
    [manager.requestSerializer setValue:@"https://finance.sina.com.cn/" forHTTPHeaderField:@"Referer"];
    [manager.requestSerializer setValue:@"Mozilla/5.0 iPhone yumengSPMSwift" forHTTPHeaderField:@"User-Agent"];

    [manager GET:urlText parameters:nil headers:nil progress:nil success:^(__unused NSURLSessionDataTask *task, id responseObject) {
        NSData *data = [responseObject isKindOfClass:[NSData class]] ? responseObject : nil;
        NSString *payload = [self decodedSinaPayload:data ?: [NSData data]];
        NSArray<OCMarketQuote *> *quotes = [self parsedQuotesFromPayload:payload baseQuotes:baseQuotes];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(quotes.count > 0 ? quotes : baseQuotes, nil);
        });
    } failure:^(__unused NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(baseQuotes, error);
        });
    }];
}

- (NSString *)decodedSinaPayload:(NSData *)data {
    NSStringEncoding gbEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *payload = [[NSString alloc] initWithData:data encoding:gbEncoding];
    if (payload.length == 0) {
        payload = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return payload ?: @"";
}

- (NSArray<OCMarketQuote *> *)parsedQuotesFromPayload:(NSString *)payload baseQuotes:(NSArray<OCMarketQuote *> *)baseQuotes {
    NSMutableDictionary<NSString *, OCMarketQuote *> *baseBySymbol = [NSMutableDictionary dictionary];
    for (OCMarketQuote *quote in baseQuotes) {
        baseBySymbol[quote.symbol] = quote;
    }

    NSMutableArray<OCMarketQuote *> *results = [NSMutableArray array];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"var hq_str_([^=]+)=\\\"([^\\\"]*)\\\";" options:0 error:nil];
    NSArray<NSString *> *lines = [payload componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    for (NSString *line in lines) {
        NSTextCheckingResult *match = [regex firstMatchInString:line options:0 range:NSMakeRange(0, line.length)];
        if (match.numberOfRanges < 3) {
            continue;
        }

        NSString *symbol = [line substringWithRange:[match rangeAtIndex:1]];
        NSString *rawFields = [line substringWithRange:[match rangeAtIndex:2]];
        OCMarketQuote *base = baseBySymbol[symbol];
        if (!base) {
            continue;
        }

        OCMarketQuote *quote = [base copy];
        [self fillQuote:quote fields:[rawFields componentsSeparatedByString:@","]];
        [results addObject:quote];
    }

    return results;
}

- (void)fillQuote:(OCMarketQuote *)quote fields:(NSArray<NSString *> *)fields {
    if (fields.count == 0) {
        return;
    }

    BOOL firstFieldIsName = ![self isNumericString:fields.firstObject];
    if (firstFieldIsName) {
        quote.name = [self nonEmpty:[self fieldAtIndex:0 fields:fields] fallback:quote.name];
        quote.lastPrice = [self nonEmpty:[self fieldAtIndex:8 fields:fields] fallback:[self nonEmpty:[self fieldAtIndex:7 fields:fields] fallback:@"--"]];
        quote.volumeText = [self nonEmpty:[self fieldAtIndex:13 fields:fields] fallback:@"--"];
        [self fillChangeForQuote:quote last:[self fieldAtIndex:8 fields:fields] previous:[self fieldAtIndex:10 fields:fields]];
    } else {
        quote.lastPrice = [self nonEmpty:[self fieldAtIndex:3 fields:fields] fallback:@"--"];
        quote.volumeText = [self nonEmpty:[self fieldAtIndex:4 fields:fields] fallback:@"--"];
        quote.name = [self nonEmpty:[self fieldAtIndex:41 fields:fields] fallback:quote.name];
        [self fillChangeForQuote:quote last:[self fieldAtIndex:3 fields:fields] previous:[self fieldAtIndex:7 fields:fields]];
    }
}

- (void)fillChangeForQuote:(OCMarketQuote *)quote last:(NSString *)last previous:(NSString *)previous {
    double lastValue = last.doubleValue;
    double previousValue = previous.doubleValue;
    if (lastValue <= 0 || previousValue <= 0) {
        quote.changeText = @"--";
        quote.changePercentText = @"--";
        return;
    }

    double change = lastValue - previousValue;
    quote.changeText = [NSString stringWithFormat:@"%+.2f", change];
    quote.changePercentText = [NSString stringWithFormat:@"%+.2f%%", change / previousValue * 100.0];
}

- (NSString *)fieldAtIndex:(NSUInteger)index fields:(NSArray<NSString *> *)fields {
    return index < fields.count ? fields[index] : nil;
}

- (NSString *)nonEmpty:(NSString *)text fallback:(NSString *)fallback {
    NSString *value = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return value.length > 0 ? value : fallback;
}

- (BOOL)isNumericString:(NSString *)text {
    if (text.length == 0) {
        return NO;
    }
    return [[NSScanner scannerWithString:text] scanDouble:NULL];
}

@end
