//
//  SMMatchDiscriptController.m
//  ssrj
//
//  Created by MFD on 16/11/3.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMMatchDiscriptController.h"
#import "SMMatchDisCriptDetailViewController.h"
#import "SMMatchDiscriptHeader.h"
#import "SMMatchDiscriptCell.h"

#import "SMBrandsModel.h"
static NSString * const AllBrandsUrl = @"/b180/api/v1/goodsinfor/brands";
@interface SMMatchDiscriptController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray<SMBrandsModel *> *dataArray;
@property (nonatomic,strong)NSMutableArray<SMBrandsModel *> *filterArray;
@property (nonatomic,strong)SMMatchDiscriptHeader *header;

@end

@implementation SMMatchDiscriptController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _filterArray = [NSMutableArray array];
    [self addBackButton];
    self.title = @"添加单品";
    [self getNetData];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    
    [MobClick beginLogPageView:@"上传搭配-品牌列表页面"];
    [TalkingData trackPageBegin:@"上传搭配-品牌列表页面"];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_header.textField resignFirstResponder];
    
    [MobClick endLogPageView:@"上传搭配-品牌列表页面"];
    [TalkingData trackPageEnd:@"上传搭配-品牌列表页面"];
}
- (void)initUI {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    _header = [[SMMatchDiscriptHeader alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:_header.textField];
    [_header.cancelBtn addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchUpInside];
    _tableView.tableHeaderView = _header;
    _tableView.tableFooterView = [UIView new];
    
}

/** 
 "data":[
 {
 "name":"WOW Couture",
 "id":70
 },......
 */
#pragma mark - data
//http://192.168.1.173:9999/api/v1/goodsinfor/brands
- (void)getNetData{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = AllBrandsUrl;
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) {
            if ([responseObject[@"state"] intValue] == 0) {
                NSArray *dictArr = responseObject[@"data"];
                if ([dictArr isKindOfClass:[NSArray class]]) {
                    [weakSelf.dataArray removeAllObjects];
                    for (NSDictionary *dict in dictArr) {
                        NSError *error = nil;
                        SMBrandsModel *model = [[SMBrandsModel alloc] initWithDictionary:dict error:&error];
                        [weakSelf.dataArray addObject:model];
                    }
                }
                [self initUI];
                for (SMBrandsModel *model in weakSelf.dataArray) {
                    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:model.name];
                    model.attributeString = string;
                    [weakSelf.filterArray addObject:model];
                }
            }else{
                [HTUIHelper addHUDToView:weakSelf.view withString:responseObject[@"msg"] hideDelay:1];
            }
        }
        [hud hide:YES];
        [weakSelf.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hide:YES];
        [HTUIHelper addHUDToView:weakSelf.view withString:@"Error" hideDelay:1];
    }];
}
#pragma mark - event

- (void)cancelClick:(UIButton *)sender {
    [_header.textField resignFirstResponder];
    _header.textField.text = @"";
    
    [self.filterArray removeAllObjects];
    for (SMBrandsModel *model in self.dataArray) {
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:model.name];
        model.attributeString = string;
        [self.filterArray addObject:model];
    }
    [_tableView reloadData];
}
- (void)textFieldChanged:(NSNotification *)notify {
    UITextField *textField = notify.object;
    [self searchArrayWithString:textField.text];
}
#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filterArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SMMatchDiscriptCell *cell = [tableView dequeueReusableCellWithIdentifier:@"pinpai"];
    if (!cell) {
        cell = [[SMMatchDiscriptCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"pinpai"];
        cell.selectionStyle = UITableViewCellAccessoryNone;
    }
    SMBrandsModel *model = self.filterArray[indexPath.row];
    cell.label.attributedText = model.attributeString;
    cell.trackingId = [NSString stringWithFormat:@"%@&SMMatchDiscriptCell&id=%@",NSStringFromClass(self.class),model.ID];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    SMBrandsModel *model = self.filterArray[indexPath.row];
    SMMatchDisCriptDetailViewController *detail = [[SMMatchDisCriptDetailViewController alloc] init];
    detail.selectBrandsName = model.name;
    detail.brandId = model.ID;
    detail.isAddTag = self.isAddTag;
    [self.navigationController pushViewController:detail animated:YES];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_header.textField resignFirstResponder];
}
#pragma mark - set get
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
#pragma mark - 排序算法
/** 根据输入的内容，排序 */
- (void)searchArrayWithString:(NSString *)string {
    [_filterArray removeAllObjects];
    //如果没有输入任何文字，则显示全部品牌
    if ([string isEqualToString:@""] || string == nil) {
        for (SMBrandsModel *model in self.dataArray) {
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:model.name];
            model.attributeString = string;
            [self.filterArray addObject:model];
        }
        [_tableView reloadData];
        return;
    }
    //显示包含某字段的品牌。
    //包含某字段的品牌，无排序
    NSMutableArray *tempFilterArray = [NSMutableArray array];
    for (SMBrandsModel *model in self.dataArray) {
        NSRange range = [model.name rangeOfString:string options:NSCaseInsensitiveSearch];
        if (range.length) {
            NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:model.name];
            [attribute addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:15]} range:range];
            model.attributeString = attribute;
            [tempFilterArray addObject:model];
        }
    }
    //排序
    NSArray *arr = [tempFilterArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        SMBrandsModel *model1 = obj1;
        SMBrandsModel *model2 = obj2;
        NSRange range1 = [model1.name rangeOfString:string options:NSCaseInsensitiveSearch];
        
        NSRange range2 = [model2.name rangeOfString:string options:NSCaseInsensitiveSearch];
        NSComparisonResult result = [[NSNumber numberWithInteger:range1.location] compare:[NSNumber numberWithInteger:range2.location]] ;
        return result;
    }];
    [self.filterArray addObjectsFromArray:arr];
    [self.tableView reloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
