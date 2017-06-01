//
//  SMPublishMatchController.m
//  ssrj
//
//  Created by MFD on 16/11/5.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMPublishMatchController.h"
#import "SearchForCreateMatchViewController.h"
#import "SMPublishFinishedController.h"
#import "SMMatchDiscriptHeader.h"
#import "SMPublishMatchHeader.h"
#import "SMThemeCell.h"
#import "SMThemeModel.h"
#import "Masonry.h"
#import "UIButton+ImageTitleSpacing.h"

#define LeftRightMargin 15
#define BetweenMargin  8
#define TopMargin  15
#define ButtonHeight 24

static NSString * const MyThemeUrl = @"/b180/api/v1/collocationupload/mytheme";
static NSString * const PublishTagUrl = @"/b180/api/v1/collocationupload/publishupload";
static NSString * const PublishMatchUrl = @"/b180/api/v1/collocation/publish";

@interface SMPublishMatchController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIScrollViewDelegate,SearchForCreateMatchViewControllerDelegate>

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *themeArray;
@property (nonatomic,strong)SMPublishMatchHeader *header;
@property (nonatomic,strong)UIView *selectThemesView;
@property (nonatomic,strong)UILabel *hasAddThemesLabel;
//存储已有合辑
@property (nonatomic,strong)NSMutableArray *dataArray;
//存储选中的合辑
@property (nonatomic,strong)NSMutableArray *selectArray;
@property (nonatomic,assign)int pageNumber;
@property (nonatomic,assign)int pageSize;
@end

@implementation SMPublishMatchController
{
    BOOL navBarHiddenState;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self forbiddenSideBack];
    
    switch (self.publishType) {
        case SMPublishTypeMatch:
            [MobClick beginLogPageView:@"创建搭配-发布搭配页面"];
            [TalkingData trackPageBegin:@"创建搭配-发布搭配页面"];
            break;
        case SMPublishTypeDraftMatch:
            [MobClick beginLogPageView:@"创建搭配-发布搭配页面"];
            [TalkingData trackPageBegin:@"创建搭配-发布搭配页面"];
            break;
        case SMPublishTypeTag:
            [MobClick beginLogPageView:@"上传搭配-发布搭配页面"];
            [TalkingData trackPageBegin:@"上传搭配-发布搭配页面"];
            break;
        default:
            break;
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    [self resetSideBack];
    
    switch (self.publishType) {
        case SMPublishTypeMatch:
            [MobClick endLogPageView:@"创建搭配-发布搭配页面"];
            [TalkingData trackPageEnd:@"创建搭配-发布搭配页面"];
            break;
        case SMPublishTypeDraftMatch:
            [MobClick endLogPageView:@"创建搭配-发布搭配页面"];
            [TalkingData trackPageEnd:@"创建搭配-发布搭配页面"];
            break;
        case SMPublishTypeTag:
            [MobClick endLogPageView:@"上传搭配-发布搭配页面"];
            [TalkingData trackPageEnd:@"上传搭配-发布搭配页面"];
            break;
        default:
            break;
    }
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self addBackButton];
    _dataArray = [NSMutableArray array];
    _selectArray = [NSMutableArray array];
    _pageSize = 20;
    // Do any additional setup after loading the view.
    [self initUI];
    
    __weak __typeof(&*self)weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
    }];
    [self.tableView.mj_header beginRefreshing];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf getNextData];
    }];
    [self.tableView.mj_footer setAutomaticallyHidden:YES];
}

- (void)initUI {
    self.title = @"发布搭配";
    _header = [[SMPublishMatchHeader alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, 127.5+60)];
    _header.imageView.image = self.image;
    [self.view addSubview:_header];
    [_header.searchTF addTarget:self action:@selector(searchTFClick) forControlEvents:UIControlEventTouchDown];
    
    _hasAddThemesLabel = [[UILabel alloc] init];
    _hasAddThemesLabel.backgroundColor = [UIColor whiteColor];
    _hasAddThemesLabel.text = @"已加入的合辑";
    _hasAddThemesLabel.textColor = [UIColor colorWithHexString:@"#424446"];
    _hasAddThemesLabel.font = [UIFont systemFontOfSize:12];
    _hasAddThemesLabel.clipsToBounds = YES;
    [self.view addSubview:_hasAddThemesLabel];
    [_hasAddThemesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_header.mas_bottom);
        make.left.equalTo(self.view).offset(10);
        make.width.mas_equalTo(180);
        make.height.mas_equalTo(0);
    }];
    
    _selectThemesView = [[UIView alloc] init];
    [self.view addSubview:_selectThemesView];
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithHexString:@"#efeff4"];
    [_selectThemesView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.left.equalTo(_selectThemesView);
        make.height.mas_equalTo(7.5);
    }];
    [_selectThemesView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(_hasAddThemesLabel.mas_bottom);
        make.height.mas_equalTo(7.5 + 18.5);
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor whiteColor];
    label.textColor = [UIColor colorWithHexString:@"#424446"];
    label.text = @"已有合辑";
    label.font = GetFont(12);
    [self.view addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view);
        make.top.equalTo(_selectThemesView.mas_bottom).offset(7.5);
        make.height.mas_equalTo(30);
    }];
    
    
    CGFloat height = kScreenWidth > 375 ? 48 : 40;
    _tableView = [[UITableView alloc] init];
    _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor whiteColor];
    view.frame = CGRectMake(0, 0, kScreenWidth, 3);
    _tableView.tableFooterView = view;
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-height);
    }];
    
    UIButton *publishBtn = [[UIButton alloc] init];
    publishBtn.backgroundColor = [UIColor colorWithHexString:@"#5d32b8"];
    [publishBtn setTitle:@"发布" forState:UIControlStateNormal];
    [publishBtn addTarget:self action:@selector(publishClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:publishBtn];
    [publishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_tableView);
        make.top.equalTo(_tableView.mas_bottom);
        make.height.mas_equalTo(height);
    }];
}

//添加标签
- (void)addWLabelDataWithDict:(NSDictionary *)dict {
    if (dict) {
        SMThemeModel *themeModel = [[SMThemeModel alloc] init];
        themeModel.is_publish = 1;
        themeModel.title = dict[@"name"];
        themeModel.ID = [NSString stringWithFormat:@"%@",dict[@"id"]] ;
        [_selectArray addObject:themeModel];
        [self displayLabelView];
        
        [self.tableView.mj_header beginRefreshing];
    }
}

#pragma mark - event

- (void)back:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否放弃当前操作？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:sure];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];

}
- (void)searchTFClick {
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    SearchForCreateMatchViewController *searchVC = [story instantiateViewControllerWithIdentifier:@"SearchForCreateMatchViewController"];
    searchVC.createLabelDelegate = self;
    searchVC.isFromCreateCollection = YES;
    [self.navigationController pushViewController:searchVC animated:YES];
}
- (void)publishClick:(UIButton *)publishBtn {
    
    if (!_header.matchNameTF.text.length) {
        [HTUIHelper addHUDToWindowWithString:@"请输入搭配标题" hideDelay:1];
        return;
    }
    if (!_header.matchDiscriptTF.text.length) {
        [HTUIHelper addHUDToWindowWithString:@"请输入搭配描述" hideDelay:1];
        return;
    }
    if (!_selectArray.count) {
        [HTUIHelper addHUDToWindowWithString:@"至少选择一个合辑" hideDelay:1];
        return;
    }
    [self publishNet];
}
/**
 "data":[
 {
 "favored":false,
 "image":"http://www.ssrj.cn/static/image/mfd_theme.png",
 "favor_count":0,
 "is_open":1,
 "owner":1,
 "id":1308,
 "is_publish":0,
 "title":"1231",
 "comment_count":0,
 "praise_count":0,
 "memo":"12312"
 },......
 */
#pragma mark - data
//获取已有合辑
//http://192.168.1.173:9999/api/v1/collocationupload/mytheme?appVersion=2.2.0&pagenum=1&pagesize=20&token=daf1a91acee1be236510cc2bd1873b49
- (void)getNetData {
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    _pageNumber = 1;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@(_pageNumber) forKey:@"pagenum"];
    [dict setObject:@(_pageSize) forKey:@"pagesize"];
    requestInfo.URLString = MyThemeUrl;
    requestInfo.getParams = dict;
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[responseObject objectForKey:@"state"] intValue] == 0) {
            
            _pageNumber++;
            [_dataArray removeAllObjects];
            for (NSDictionary *dict in responseObject[@"data"]) {
                NSError *error;
                SMThemeModel * model = [[SMThemeModel alloc] initWithDictionary:dict error:&error];
                if (!error) {
                    [weakSelf.dataArray addObject:model];
                }
            }
            [_tableView reloadData];
            [_tableView.mj_header endRefreshing];
            if (weakSelf.dataArray.count < _pageSize) {
                [weakSelf.tableView.mj_footer setHidden:YES];
            }else {
                [weakSelf.tableView.mj_footer resetNoMoreData];
            }
        }else{
            [HTUIHelper addHUDToView:weakSelf.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
            [_tableView.mj_header endRefreshing];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:weakSelf.view withString:@"Error" hideDelay:2];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
}
//获取已有合辑
- (void)getNextData {
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@(_pageNumber) forKey:@"pagenum"];
    [dict setObject:@(_pageSize) forKey:@"pagesize"];
    requestInfo.URLString = MyThemeUrl;
    requestInfo.getParams = dict;
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[responseObject objectForKey:@"state"] intValue] == 0) {
            _pageNumber++;
            if ([responseObject[@"data"] count] < _pageSize) {
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }else {
                [weakSelf.tableView.mj_footer endRefreshing];
            }
            for (NSDictionary *dict in responseObject[@"data"]) {
                NSError *error;
                SMThemeModel * model = [[SMThemeModel alloc] initWithDictionary:dict error:&error];
                if (!error) {
                    [self.dataArray addObject:model];
                }
            }
            [_tableView reloadData];
        }else{
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
            [_tableView.mj_header endRefreshing];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
}
//发布
//http://192.168.1.173:9999/api/v1/collocationupload/publishupload
/**post 参数
    //上传搭配
    appVersion	2.2.0
    brief	故意
    draft	{"data":[{"pointX":154.396875,"pointY":177,"position":0,"tagText":"Tahari by ASL黑色连衣裙"}]}
    format	jpg
    goods	336
    image	/9j/4AAQSkZJRgABAQAASABIAAD/4QBYRXhpZg......
    theme	1306
    title	你来了
    token	daf1a91acee1be236510cc2bd1873b49
 
    //发布在线创作 如果是草稿id传草稿id，不是传空；
     appVersion	2.2.0
     brief	体会
     draft	{"data":[{"id":"2388","scale":1,"isFlipY":0,"angle":0,"type":"image","transform":"[1, 0, 0, 1, 0, 0]","isFlipX":false,"image":"http:\/\/www.ssrj.com\/upload\/image\/201611\/96343d97-799b-4a07-b85f-1cdd957469ec-medium.png","scaleY":1,"center":"{187.5, 187.5}","scaleX":1,"bounds":"{{0, 0}, {150, 150}}","screenWidth":375}]}
     goods	2388,2133
     image	/9j/4AAQSkZJRgABAQAASABIAAD/......
     status	4
     theme	1306,1308
     title	两个人
     id 7075
     token	daf1a91acee1be236510cc2bd1873b49
 */
- (void)publishNet{
    
    /** 上传搭配--背景图 or 创建搭配--截图 */
    UIImage *newimage = [self scaleImageWithImage:self.image size:CGSizeMake(600, 600)];
    NSData *imagedata = UIImageJPEGRepresentation(newimage, 0.5);
    NSString *base64Str = [imagedata base64EncodedStringWithOptions:0];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (base64Str.length) {
        [dict setObject:base64Str forKey:@"image"];
    }
    [dict setObject:_header.matchNameTF.text forKey:@"title"];
    if (_header.matchDiscriptTF.text.length) {
        [dict setObject:_header.matchDiscriptTF.text forKey:@"brief"];
    }
    [dict setObject:self.jsonString forKey:@"draft"];
    NSMutableArray *themeArr = [NSMutableArray array];
    for (SMThemeModel *model in _selectArray) {
        [themeArr addObject:model.ID];
    }
    if (themeArr.count) {
        NSString *theme = [themeArr componentsJoinedByString:@","];
        [dict setObject:theme forKey:@"theme"];
    }
    //发布在线创作 state = 4；
    if (_publishType == SMPublishTypeMatch || _publishType == SMPublishTypeDraftMatch) {
        [dict setObject:@"4" forKey:@"status"];
    }
    if (_goodsIdArr.count) {
        NSString *goods = [_goodsIdArr componentsJoinedByString:@","];
        [dict setObject:goods forKey:@"goods"];
    }
    if (_matchDraftId.length && _publishType == SMPublishTypeDraftMatch) {
        [dict setObject:_matchDraftId forKey:@"id"];
    }
    if (_publishType == SMPublishTypeTag) {
        [dict setObject:@"jpg" forKey:@"format"];
    }
    ZHRequestInfo *requestInfo = [[ZHRequestInfo alloc] init];
    
    //上传搭配
    if (self.publishType == SMPublishTypeTag) {
        requestInfo.URLString = PublishTagUrl;
    }
    //创建搭配
    else {
        requestInfo.URLString = PublishMatchUrl;
    }
    __weak __typeof(&*self)weakSelf = self;
    [requestInfo.postParams setDictionary:dict];
    
    [[HTUIHelper shareInstance] addHUDToView:self.view withString:nil xOffset:0 yOffset:0];
    [[ZHNetworkManager sharedInstance]postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSNumber *number = responseObject[@"state"];
        if (number.boolValue == 0) {
            
            SMPublishFinishedController *finished = [[SMPublishFinishedController alloc] init];
            if (weakSelf.publishType == SMPublishTypeTag) {
                [HTUIHelper addHUDToWindowWithString:@"上传搭配成功" hideDelay:1];
                finished.publishType = HHPublishTyleTag;
            }else if (weakSelf.publishType == SMPublishTypeMatch){
                finished.publishType = HHPublishTyleMatch;
                [HTUIHelper addHUDToWindowWithString:@"创建搭配成功" hideDelay:1];
            }else {
                finished.publishType = HHPublishTyleMatch;
                [HTUIHelper addHUDToWindowWithString:@"创建搭配成功" hideDelay:1];
            }
            finished.matchId = responseObject[@"data"][@"collocation"];
            [weakSelf.navigationController pushViewController:finished animated:YES];
        }else{
            [HTUIHelper addHUDToWindowWithString:responseObject[@"msg"] hideDelay:1];
        }
        [[HTUIHelper shareInstance] removeHUD];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToWindowWithString:@"error" hideDelay:1];
        [[HTUIHelper shareInstance] removeHUD];
    }];
}
- (UIImage *)scaleImageWithImage:(UIImage *)sourceImage size:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [sourceImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
#pragma mark - Search delegate
#pragma mark -- 刷新标签数据
- (void)reloadLabelDataWithModel:(ThemeLabelForSearchModel *)model {
    BOOL hasSelected = NO ;
    for (SMThemeModel *selectModel in _selectArray) {
        if ([selectModel.ID isEqualToString:[model.id stringValue]]) {
            [HTUIHelper addHUDToWindowWithString:@"请不要重复添加" hideDelay:1];
            hasSelected = YES;
        }
    }
    if (!hasSelected) {
        
        SMThemeModel *themeModel = [[SMThemeModel alloc] init];
        themeModel.is_publish = 1;
        themeModel.title = model.name;
        themeModel.ID = [model.id stringValue] ;
        [_selectArray addObject:themeModel];
        [self displayLabelView];
    }
}

#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SMThemeModel *model = self.dataArray[indexPath.row];
    SMThemeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SMThemeCell"];
    if (!cell) {
        cell = [[SMThemeCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    cell.model = model;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SMThemeModel *model = _dataArray[indexPath.row];
    BOOL existCollection = NO;
    for (SMThemeModel *themeModel in _selectArray) {
        if ([themeModel.ID isEqualToString:model.ID]) {
            existCollection = YES;
        }
    }
    if (existCollection) {
        [HTUIHelper addHUDToWindowWithString:@"请不要重复添加" hideDelay:0.5];
    }else {
        [_selectArray addObject:model];
        [self displayLabelView];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45 + 12;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_header endEditing:YES];
}

#pragma mark - other
- (void)displayLabelView {
    for (UIView *subView in _selectThemesView.subviews) {
        [subView removeFromSuperview];
    }
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor colorWithHexString:@"#efeff4"];
    [_selectThemesView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.left.equalTo(_selectThemesView);
        make.height.mas_equalTo(7.5);
    }];
    if (_selectArray.count == 0) {
        [_hasAddThemesLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [_selectThemesView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(7.5 + 18.5);
        }];
        return;
    }
    CGFloat padding = 8;
    CGFloat buttonH = 25;
    CGFloat leftAndRightPadding = 10;
    CGFloat topAndBottomPadding = 0;
    CGFloat currentButtonX = leftAndRightPadding;
    CGFloat currentButtonY = topAndBottomPadding;
    
    
    CGRect frame = _selectThemesView.frame;
    frame.size.height = 0;
    _selectThemesView.frame = frame;
    for (int i = 0; i < _selectArray.count; i++) {
        
        SMThemeModel *model = _selectArray[i];
        
        CGFloat butttonW = [self widthWithText:model.title maxSize:CGSizeMake(kScreenWidth, buttonH) fontSize:14] + 40;
        CGFloat buttonX = currentButtonX;
        CGFloat buttonY = currentButtonY;
        
        if (buttonX + butttonW + leftAndRightPadding > kScreenWidth) {
            buttonX = leftAndRightPadding;
            buttonY = currentButtonY + (padding + buttonH);
            currentButtonY = buttonY;
            currentButtonX = buttonX;
        }
        
        UIButton *wordButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, butttonW, buttonH)];
        wordButton.backgroundColor = [UIColor colorWithHexString:@"#f3f3f3"];
        wordButton.layer.cornerRadius = 12.0;
        wordButton.clipsToBounds = YES;
        wordButton.tag = i + 20;
        [wordButton setTitle:model.title forState:UIControlStateNormal];
        [wordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        wordButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [wordButton setImage:GetImage(@"tag_delete") forState:UIControlStateNormal];
        [wordButton addTarget:self action:@selector(tagBtnClick:) forControlEvents:UIControlEventTouchDown];
        [_selectThemesView addSubview:wordButton];
        
        [wordButton layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleRight imageTitleSpace:4];
        
        buttonX = buttonX + (padding + butttonW);
        currentButtonX = buttonX;
    }
    CGFloat height = currentButtonY + (buttonH + topAndBottomPadding) + 7.5 + 18.5;
    
    [_selectThemesView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    [_hasAddThemesLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(35);
    }];
    
}

#pragma mark - 根据文字长度计算button宽度
- (CGFloat)widthWithText:(NSString *)text maxSize:(CGSize)size fontSize:(CGFloat)fontSize{
    CGRect rect = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:fontSize]} context:nil];
    return rect.size.width;
}
#pragma mark -- 标签img点击删除事件
- (void)tagBtnClick:(UIButton *)button {
    
    [_selectArray removeObjectAtIndex:button.tag - 20];
    [self displayLabelView];
}
#pragma mark - 取消侧滑
-(void)forbiddenSideBack{
    
    //关闭ios右滑返回
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
        
    }
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer {
    
    if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        return NO;
    }
    return YES;
    
}
//viewDidDisappear
- (void)resetSideBack {
    
    //开启ios右滑返回
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
