
#import "RJFilterBarndViewController.h"
#import "RJFilterBrandModel.h"
@interface RJFilterBarndViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
/**
 *  临时数组 用于存放上个界面传递过来的数据 当点击保存时候才赋值给上个界面 点击返回按钮不保存
 */
@property (nonatomic,strong) NSMutableArray * tempArray;
@end

@implementation RJFilterBarndViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self addSaveButton];
    [self addCloseButton];
    [self setTitle:@"品牌" tappable:NO];
    self.tempArray = [NSMutableArray array];
    if (self.selectIdArray) {
        self.tempArray = [NSMutableArray arrayWithArray:[self.selectIdArray mutableCopy]];
    }
    self.resetButton.layer.borderColor = [UIColor colorWithHexString:@"#5D32B5"].CGColor;
    self.resetButton.layer.borderWidth = 1;
   
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RJFilterBarndViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RJFilterBarndViewCell"];
    RJFilterBrandModel *model = self.dataArray[indexPath.row];
    cell.nameLabel.text = model.content;
    
    cell.selectImageView.highlighted = NO;
    if ([self.tempArray containsObject:model.pro]) {
        cell.selectImageView.highlighted = YES;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RJFilterBrandModel *model = self.dataArray[indexPath.row];
    
    if ([self.tempArray containsObject:model.pro]) {
        [self.tempArray removeObject:model.pro];
    }else{
        [self.tempArray addObject:model.pro];
    }
    [self.tableView reloadData];
}

- (IBAction)resetButtonAction:(id)sender {
    [self.tempArray removeAllObjects];
    [self.tableView reloadData];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick beginLogPageView:@"筛选品牌界面"];
    [TalkingData trackPageBegin:@"筛选品牌界面"];

    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick endLogPageView:@"筛选品牌界面"];
    [TalkingData trackPageEnd:@"筛选品牌界面"];

    
}
- (void)save:(id)sender{
    [self.selectIdArray removeAllObjects];
    [self.selectIdArray addObjectsFromArray:[self.tempArray mutableCopy]];
    [self.navigationController popViewControllerAnimated:YES];
}
@end



@implementation RJFilterBarndViewCell
- (void)awakeFromNib{
    [super awakeFromNib];
}
@end