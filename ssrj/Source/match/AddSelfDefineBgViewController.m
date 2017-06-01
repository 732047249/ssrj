//
//  AddSelfDefineBgViewController.m
//  ssrj
//
//  Created by YiDarren on 16/10/27.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "AddSelfDefineBgViewController.h"
#import "UIButton+AFNetworking.h"
#import "YLButton.h"
static NSString * const GetAllCustomBgUrl = @"/b180/api/v1/collocation/background";
@interface AddSelfDefineBgViewController ()<UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

// 场合、颜色相关
@property (weak, nonatomic) IBOutlet UIScrollView *occasionScrollView;

@property (weak, nonatomic) IBOutlet UIScrollView *colorScrollView;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
//场景数据
@property (strong, nonatomic) NSMutableArray *scenArray;
//颜色数据
@property (strong, nonatomic) NSMutableArray *colorArray;
//选择的场景数组：[@"id"]
@property (strong, nonatomic) NSMutableArray *selectScenArray;
//选择的颜色数组：[@"id"]
@property (strong, nonatomic) NSMutableArray *selectColorArray;
//collectionView的背景图数组
@property (strong, nonatomic) NSMutableArray *backgroundArray;

// collectionView相关
@property (assign, nonatomic) int pageNumber;
//选择的颜色：@"id"
@property (strong,nonatomic)NSString *selectColorId;
//选择的场景：@"id"
@property (strong,nonatomic)NSString *selectSceneId;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *occasionScrollViewHeightConstraint;


@end

@implementation AddSelfDefineBgViewController
{
    int pageSize;//每页几条数据
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [MobClick beginLogPageView:@"创建搭配-自定义背景页面"];
    [TalkingData trackPageBegin:@"创建搭配-自定义背景页面"];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [MobClick endLogPageView:@"创建搭配-自定义背景页面"];
    [TalkingData trackPageEnd:@"创建搭配-自定义背景页面"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#efeff4"];
    _backgroundArray = [NSMutableArray array];
    _colorArray = [NSMutableArray array];
    _scenArray = [NSMutableArray array];
    _selectScenArray = [NSMutableArray array];
    _selectColorArray = [NSMutableArray array];
    [self addBackButton];
    pageSize = 15;
    self.title = @"自定义背景";
    self.occasionScrollView.scrollsToTop = NO;
    self.colorScrollView.scrollsToTop = NO;
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [self getNetData];
    }];
    
    [self.collectionView.mj_header beginRefreshing];
    
    self.occasionScrollViewHeightConstraint.constant = (86 - 15)*(SCREEN_WIDTH/320) +15;
    
    
}
#pragma mark -- 获取颜色 场合 背景
/**
 "data":[
 {
    "color":[
         {
         "color_value":"rgb(255, 255, 255)",
         "picture":"http://www.ssrj.com/upload/image/201508/34576993-22cc-43c7-a1cb-7cdc9d2d8c8e.png",
         "id":"12",
         "title":"白色"
         },......
     "scene":[
         {
         "image":"http://192.168.1.173:9999/static/upload/image/background/1.png",
         "title":"雾霾",
         "id":"1",
         "choice":"http://192.168.1.173:9999/static/upload/image/background/1-1.png"
         },......
     "background":[
         {
         "title":"斑马纹连衣裤",
         "color":12,
         "image":"http://192.168.1.173:9999/static/upload/image/background/f66cc2c4-35dc-4b4e-ad18-109a70f398a4.jpg",
         "scene":1,
         "thumbnail":"",
         "draft":[
             {
             "height":75,
             "src":"http://www.ssrj.cn/static/upload/image/201511/b60991d4-e9d1-44f8-8b23-27e9724f93d8.jpg",
             "angle":0,
             "flipX":false,
             "flipY":false,
             "top":451.11,
             "scaleX":1,
             "scaleY":1,
             "width":400,
             "type":"image",
             "left":463.43
             },......
        .....
 */
//http://ugcapp.ssrj.com/api/v1/collocation/background?pagenum=1&pagesize=15&appVersion=2.2.0&token=daf1a91acee1be236510cc2bd1873b49
- (void)getNetData{
    
    _pageNumber = 1;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = GetAllCustomBgUrl;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@(_pageNumber) forKey:@"pagenum"];
    [dict setValue:@(pageSize) forKey:@"pagesize"];
    requestInfo.getParams = dict;
    if (self.selectColorId.length) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"color" : self.selectColorId}];
    }
    if (self.selectSceneId.length) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"scene" : self.selectSceneId}];
    }
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSNumber *number = [responseObject objectForKey:@"state"];
        if (number.boolValue == 0) {
            //1、color
            NSArray *colorDataArr = [[responseObject[@"data"] lastObject]  objectForKey:@"color"];
            if (colorDataArr.count) {
                [weakSelf.colorArray removeAllObjects];
                for (NSDictionary * dic in colorDataArr) {
                    ColorModel *model = [[ColorModel alloc] initWithDictionary:dic error:nil];
                    if (model) {
                        [weakSelf.colorArray addObject:model];
                    }
                }
            }
            
            //2、scene<---->occasion
            NSArray *occasionDataArray = [[responseObject[@"data"] lastObject]  objectForKey:@"scene"];
            if (occasionDataArray.count) {
                [weakSelf.scenArray removeAllObjects];
                for (NSDictionary * dic in occasionDataArray) {
                    
                    SceneModel *model = [[SceneModel alloc] initWithDictionary:dic error:nil];
                    
                    if (model) {
                        [weakSelf.scenArray addObject:model];
                    }
                }
            }
            
            //3、background
            NSArray *backgroundDataArr = [[responseObject[@"data"] lastObject]  objectForKey:@"background"];
            
            _pageNumber +=1;
            [weakSelf.backgroundArray removeAllObjects];
            for (NSDictionary * dic in backgroundDataArr) {
                BackgroundModel *model = [[BackgroundModel alloc] initWithDictionary:dic error:nil];
                
                if (model) {
                    
                    [weakSelf.backgroundArray addObject:model];
                }
            }
            [weakSelf updateHeaderData];
            
            weakSelf.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                [weakSelf getNextNetData];
            }];
        }else{
            
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            [weakSelf.collectionView.mj_header endRefreshing];
            
        }
        [weakSelf.collectionView reloadData];
        [weakSelf.collectionView.mj_header endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
        [weakSelf.collectionView.mj_header endRefreshing];

    }];
}


#pragma mark -- 获取下一页全部网络数据
- (void)getNextNetData{
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = GetAllCustomBgUrl;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@(_pageNumber) forKey:@"pagenum"];
    [dict setValue:@(pageSize) forKey:@"pagesize"];
    requestInfo.getParams = dict;
    if (self.selectColorId.length) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"color" : self.selectColorId}];
    }
    if (self.selectSceneId.length) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"scene" : self.selectSceneId}];
    }
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSNumber *number = [responseObject objectForKey:@"state"];
        if (number.boolValue == 0) {
            
            _pageNumber +=1;
            //3、background
            NSArray *backgroundDataArr = [[responseObject[@"data"] lastObject]  objectForKey:@"background"];
            for (NSDictionary * dic in backgroundDataArr) {
                BackgroundModel *model = [[BackgroundModel alloc] initWithDictionary:dic error:nil];
                if (model) {
                    [weakSelf.backgroundArray addObject:model];
                }
            }
            [weakSelf.collectionView reloadData];
            if (backgroundDataArr.count < pageSize) {
                [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
            }else {
                [weakSelf.collectionView.mj_footer endRefreshing];
            }
        }else{
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            [weakSelf.collectionView.mj_footer endRefreshing];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
        [weakSelf.collectionView.mj_footer endRefreshing];
    }];
}


- (void)updateHeaderData{
    for (UIView * view in self.occasionScrollView.subviews) {
        [view removeFromSuperview];
    }
    CGFloat originX = 20;
    CGFloat sizeWith = 0;
    
#pragma mark -- sceneScrollView 部分
    [self.selectScenArray removeAllObjects];
    for (int i = 0; i<self.scenArray.count; i++) {
        SceneModel *model = self.scenArray[i];
        UIButton *button = [UIButton buttonWithType:0];
        
//        button.height = self.occasionScrollView.height - 15 ;
//        button.width = button.height / 272.0 * 252;
        button.width = 65 *  (SCREEN_WIDTH/320);
        button.height = self.occasionScrollView.height - 15;
    
        button.layer.borderColor = APP_BASIC_COLOR2.CGColor;
        button.layer.borderWidth = 0;
        button.layer.cornerRadius = 3;
        button.clipsToBounds = YES;
        
        [button setBackgroundImageForState:0 withURL:[NSURL URLWithString:model.image] placeholderImage:GetImage(@"default_1x1")];
        [button setBackgroundImageForState:UIControlStateSelected withURL:[NSURL URLWithString:model.choice] placeholderImage:GetImage(@"default_1x1")];
        
        [button setOrigin:CGPointMake(originX, 8)];
        originX += button.width + 6;
        
        button.tag = model.sceneId.intValue;
        [self.occasionScrollView addSubview:button];
        if (i == self.scenArray.count -1) {
            sizeWith = originX + 6;
        }
        if ([model.sceneId isEqualToString:self.selectSceneId]) {
            button.selected = YES;
            [self.selectScenArray addObject:[NSNumber numberWithInteger:button.tag]];
        }
        [button addTarget:self action:@selector(occasionTagButtonAction:) forControlEvents:UIControlEventTouchUpInside];
                
    }
    [self.occasionScrollView setContentSize:CGSizeMake(sizeWith, self.occasionScrollView.height)];
    
#pragma mark -- colorScrollView 部分
    [self.selectColorArray removeAllObjects];
    for (UIView * view in self.colorScrollView.subviews) {
        [view removeFromSuperview];
    }
    originX = 20;
    sizeWith = 0;
    for (int i = 0; i<self.colorArray.count; i++) {
        ColorModel *model = self.colorArray[i];
        YLButton *button = [YLButton buttonWithType:UIButtonTypeCustom];
        CGFloat width = [model.title boundingRectWithSize:CGSizeMake(100, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size.width + 25 + 10;
        
        [button setWidth:width];
        button.height = 25;
        button.imageRect = CGRectMake(10, 5.5, 14, 14);
        button.titleRect = CGRectMake(25, 2.5, width - 25 - 10, 20);
        [button setTitle:model.title forState:0];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setTitleColor:[UIColor darkGrayColor] forState:0];
        [button setTitleColor:APP_BASIC_COLOR2 forState:UIControlStateSelected];
            
        button.layer.borderColor = [UIColor colorWithHexString:@"#e5e5e5"].CGColor;
        button.layer.borderWidth = 1;
        
        [button setImageForState:UIControlStateNormal withURL:[NSURL URLWithString:model.picture] placeholderImage:GetImage(@"640X200")];
        
        [button setOrigin:CGPointMake(originX, 8)];
        originX += button.width + 10;
    
        button.tag = model.colorId.intValue;
        if ([model.colorId isEqualToString:self.selectColorId]) {
            button.selected = YES;
            button.layer.borderWidth = 1;
            button.layer.borderColor = [APP_BASIC_COLOR2 CGColor];
            [self.selectColorArray addObject:[NSNumber numberWithInteger:button.tag]];
        }
        button.layer.cornerRadius = 3;
        button.clipsToBounds = YES;
        [self.colorScrollView addSubview:button];
        if (i == self.colorArray.count -1) {
            sizeWith = originX + 20;
        }
            
        [button addTarget:self action:@selector(colorTagButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            
    }
    [self.colorScrollView setContentSize:CGSizeMake(sizeWith, self.colorScrollView.height)];
    
#pragma mark -- backgroundScrollView 部分

    [self.collectionView reloadData];
    
    
}

- (void)occasionTagButtonAction:(UIButton *)button{
    //重复点击，取消选中
    if ([self.selectScenArray containsObject:[NSNumber numberWithInteger:button.tag]] && button.selected) {
//        NSLog(@"%@",self.selectScenArray);
        [self.selectScenArray removeAllObjects];
        button.selected = NO;
        button.layer.borderWidth = 0;
        self.selectSceneId = nil;
    }
    //点击其他按钮。添加id
    else{
        for (UIButton * button in self.occasionScrollView.subviews) {
            if ([button isKindOfClass:[UIButton class]]) {
                button.selected = NO;
                button.layer.borderWidth = 0;
            }
        }
        [self.selectScenArray removeAllObjects];
        button.selected = YES;
        
        self.selectSceneId = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:button.tag]];
        [self.selectScenArray addObject:[NSNumber numberWithInteger:button.tag]];
    }
    
    [self.collectionView.mj_header beginRefreshing];

}


- (void)colorTagButtonAction:(UIButton *)button{
    
    //重复点击，取消选中
    if ([self.selectColorArray containsObject:[NSNumber numberWithInteger:button.tag]] && button.selected) {
        [self.selectColorArray removeAllObjects];
        button.selected = NO;
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor colorWithHexString:@"#f4f4f4"].CGColor;
        self.selectColorId = nil;
    }
    //点击其他按钮。添加id
    else{
        for (UIButton * button in self.colorScrollView.subviews) {
            if ([button isKindOfClass:[UIButton class]]) {
                button.selected = NO;
                button.layer.borderWidth = 1;
                button.layer.borderColor = [UIColor colorWithHexString:@"#f4f4f4"].CGColor;
            }
        }
        [self.selectColorArray removeAllObjects];
        button.selected = YES;
        button.layer.borderWidth = 1;
        button.layer.borderColor = APP_BASIC_COLOR2.CGColor;
        
        self.selectColorId = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:button.tag]];
        [self.selectColorArray addObject:[NSNumber numberWithInteger:button.tag]];
    }
    
    [self.collectionView.mj_header beginRefreshing];
}


#pragma mark -- collectionView代理数据源方法
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _backgroundArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
 
    AddSelfDefineBgViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AddSelfDefineBgViewCell" forIndexPath:indexPath];
    
    if (cell == nil) {
     
        [HTUIHelper addHUDToView:self.view withString:@"AddSelfDefineBgViewCell is nil" hideDelay:2];
        
        return nil;
    }
    
    BackgroundModel *model = self.backgroundArray[indexPath.row];
    
    /**
     *  统计ID
     */
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.backgroundId.intValue];

    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:GetImage(@"default_1x1")];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake((SCREEN_WIDTH)/3.0 , (SCREEN_WIDTH)/3.0);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [HTUIHelper addHUDToView:self.view withString:@"选中了该图片" hideDelay:1];
    
    BackgroundModel *model = self.backgroundArray[indexPath.row];
    if (self.selectedBgBlock) {
        self.selectedBgBlock(model);
    }
    [self.navigationController popViewControllerAnimated:YES];
    
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}



@end






@implementation AddSelfDefineBgViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imageView.image = nil;
    self.layer.borderColor = [UIColor colorWithHexString:@"#f1f1f1"].CGColor;
    self.layer.borderWidth = 0.5;
}

@end


