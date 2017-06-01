
#import "RJFilterCategoryViewController.h"
#import "RJFilterCategoryModel.h"
#define CategoryHeaderIdentity @"CategoryHeaderIdentity"

@interface RJFilterCategoryViewController ()<UITableViewDataSource,UITableViewDelegate,RJFilterCategoryHeaderViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
/**
 *  临时数组 用于存放上个界面传递过来的数据 当点击保存时候才赋值给上个界面 点击返回按钮不保存
 */
@property (nonatomic,strong) NSMutableArray * tempArray;

@end

@implementation RJFilterCategoryViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self addSaveButton];
    [self addCloseButton];
    [self setTitle:@"分类" tappable:NO];
    self.tempArray = [NSMutableArray array];
    if (self.selectIdArray) {
        self.tempArray = [NSMutableArray arrayWithArray:[self.selectIdArray mutableCopy]];
    }
    self.resetButton.layer.borderColor = [UIColor colorWithHexString:@"#5D32B5"].CGColor;
    self.resetButton.layer.borderWidth = 1;
    [self.tableView registerClass:[RJFilterCategoryHeaderView class] forHeaderFooterViewReuseIdentifier:CategoryHeaderIdentity];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    RJFilterCategoryModel *model = self.dataArray[section];
    return model.isOpen.boolValue?model.children.count:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RJFilterCategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RJFilterCategoryTableViewCell" forIndexPath:indexPath];
    RJFilterCategoryModel *model = self.dataArray[indexPath.section];
    RJFilterCategoryChildrenModel *itemModel = model.children[indexPath.row];
    cell.nameLabel.text = itemModel.content;
    cell.selectImageView.highlighted = NO;
    if ([self.tempArray containsObject:itemModel.pro]) {
        cell.selectImageView.highlighted = YES;
    }
    return cell;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    RJFilterCategoryHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:CategoryHeaderIdentity];
    headerView.delegate = self;
    RJFilterCategoryModel *model = self.dataArray[section];
    headerView.model = model;
    headerView.titleLabel.text = model.content;
    headerView.imageView.image = model.isOpen.boolValue?[UIImage imageNamed:@"sort_section_up"]:[UIImage imageNamed:@"sort_section_down"];
    [headerView.iconImageView sd_setImageWithURL:[NSURL URLWithString:model.image]];
    headerView.contentView.backgroundColor = [UIColor whiteColor];
    return headerView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RJFilterCategoryModel *model = self.dataArray[indexPath.section];
    RJFilterCategoryChildrenModel *itemModel = model.children[indexPath.row];
    if ([self.tempArray containsObject:itemModel.pro]) {
        [self.tempArray removeObject:itemModel.pro];
    }else{
        [self.tempArray addObject:itemModel.pro];
    }
    [self.tableView reloadData];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 54;
}
- (void)didClickHeaderView:(RJFilterCategoryHeaderView *)headerView{
    [self.tableView reloadData];

}
- (IBAction)resetButtonAction:(id)sender {
    [self.tempArray removeAllObjects];
    [self.tableView reloadData];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick beginLogPageView:@"筛选分类界面"];
    [TalkingData trackPageBegin:@"筛选分类界面"];


}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick endLogPageView:@"筛选分类界面"];
    [TalkingData trackPageEnd:@"筛选分类界面"];


}
- (void)save:(id)sender{
    [self.selectIdArray removeAllObjects];
    [self.selectIdArray addObjectsFromArray:[self.tempArray mutableCopy]];
    [self.navigationController popViewControllerAnimated:YES];
}
@end








@implementation RJFilterCategoryTableViewCell



@end

@implementation RJFilterCategoryHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self initView];
    }
    return self;
}
- (void)initView{
    UILabel *label = [[UILabel alloc]init];
    label.font = [UIFont systemFontOfSize:19];
    self.titleLabel = label;
    [self addSubview:self.titleLabel];
    self.titleLabel.textColor = [UIColor colorWithHexString:@"#464646"];
    UIImageView *imageView =[[UIImageView alloc]init];
    
    imageView.image = GetImage(@"sort_section_down");
    [self addSubview:imageView];
    self.imageView = imageView;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureAction:)];
    [self addGestureRecognizer:tapGesture];
    self.userInteractionEnabled = YES;
    
    self.lineLabel = [[UILabel alloc]init];
    self.lineLabel.backgroundColor = [UIColor colorWithHexString:@"#e5e5e5"];
    [self addSubview:_lineLabel];
    
    self.iconImageView = [[UIImageView alloc]init];
    [self addSubview:_iconImageView];
    
}
- (void)tapGestureAction:(UITapGestureRecognizer *)tagGesture{
  
    self.model.isOpen = [NSNumber numberWithBool:!self.model.isOpen.boolValue];

    if ([self.delegate respondsToSelector:@selector(didClickHeaderView:)]) {
        [self.delegate didClickHeaderView:self];
    }
}
-(void)layoutSubviews{
    [super layoutSubviews];
    self.titleLabel.frame = CGRectMake(65, 0, 200, self.height);
    self.imageView.frame = CGRectMake(self.width - 35, 20, 20, 20);
    self.lineLabel.frame = CGRectMake(10, self.height-1, self.width-20, 1);
    self.iconImageView.frame = CGRectMake(20, 15, 30, 30);
}
-(void)prepareForReuse{
    [super prepareForReuse];
    
}
@end
