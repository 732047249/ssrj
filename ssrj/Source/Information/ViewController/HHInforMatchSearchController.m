//
//  HHInforMatchSearchController.m
//  ssrj
//
//  Created by 夏亚峰 on 16/12/12.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "HHInforMatchSearchController.h"
#import "SMSearchDetailController.h"
#import "HHInforMatchSearchDetailViewController.h"
#import "Masonry.h"

static NSString * const SearchListUrl = @"/b180/api/v1/goodsinfor/collocation";
@interface HHInforMatchSearchController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UITextFieldDelegate>
@property (nonatomic,strong)UITableView *tableView;
//帅选出的数据
@property (strong, nonatomic) NSMutableArray *filterArr;
//所有数据
@property (strong, nonatomic) NSMutableArray *allArray;
@end

@implementation HHInforMatchSearchController

- (void)viewDidLoad {
    [super viewDidLoad];
    _filterArr = [NSMutableArray array];
    _allArray = [NSMutableArray array];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self configNav];
    [self configTableView];
    [self getNetData];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [MobClick beginLogPageView:@"创建资讯-搭配名称列表页面"];
    [TalkingData trackPageBegin:@"创建资讯-搭配名称列表页面"];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"创建资讯-搭配名称列表页面"];
    [TalkingData trackPageEnd:@"创建资讯-搭配名称列表页面"];
}
- (void)configTableView {
    _tableView = [[UITableView alloc]init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(64);
    }];
}
- (void)configNav {
    UIView *bar = [UIView new];
    bar.backgroundColor = APP_BASIC_COLOR;
    [self.view addSubview:bar];
    
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor colorWithHexString:@"#e5e5e5"];
    view.layer.cornerRadius = 5.0;
    view.layer.masksToBounds = YES;
    [bar addSubview:view];
    
    
    UITextField *textField = [[UITextField alloc]init];
    textField.placeholder = @"搜索搭配";
    textField.delegate = self;
    textField.returnKeyType = UIKeyboardTypeDefault;
    [textField addTarget:self action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [view addSubview:textField];
    
    UIImageView *searchImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"search_icon2"]];
    searchImageView.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:searchImageView];
    
    UIButton *cancelBtn = [[UIButton alloc]init];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [cancelBtn addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [bar addSubview:cancelBtn];
    
    
    [bar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(64);
    }];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(27, 8, 7, 50));
    }];
    [searchImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(10);
        make.centerY.equalTo(view);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(searchImageView.mas_right).offset(5);
        make.top.right.bottom.equalTo(view);
    }];
    
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(view);
        make.left.equalTo(view.mas_right);
        make.right.equalTo(bar);
    }];
    
    
}
//搜索下拉框数据接口
/** http://192.168.1.173:9999/api/v1/goodsinfor/goods?token=227a1368bd09faa8f94d9181710ba533&appVersion=22
 
 "data": ["灰色小脚裤", "深蓝色卡林织无袖上衣", "白色双肩带露背连衣裙",
 
 */
- (void)getNetData {
    
    __weak typeof (&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = SearchListUrl;
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject[@"state"] boolValue] == 0) {
            [weakSelf.allArray removeAllObjects];
            [weakSelf.filterArr removeAllObjects];
            [weakSelf.allArray addObjectsFromArray:responseObject[@"data"]];
            for (NSString *string in weakSelf.allArray) {
                NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:string];
                [weakSelf.filterArr addObject:attribute];
            }
            [weakSelf.tableView reloadData];
        }else {
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
    }];
    
}
#pragma mark - event
- (void)cancelButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}
- (void)textFieldEditChanged:(UITextField *)textField {
    [self searchArrayWithString:textField.text];
}
#pragma mark - tableViewdelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filterArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.attributedText = self.filterArr[indexPath.row];
    cell.trackingId = [NSString stringWithFormat:@"HHInforMatchSearchController&UITableViewCell&name=%@",self.filterArr[indexPath.row]];
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    NSString *selectString = [self.filterArr[indexPath.row] string];
    HHInforMatchSearchDetailViewController *searchDetail = [[HHInforMatchSearchDetailViewController alloc] init];
    searchDetail.searchName = selectString;
    [self.navigationController pushViewController:searchDetail animated:YES];
}
#pragma mark - scrollViewdelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}
#pragma mark - 排序算法
/** 根据输入的内容，排序 */
- (void)searchArrayWithString:(NSString *)string {
    [_filterArr removeAllObjects];
    //如果没有输入任何文字，则显示全部品牌
    if ([string isEqualToString:@""] || string == nil) {
        for (NSString *string in self.allArray) {
            NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:string];
            [self.filterArr addObject:attributeStr];
        }
        [_tableView reloadData];
        return;
    }
    //显示包含某字段的品牌。
    //包含某字段的品牌，无排序
    NSMutableArray *tempFilterArray = [NSMutableArray array];
    for (NSString *allStr in self.allArray) {
        NSRange range = [allStr rangeOfString:string options:NSCaseInsensitiveSearch];
        if (range.length) {
            NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:allStr];
            [attribute addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:17]} range:range];
            [tempFilterArray addObject:attribute];
        }
    }
    //排序
    NSArray *arr = [tempFilterArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSMutableAttributedString *attribute1 = obj1;
        NSMutableAttributedString *attribute2 = obj2;
        NSRange range1 = [attribute1.string rangeOfString:string options:NSCaseInsensitiveSearch];
        
        NSRange range2 = [attribute2.string rangeOfString:string options:NSCaseInsensitiveSearch];
        NSComparisonResult result = [[NSNumber numberWithInteger:range1.location] compare:[NSNumber numberWithInteger:range2.location]] ;
        return result;
    }];
    [self.filterArr addObjectsFromArray:arr];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
