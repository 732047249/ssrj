
#import "FilterListViewController.h"
#import "RJFilterBigModel.h"
#import "RJFilterBarndViewController.h"
#import "RJFilterPriceViewController.h"
#import "RJFilterColorViewController.h"
#import "RJFilterCategoryViewController.h"
@interface FilterListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (strong, nonatomic) RJFilterBigModel * model;
@property (assign, nonatomic) BOOL shouldUpLoad;


@end

@implementation FilterListViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self addBarButtonItem:RJNavColseButtonItem onSide:RJNavLeftSide];
    [self addBarButtonItem:RJNavDoneButtonItem onSide:RJNavRightSide];
    
    [self setTitle:@"筛选" tappable:NO];
    self.resetButton.layer.borderColor = [UIColor colorWithHexString:@"#5D32B5"].CGColor;
    self.resetButton.layer.borderWidth = 1;
    self.dataArray = [NSMutableArray array];
    self.shouldUpLoad = NO;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    if ([self.parameterDictionary allKeys].count) {
        
        [requestInfo.getParams addEntriesFromDictionary:self.parameterDictionary];
    }
    requestInfo.URLString = @"/b82/api/v2/product/findproductcategory";
    [[HTUIHelper shareInstance]addHUDToView:self.tableView withString:@"加载中..." xOffset:0 yOffset:0];
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[HTUIHelper shareInstance]removeHUD];
        self.shouldUpLoad = NO;
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                NSDictionary *dic = responseObject[@"data"];
                NSError __autoreleasing *e = nil;
                RJFilterBigModel *model = [[RJFilterBigModel alloc]initWithDictionary:dic error:&e];
                if (model) {
                    [self.dataArray addObjectsFromArray:@[@"分类",@"品牌",@"价钱",@"颜色"]];
                    self.model = model;
                    [self.tableView reloadData];
                }else{
                    [HTUIHelper addHUDToView:self.tableView withString:@"Error" hideDelay:1];
                }
            }else{
                [HTUIHelper addHUDToView:self.tableView withString:@"Error" hideDelay:1];
            }
        }else{
            [HTUIHelper addHUDToView:self.tableView withString:@"Error" hideDelay:1];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance]removeHUD];

        [HTUIHelper addHUDToView:self.tableView withString:@"Error" hideDelay:1];
        self.shouldUpLoad = YES;
    }];
}
- (void)updateFilterDic{
    if (self.dictionary) {
        
        self.filterCategoryArray = [NSMutableArray arrayWithArray:[[self.dictionary objectForKey:@"Category"] mutableCopy]];
        
        self.filterBrandArray = [NSMutableArray arrayWithArray:[[self.dictionary objectForKey:@"Brand"] mutableCopy]];
        
        self.filterPriceArray = [NSMutableArray arrayWithArray:[[self.dictionary objectForKey:@"Price"] mutableCopy]];
        
        self.filterColorArray =[NSMutableArray arrayWithArray:[[self.dictionary objectForKey:@"Color"] mutableCopy]];
        
    }else{
        
        self.filterBrandArray = [NSMutableArray array];
        self.filterCategoryArray = [NSMutableArray array];
        self.filterColorArray =[NSMutableArray array];
        self.filterPriceArray = [NSMutableArray array];
    }

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [MobClick beginLogPageView:@"筛选界面"];
    [TalkingData trackPageBegin:@"筛选界面"];

    
    
    if (self.shouldUpLoad) {
        ZHRequestInfo *requestInfo = [ZHRequestInfo new];
        
        if ([self.parameterDictionary allKeys].count) {
            
            [requestInfo.getParams addEntriesFromDictionary:self.parameterDictionary];
        }
        requestInfo.URLString = @"/b82/api/v2/product/findproductcategory";
        [[HTUIHelper shareInstance]addHUDToView:self.tableView withString:@"加载中..." xOffset:0 yOffset:0];
        [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[HTUIHelper shareInstance]removeHUD];
            self.shouldUpLoad = NO;
            if ([responseObject objectForKey:@"state"]) {
                NSNumber *number = [responseObject objectForKey:@"state"];
                if (number.boolValue == 0) {
                    NSDictionary *dic = responseObject[@"data"];
                    NSError __autoreleasing *e = nil;
                    RJFilterBigModel *model = [[RJFilterBigModel alloc]initWithDictionary:dic error:&e];
                    if (model) {
                        [self.dataArray addObjectsFromArray:@[@"分类",@"品牌",@"价钱",@"颜色"]];
                        self.model = model;
                        [self.tableView reloadData];
                    }else{
                        [HTUIHelper addHUDToView:self.tableView withString:@"Error" hideDelay:1];
                    }
                }else{
                    [HTUIHelper addHUDToView:self.tableView withString:@"Error" hideDelay:1];
                }
            }else{
                [HTUIHelper addHUDToView:self.tableView withString:@"Error" hideDelay:1];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[HTUIHelper shareInstance]removeHUD];

            [HTUIHelper addHUDToView:self.tableView withString:@"Error" hideDelay:1];
            self.shouldUpLoad = YES;
        }];
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"筛选界面"];
    [TalkingData trackPageEnd:@"筛选界面"];

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    FilterListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FilterListViewCell"];
    cell.nameLabel.textColor = [UIColor blackColor];
    if (indexPath.row == 1) {
        if (self.model.brands.count == 1) {
            cell.nameLabel.textColor = [UIColor lightGrayColor];
        }
    }
    cell.nameLabel.text = self.dataArray[indexPath.row];
    cell.choseLabel.hidden = YES;
    switch (indexPath.row) {
        case 0:{
            if (self.filterCategoryArray.count) {
                cell.choseLabel.hidden = NO;
                cell.choseLabel.text = [NSString stringWithFormat:@"%lu个选择",(unsigned long)self.filterCategoryArray.count];
            }
        }
            break;
        case 1:{
            /**
             *  特殊处理
             */
            if (self.model.brands.count == 1) {
                cell.choseLabel.hidden = NO;
                cell.choseLabel.text = @"1个选择";
                break;
            }
            
            if (self.filterBrandArray.count) {
              
                cell.choseLabel.hidden = NO;
                cell.choseLabel.text = [NSString stringWithFormat:@"%lu个选择",(unsigned long)self.filterBrandArray.count];
            }
        }
            break;
        case 2:{
            if (self.filterPriceArray.count) {
                cell.choseLabel.hidden = NO;
                cell.choseLabel.text = [NSString stringWithFormat:@"%lu个选择",(unsigned long)self.filterPriceArray.count];
            }
        }
            break;
        case 3:{
            if (self.filterColorArray.count) {
                cell.choseLabel.hidden = NO;
                cell.choseLabel.text = [NSString stringWithFormat:@"%lu个选择",(unsigned long)self.filterColorArray.count];
            }
        }
            break;
        default:
            break;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    /**
     *  分类
     */
    if (indexPath.row == 0) {
        RJFilterCategoryViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJFilterCategoryViewController"];
        vc.dataArray = [NSMutableArray arrayWithArray:[self.model.category copy]];
        [self.navigationController pushViewController:vc animated:YES];
        vc.selectIdArray = self.filterCategoryArray;
    }
    /**
     *  品牌
     */
    if (indexPath.row == 1) {

        if (self.model.brands.count == 1) {
            return;
        }

        RJFilterBarndViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJFilterBarndViewController"];
        
        vc.dataArray = [NSMutableArray arrayWithArray:[self.model.brands copy]];
//        vc.selectIdArray = [NSMutableArray arrayWithArray:[self.filterBrandArray copy]];
        vc.selectIdArray = self.filterBrandArray;
        [self.navigationController pushViewController:vc animated:YES];
    }
    /**
     *  价格
     */
    if (indexPath.row == 2) {
        
        RJFilterPriceViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJFilterPriceViewController"];
        vc.dataArray = [NSMutableArray arrayWithArray:[self.model.prices copy]];
        vc.selectIdArray = self.filterPriceArray;
        [self.navigationController pushViewController:vc animated:YES];

    }
    /**
     *  颜色
     */
    if (indexPath.row == 3) {
        RJFilterColorViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJFilterColorViewController"];
        vc.dataArray = [NSMutableArray arrayWithArray:[self.model.colors copy]];
        vc.selectIdArray = self.filterColorArray;
        [self.navigationController pushViewController:vc animated:YES];
    }
 
}
- (IBAction)resetButtonAction:(id)sender {
    
    [self.filterBrandArray removeAllObjects];
    [self.filterCategoryArray removeAllObjects];
    [self.filterColorArray removeAllObjects];
    [self.filterPriceArray removeAllObjects];
    [self.tableView reloadData];
}
#pragma mark - 完成按钮

- (void)done:(id)sender{
    
    self.dictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"Category":self.filterCategoryArray,
                                                                      @"Brand":self.filterBrandArray,
                                                                      @"Price":self.filterPriceArray,
                                                                      @"Color":self.filterColorArray}];
    if (self.delegate) {
        
        [self.delegate filiterDownWithDictionary:self.dictionary shouldReload:YES];
        
        if ([self.delegate isKindOfClass:NSClassFromString(@"RJBrandDetailGoodsViewController")]) {
            
            if ([self.delegate respondsToSelector:@selector(filiterRJBrandRootVCInGoodVC)]) {
                
                [self.delegate filiterRJBrandRootVCInGoodVC];
                
            }
        }
        
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)dismiss:(id)sender{
    if (self.delegate) {
        [self.delegate filiterDownWithDictionary:self.dictionary shouldReload:NO];
    }
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

@end


@implementation FilterListViewCell
- (void)awakeFromNib{
    [super awakeFromNib];
    self.choseLabel.hidden = YES;
}

@end
