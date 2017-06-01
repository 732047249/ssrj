//
//  SMAllGoodsViewController.m
//  ssrj
//
//  Created by 夏亚峰 on 16/11/14.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMAllGoodsViewController.h"
#import "SMCreateMatchController.h"
#import "AJPhotoPickerViewController.h"
#import "SMAllGoodsSearchView.h"
#import "SMAllGoodsAndSourceModel.h"
#import "SMSearchGoodsController.h"
#import "SMCategaryDetailController.h"
#import "SMAllGoodsCell.h"
#import "Masonry.h"
static NSString * const CurrentUrl = @"/b180/api/v1/collocation/home";
static NSString * const UploadImageUrl = @"/b180/api/v1/collocationupload/uploadimage";
@interface SMAllGoodsViewController ()<UITableViewDelegate,UITableViewDataSource,SMAllGoodsSearchViewDelegate,AJPhotoPickerProtocol>

@property (nonatomic,strong)SMAllGoodsSearchView *searchView;
@property (nonatomic,strong)UITableView *tableView;
@property (strong,nonatomic)NSMutableArray *fashionDataArray;
@end

@implementation SMAllGoodsViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"创建搭配-所有单品页面"];
    [TalkingData trackPageBegin:@"创建搭配-所有单品页面"];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"创建搭配-所有单品页面"];
    [TalkingData trackPageEnd:@"创建搭配-所有单品页面"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _fashionDataArray = [NSMutableArray array];
    [self configSearchView];
    [self configTableView];
    [self getSourceAndAllGoodsData];
    
    __weak __typeof(&*self)weakSelf = self;
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getSourceAndAllGoodsData];
    }];
}
#pragma mark - UI
- (void)configSearchView {
    _searchView = [[SMAllGoodsSearchView alloc] init];
    _searchView.delegate = self;
    [self.view addSubview:_searchView];
    [_searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view);
    }];
}
- (void)configTableView {
    _tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(_searchView.mas_bottom);
    }];
}
#pragma mark - network
- (void)getSourceAndAllGoodsData {
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = CurrentUrl;
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"state"] intValue] == 0) {
            [weakSelf.fashionDataArray removeAllObjects];
            NSArray *data = responseObject[@"data"];
            NSDictionary *dataDict = [data firstObject];
            if (dataDict && [dataDict isKindOfClass:[NSDictionary class]]) {
                for (NSDictionary *fashDict in dataDict[@"fashion"]) {
                    NSError *error;
                    SMAllGoodsAndSourceModel *fashion = [[SMAllGoodsAndSourceModel alloc] initWithDictionary:fashDict error:&error];
                    if (!error) {
                        [self.fashionDataArray addObject:fashion];
                    }
                }
            }
            [weakSelf.tableView reloadData];
            [weakSelf.tableView.mj_header endRefreshing];
        }else{
            [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow withString:responseObject[@"msg"] hideDelay:1];
            [weakSelf.tableView.mj_header endRefreshing];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow  withString:@"Error" hideDelay:2];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
}
#pragma mark - delegate
#pragma mark -- searchBarDelegate

- (void)didClickCamara {
    //判断用户是否登录
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
        return;
    }
    AJPhotoPickerViewController *picker = [[AJPhotoPickerViewController alloc] init];
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.showEmptyGroups = YES;
    picker.minimumNumberOfSelection = 1;
    picker.maximumNumberOfSelection = 9;
    picker.multipleSelection = NO;
    picker.shouldClip = YES;
    picker.delegate = self;
    picker.cropMode = RSKImageCropModeSquare;
    
    picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return YES;
    }];
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:picker];
    [nav setNavigationBarHidden:YES];
    [self presentViewController:nav animated:YES completion:nil];
}
- (void)didClickSearchView {
    SMSearchGoodsController *vc = [SMSearchGoodsController new];
    vc.isFromAllGoods = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark -- tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fashionDataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SMAllGoodsAndSourceModel *model = self.fashionDataArray[indexPath.row];
    SMAllGoodsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SMAllGoodsCell"];
    if (!cell) {
        cell = [[SMAllGoodsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SMAllGoodsCell"];
    }
    cell.nameLabel.text = model.title;
    [cell.picImageView sd_setImageWithURL:[NSURL URLWithString:model.icon] placeholderImage:[UIImage imageNamed:@"placeHodler"]];
    cell.trackingId = [NSString stringWithFormat:@"SMAllGoodsViewController&SMAllGoodsCell&id=%@",model.ID];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SMCategaryDetailController *detail = [SMCategaryDetailController new];
    detail.tabbarArray = self.fashionDataArray;
    detail.isFromAllGoods = YES;
    detail.selectIndex = indexPath.row;
    [self.navigationController pushViewController:detail animated:YES];
}
#pragma mark -- photoDelegate

- (void)photoPickerDidClipImageDone:(UIImage *)image {
    [self updateImageNet:image];
}
- (void)updateImageNet:(UIImage *)image {
    [[HTUIHelper shareInstance] addHUDToView:self.view withString:@"加载中" xOffset:0 yOffset:0];
    
    NSData *imagedata = UIImageJPEGRepresentation(image, 1);
    float qulity = 1;
    NSData *minData = [NSData dataWithData:imagedata];
    while (imagedata.length > 50 * 1024 && qulity >= 0.2) {
        qulity -= 0.1;
        imagedata = UIImageJPEGRepresentation(image, qulity);
        if (imagedata.length < minData.length) {
            minData = imagedata;
        }
    }
    if (imagedata.length > 50 * 1024) {
        imagedata = minData;
    }
    NSString *base64Str = [imagedata base64EncodedStringWithOptions:0];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"jpg" forKey:@"format"];
    [dict setObject:base64Str forKey:@"image"];
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = UploadImageUrl;
    requestInfo.postParams = dict;
    [[ZHNetworkManager sharedInstance] postWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"state"] intValue] == 0) {
            if ([weakSelf.navigationController.parentViewController isKindOfClass:[SMCreateMatchController class]]) {
                SMCreateMatchController *createMatchVC = (SMCreateMatchController *)weakSelf.navigationController.parentViewController;
                
                SMGoodsModel *goodsModel = [[SMGoodsModel alloc] init];
                goodsModel.image = responseObject[@"data"][@"image"];
                [createMatchVC addGoodsOrSourceWithModel:goodsModel];
            }
        }else {
            [HTUIHelper addHUDToWindowWithString:responseObject[@"msg"] hideDelay:1];
        }
        [[HTUIHelper shareInstance] removeHUD];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToWindowWithString:@"error" hideDelay:1];
        [[HTUIHelper shareInstance] removeHUD];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
