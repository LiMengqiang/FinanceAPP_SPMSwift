#import "OCMarketViewController.h"
#import "OCMarketQuote.h"
#import "OCQuoteService.h"
#import "OCQuoteTableViewCell.h"

@interface OCMarketViewController ()

@property (nonatomic, strong) OCQuoteService *quoteService;
@property (nonatomic, copy) NSArray<OCMarketQuote *> *quotes;
@property (nonatomic, strong) UILabel *statusLabel;

@end

@implementation OCMarketViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"OC行情";
    self.quoteService = [[OCQuoteService alloc] init];
    self.quotes = [OCMarketQuote defaultFutures];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshQuotes)];

    self.view.backgroundColor = [self colorWithHex:0xF3F6FA];
    self.tableView.backgroundColor = [self colorWithHex:0xF3F6FA];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 74;
    self.tableView.tableHeaderView = [self makeHeaderView];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshQuotes) forControlEvents:UIControlEventValueChanged];
    [self refreshQuotes];
}

- (UIView *)makeHeaderView {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 72)];
    header.backgroundColor = [self colorWithHex:0xF3F6FA];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 220, 24)];
    titleLabel.text = @"AFNetworking 请求";
    titleLabel.font = [UIFont boldSystemFontOfSize:21];
    titleLabel.textColor = [self colorWithHex:0x111827];
    [header addSubview:titleLabel];

    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 40, 320, 18)];
    self.statusLabel.text = @"新浪实时行情";
    self.statusLabel.font = [UIFont systemFontOfSize:12];
    self.statusLabel.textColor = [self colorWithHex:0x6B7280];
    [header addSubview:self.statusLabel];
    return header;
}

- (void)refreshQuotes {
    __weak typeof(self) weakSelf = self;
    [self.quoteService fetchQuotesWithCompletion:^(NSArray<OCMarketQuote *> *quotes, NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) {
            return;
        }

        [self.refreshControl endRefreshing];
        self.quotes = quotes;
        if (!error) {
            self.statusLabel.text = [NSString stringWithFormat:@"新浪实时行情 · 已更新 %@", [self timeText]];
            [self.tableView reloadData];
        } else {
            [self.tableView reloadData];
            [self showMessage:@"OC行情刷新失败，请稍后重试"];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.quotes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OCQuoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OCQuoteCell"];
    if (!cell) {
        cell = [[OCQuoteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"OCQuoteCell"];
    }
    [cell configureWithQuote:self.quotes[indexPath.row]];
    return cell;
}

- (void)showMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSString *)timeText {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm:ss";
    return [formatter stringFromDate:[NSDate date]];
}

- (UIColor *)colorWithHex:(NSUInteger)hex {
    return [UIColor colorWithRed:((hex >> 16) & 0xFF) / 255.0
                           green:((hex >> 8) & 0xFF) / 255.0
                            blue:(hex & 0xFF) / 255.0
                           alpha:1.0];
}

@end
