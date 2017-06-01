//
//  SMMatchDisCriptDetailViewController.m
//  ssrj
//
//  Created by MFD on 16/11/3.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMMatchDisCriptDetailViewController.h"
#import "SMMatchDiscriptDetailHeader.h"
#import "SMMatchDiscriptCell.h"
#import "SMAddTagViewController.h"
#import "TagModel.h"
#import "SMGoodsModel.h"
#import "Masonry.h"
static NSString * const BrandsGoodsUrl = @"/b180/api/v1/goodsinfor/brand_goods";
@interface SMMatchDisCriptDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIScrollViewDelegate>

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataArray;//请求到的数组
@property (nonatomic,strong)NSMutableArray *filterArray;//过滤后的商品名字数组
@property (nonatomic,strong)SMMatchDiscriptDetailHeader *header;
@property (nonatomic,strong)NSIndexPath *indexPath;

@end

@implementation SMMatchDisCriptDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _filterArray = [NSMutableArray array];
    self.view.backgroundColor = [UIColor whiteColor];
    [self addBackButton];
    self.title = @"添加单品";
    [self initUI];
    [self getNetData];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"上传搭配-单品列表页面"];
    [TalkingData trackPageBegin:@"上传搭配-单品列表页面"];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_header.textField resignFirstResponder];
    
    [MobClick endLogPageView:@"上传搭配-单品列表页面"];
    [TalkingData trackPageEnd:@"上传搭配-单品列表页面"];
}
- (void)initUI {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _header = [[SMMatchDiscriptDetailHeader alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44+44+10)];
    [_header.cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchDown];
    _tableView.tableHeaderView = _header;
    _header.label.text = self.selectBrandsName;
    _tableView.tableFooterView = [UIView new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:_header.textField];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(clickNextBtn:)];
}
/** http://192.168.1.173:9999/api/v1/goodsinfor/brand_goods?appVersion=2.2.0&brand_id=122&token=daf1a91acee1be236510cc2bd1873b49
 "data":[
 {
 "name":"黑色连衣裙",
 "brand":71,
 "brand_name":"Tahari by ASL",
 "price":"1064.000000",
 "market_price":"1277.000000",
 "image":"http://www.ssrj.com/upload/image/201604/b6340186-753b-4b72-9ffd-506c6daa001e-large.png",
 "id":336
 },......
 */
#pragma mark - data
//http://192.168.1.173:9999/api/v1/goodsinfor/brand_goods?appVersion=2.2.0&brand_id=71
- (void)getNetData{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = BrandsGoodsUrl;
    [requestInfo.getParams addEntriesFromDictionary:@{@"brand_id":self.brandId}];
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) {
            if ([responseObject[@"state"] intValue] == 0) {
                [weakSelf.dataArray removeAllObjects];
                NSArray *dicArr = responseObject[@"data"];
                if ([dicArr isKindOfClass:[NSArray class]]) {
                    for (NSDictionary *dic in dicArr) {
                        NSError *error = nil;
                        SMGoodsModel *model = [[SMGoodsModel alloc] initWithDictionary:dic error:&error];
                        if (model) {
                            [weakSelf.dataArray addObject:model];
                        }
                    }
                }
                for (SMGoodsModel *model in weakSelf.dataArray) {
                    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:model.name];
                    model.attributeString = string;
                    [weakSelf.filterArray addObject:model];
                }
            }else{
                [HTUIHelper addHUDToView:weakSelf.view withString:responseObject[@"msg"] hideDelay:1];
            }
            [weakSelf.tableView reloadData];
        }
        [hud hide:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:weakSelf.view withString:@"Error" hideDelay:2];
        [hud hide:YES];
    }];
}
#pragma mark - event
- (void)cancelBtnClick {
    [_header.textField resignFirstResponder];
    _header.textField.text = @"";
    
    [self.filterArray removeAllObjects];
    for (SMGoodsModel *model in self.dataArray) {
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:model.name];
        model.attributeString = string;
        [self.filterArray addObject:model];
    }
    [_tableView reloadData];

}

- (void)selectedGoods {
    SMGoodsModel *model = self.filterArray[_indexPath.row];
    _header.textField.text = model.name;
    
    //构建model对象
    TagModel *tagModel = [[TagModel alloc] init];
    tagModel.tagText = [NSString stringWithFormat:@"%@%@",self.selectBrandsName, model.name];
    tagModel.isAddTag = self.isAddTag;
    tagModel.goodsId = model.ID;
    tagModel.brandId = model.brand;
    tagModel.goodsModel = model;
    
    //返回SMAddTagViewController 页
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[SMAddTagViewController class]]) {
            SMAddTagViewController *addVc = (SMAddTagViewController *)vc;
            [addVc addTagWithTagModel:tagModel];
            [self.navigationController popToViewController:addVc animated:YES];
        }
    }
}
- (void)clickNextBtn:(UIButton *)sender {
    if (_indexPath == nil) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.labelText = @"请选择商品";
        hud.mode = MBProgressHUDModeText;
        [hud hide:YES afterDelay:2];
    }else {
        SMGoodsModel *model = self.filterArray[_indexPath.row];
        _header.textField.text = model.name;
        
        //构建model对象
        TagModel *tagModel = [[TagModel alloc] init];
        tagModel.tagText = [NSString stringWithFormat:@"%@%@",self.selectBrandsName, model.name];
        tagModel.isAddTag = self.isAddTag;
        tagModel.goodsId = model.ID;
        tagModel.brandId = model.brand;
        tagModel.goodsModel = model;
        
        //返回SMAddTagViewController 页
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[SMAddTagViewController class]]) {
                SMAddTagViewController *addVc = (SMAddTagViewController *)vc;
                [addVc addTagWithTagModel:tagModel];
                [self.navigationController popToViewController:addVc animated:YES];
            }
        }
    }
    
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
    SMMatchDiscriptCell *cell = [tableView dequeueReusableCellWithIdentifier:@"goods"];
    if (!cell) {
        cell = [[SMMatchDiscriptCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"goods"];
    }
    SMGoodsModel *model = self.filterArray[indexPath.row];
    cell.label.attributedText = model.attributeString;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SMGoodsModel *model = self.filterArray[indexPath.row];
    _header.textField.text = model.name;
    
    //构建model对象
    TagModel *tagModel = [[TagModel alloc] init];
    tagModel.tagText = [NSString stringWithFormat:@"%@%@",self.selectBrandsName, model.name];
    tagModel.isAddTag = self.isAddTag;
    tagModel.goodsId = model.ID;
    tagModel.brandId = model.brand;
    tagModel.goodsModel = model;
    
    //返回SMAddTagViewController 页
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[SMAddTagViewController class]]) {
            SMAddTagViewController *addVc = (SMAddTagViewController *)vc;
            [addVc addTagWithTagModel:tagModel];
            [self.navigationController popToViewController:addVc animated:YES];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_header.textField resignFirstResponder];
}
#pragma mark - textField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    return YES;
}
#pragma mark - set get
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - other
- (void)searchArrayWithString:(NSString *)string {
    [_filterArray removeAllObjects];
    
    //如果没有输入任何文字，则显示全部品牌
    if ([string isEqualToString:@""] || string == nil) {
        for (SMGoodsModel *model in self.dataArray) {
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
    for (SMGoodsModel *model in self.dataArray) {
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
        SMGoodsModel *model1 = obj1;
        SMGoodsModel *model2 = obj2;
        NSRange range1 = [model1.name rangeOfString:string options:NSCaseInsensitiveSearch];
        
        NSRange range2 = [model2.name rangeOfString:string options:NSCaseInsensitiveSearch];
        NSComparisonResult result = [[NSNumber numberWithInteger:range1.location] compare:[NSNumber numberWithInteger:range2.location]] ;
        return result;
    }];
    [self.filterArray addObjectsFromArray:arr];
    [self.tableView reloadData];
}


@end
