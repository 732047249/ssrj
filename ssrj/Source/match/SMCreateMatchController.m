//
//  SMCreateMatchController.m
//  CreateMatchView
//
//  Created by MFD on 16/11/9.
//  Copyright © 2016年 MFD. All rights reserved.
//

#import "SMCreateMatchController.h"
#import "SMAddMatchController.h"
#import "SMMatchDraftController.h"
#import "SMPublishMatchController.h"
#import "AddSelfDefineBgViewController.h"
#import "UIImageView+WebCache.h"
#import "UIImage+New.h"
#import "Masonry.h"

#define KToolBarHeight 40
#define KNavBarHeight 64
#define KWindow [UIApplication sharedApplication].keyWindow
#define KBlurColor [UIColor colorWithRed:1 green:2 blue:2 alpha:0.5]
static NSString * const SaveDraftUrl = @"/b180/api/v1/collocation/publish";
@interface SMCreateMatchController ()<SMMatchViewDelegate>
/** 将所有视图添加到容器中，方便整体上下滚动 */
@property (nonatomic,strong)UIView *containerView;
/** 自定义的导航条，方便上下滚动 */
@property (nonatomic,strong)UIView *navBar;
/** 自定义工具条：添加背景图，发布 */
@property (nonatomic,strong)UIView *topToolBar;
/** 面板 */
@property (nonatomic,strong)SMMatchView *matchView;
/** 底部的导航控制器 */
@property (nonatomic,strong)UINavigationController *navC;
/** 底部的导航控制器的跟控制器 */
@property (nonatomic,strong)SMAddMatchController *addMatchController;
//覆盖下面导航控制器，用于接受点击和滑动事件
@property (nonatomic,strong)UIView *bottomView;
//底部的蒙板,接受点击事件，可以将蒙版删除
@property (nonatomic,strong)UIView *coverView;
//草稿唯一标识，用于记录是修改草稿，还是保存草稿（选择草稿时要复制，新建搭配时滞空）
@property (nonatomic,strong)NSString *draftId;
//容器，方便动画
@property (nonatomic,assign)CGFloat containerViewHeight;
@end

@implementation SMCreateMatchController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [MobClick beginLogPageView:@"创建搭配页面"];
    [TalkingData trackPageBegin:@"创建搭配页面"];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"创建搭配页面"];
    [TalkingData trackPageEnd:@"创建搭配页面"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Do any additional setup after loading the view.
    [self setupContainerView];
    [self setupMatch];
    [self setupToolBar];
    [self setupNavBar];
    [self configNav];
    [self configBottomView];
    [self configCoverView];
    
//    [_matchView addBgImagesWithSelfDefineBgDraftModelArray:nil];
}
//添加单品或素材
- (void)addGoodsOrSourceWithModel:(SMGoodsModel *)model {
    
    [self scrollToTop:NO];
    int goodsNumber = 0;
    for (SMMatchImageView *matchImage in self.matchView.matchImageArray) {
        if (matchImage.goodsModel.ID.length) {
            goodsNumber++;
        }
    }
    if (goodsNumber >= 6) {
        [HTUIHelper addHUDToView:self.view withString:@"最多添加6个单品" hideDelay:1];
        return;
    }
    
    [_matchView addImageWithImageModel:model];
}
//设置view即时滚动到顶部或还原到起始状态
- (void)scrollToTop:(BOOL)yesOrNo {
    //滚动到顶部
    if (yesOrNo == YES) {
        //导航控制器滚动，发通知，通知其他页面（addMatch, searchDetail,categary）的导航条高度要跟着改变
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ControllerScrollNotification" object:@"top"];
        
        [UIView animateWithDuration:0.3 animations:^{
            _containerView.frame =  CGRectMake(0, -(_matchView.bounds.size.height +KNavBarHeight+KToolBarHeight), kScreenWidth, _containerViewHeight);
        } completion:^(BOOL finished) {
            _coverView.hidden = YES;
            _bottomView.hidden = YES;
        }];
    }
    //滚动到底部
    else {
        //导航控制器滚动，发通知，通知其他页面（addMatch, searchDetail,categary）的导航条高度要跟着改变
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ControllerScrollNotification" object:@"bottom"];
        
        [UIView animateWithDuration:0.3 animations:^{
            _containerView.frame = CGRectMake(0, 0, kScreenWidth, _containerViewHeight);
        } completion:^(BOOL finished) {
            self.bottomView.hidden = NO;
            if (self.matchView.selectImageView) {
                self.coverView.hidden = NO;
            }else {
                self.coverView.hidden = YES;
            }
        }];
    }
}
#pragma mark - UI
- (void)setupContainerView {
    
    //高度=底部导航控制器的高度+面板的高度+导航条高度+工具条高度
    _containerViewHeight = kScreenHeight + (kScreenWidth+50) + KNavBarHeight + KToolBarHeight;
    _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, _containerViewHeight)];
    [self.view addSubview:_containerView];
}
- (void)setupMatch {
    _matchView = [[SMMatchView alloc]initWithFrame:CGRectMake(0, KToolBarHeight+KNavBarHeight, kScreenWidth, kScreenWidth + 50)];
    _matchView.delegate = self;
    [_containerView addSubview:_matchView];
}
- (void)setupToolBar {
    _topToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, KNavBarHeight, kScreenWidth, KToolBarHeight)];
    _topToolBar.backgroundColor = [UIColor whiteColor];
    UIButton *addBg = [[UIButton alloc] init];
    [addBg setTitle:@" 自定义背景" forState:UIControlStateNormal];
    addBg.titleLabel.font = [UIFont systemFontOfSize:14];
    [addBg setImage:[UIImage imageNamed:@"match_zidingyibeijing"] forState:UIControlStateNormal];
    [addBg setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [addBg addTarget:self action:@selector(addBgBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_topToolBar addSubview:addBg];
    [addBg sizeToFit];
    
    CGFloat width = addBg.bounds.size.width;
    [addBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(_topToolBar);
        make.left.equalTo(_topToolBar).offset(15);
        make.width.mas_equalTo(width);
    }];
    
    
    UIButton *publish = [[UIButton alloc] init];
    [publish setTitle:@"  发布" forState:UIControlStateNormal];
    [publish setTitleColor:[UIColor colorWithHexString:@"#5d32b5"] forState:UIControlStateNormal];
    publish.titleLabel.font = [UIFont systemFontOfSize:14];
    [publish addTarget:self action:@selector(publishBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_topToolBar addSubview:publish];
    [publish sizeToFit];
    width = publish.bounds.size.width;
    [publish mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(_topToolBar);
        make.right.equalTo(_topToolBar).offset(-15);
        make.width.mas_equalTo(width);
    }];
    
    
    UIView *bottomLien = [[UIView alloc]initWithFrame:CGRectMake(0, KToolBarHeight-1, kScreenWidth, 1)];
//    bottomLien.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    bottomLien.backgroundColor = [UIColor colorWithHexString:@"#e5e5e5"];
    [_topToolBar addSubview:bottomLien];
    
    [_containerView addSubview:_topToolBar];
    
    addBg.trackingId = [NSString stringWithFormat:@"SMCreateMatchController&topToolBar&addBg"];
    publish.trackingId = [NSString stringWithFormat:@"SMCreateMatchController&topToolBar&publish"];
    
}
- (void)setupNavBar {
    self.navBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, KNavBarHeight)];
    self.navBar.backgroundColor = APP_BASIC_COLOR;
    
    UIButton *back = [[UIButton alloc] initWithFrame:CGRectMake(5,20,40,44)];
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [back setImage:[UIImage imageNamed:@"back_icon"] forState:UIControlStateNormal];
//    [back setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 15)];
    [self.navBar addSubview:back];
    [_containerView addSubview:self.navBar];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 100)*0.5, 20, 100, 44)];
    label.text = @"在线创作";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    [self.navBar addSubview:label];
    
    UIButton *menuBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 45, 20, 40, 44)];
    [menuBtn setImage:[UIImage imageNamed:@"match_menu"] forState:UIControlStateNormal];
    menuBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [menuBtn addTarget:self action:@selector(menuBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navBar addSubview:menuBtn];
    
    menuBtn.trackingId = [NSString stringWithFormat:@"SMCreateMatchController&navBar&menuBtn"];
}
//设置底部的导航控制器
- (void)configNav {
    __weak __typeof(&*self)weakSelf = self;
    _addMatchController = [[SMAddMatchController alloc] init];
    _addMatchController.switchBlock = ^ {
        [weakSelf scrollToTop:NO];
    };
    _navC = [[UINavigationController alloc] initWithRootViewController:_addMatchController];
    _navC.view.frame = CGRectMake(0, CGRectGetMaxY(_matchView.frame), self.view.frame.size.width, KWindow.frame.size.height);
    [_containerView addSubview:_navC.view];
    [self addChildViewController:_navC];
}
- (void)configBottomView {
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(_navC.view.frame), kScreenWidth, kScreenHeight - CGRectGetMinY(_navC.view.frame))];
    _bottomView.backgroundColor = [UIColor whiteColor];
    _bottomView.alpha = 0.02;
    UITapGestureRecognizer *bottomViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bottomViewTap:)];
    [_bottomView addGestureRecognizer:bottomViewTap];
    UIPanGestureRecognizer *bottomViewPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(bottomViewPan:)];
    [_bottomView addGestureRecognizer:bottomViewPan];
    [_containerView addSubview:_bottomView];
}
- (void)configCoverView {
    _coverView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(_navC.view.frame), self.view.bounds.size.width, self.view.bounds.size.height - CGRectGetMinY(_navC.view.frame))];
    _coverView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverViewTap:)];
    [_coverView addGestureRecognizer:tap];
    _coverView.hidden = YES;
    [_containerView addSubview:_coverView];
}


#pragma mark - event
#pragma mark -- 底部导航滚动
//点击不导航条按钮。底部导航还原到起始位置
- (void)switchBtnClick:(UIButton *)button {
    [self scrollToTop:NO];
}
- (void)back {
    [self cancelEditState];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否放弃当前操作？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:sure];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark -- 自定义背景
- (void)addBgBtnClick {
    
    [self cancelEditState];
    __weak __typeof(&*self)weakSelf = self;
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    AddSelfDefineBgViewController *addBgVC = [story instantiateViewControllerWithIdentifier:@"AddSelfDefineBgViewController"];
    addBgVC.selectedBgBlock = ^(BackgroundModel *model){
        weakSelf.matchView.imageContainerView.image = nil;
        NSMutableArray *arr = [NSMutableArray array];
        for (NSDictionary *dict in model.draft) {
            SMBackgroundDraftModel *model = [[SMBackgroundDraftModel alloc] init];
            [model setValuesForKeysWithDictionary:dict];
            [arr addObject:model];
        }
        [weakSelf.matchView addBgImagesWithSelfDefineBgDraftModelArray:arr];
    };
    [self.navigationController pushViewController:addBgVC animated:YES];
}
#pragma mark -- 点击发布
- (void)publishBtnClick {
    
    [self cancelEditState];
    //判断用户是否登录
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
        return;
    }
    //至少要一个单品
//    BOOL shouldAddGoods = YES;
//    for (SMMatchImageView *matchImage in self.matchView.matchImageArray) {
//        if (matchImage.goodsModel.ID.length) {
//            shouldAddGoods = NO;
//        }
//    }
//    if (shouldAddGoods) {
//        [HTUIHelper addHUDToView:self.view withString:@"至少添加一个单品" hideDelay:1];
//        return;
//    }
    
    //判断单品数量是否符合要求。1-6个
    int goodsNumber = 0;
    for (SMMatchImageView *matchImage in self.matchView.matchImageArray) {
        if (matchImage.goodsModel.ID.length) {
            goodsNumber++;
        }
    }
    if (goodsNumber == 0) {
        [HTUIHelper addHUDToView:self.view withString:@"至少添加一个单品" hideDelay:1];
        return;
    }
    if (goodsNumber > 6) {
        [HTUIHelper addHUDToView:self.view withString:@"最多添加6个单品" hideDelay:1];
        return;
    }
    
    NSMutableArray *goodsIdArr = [NSMutableArray array];
    for (SMMatchImageView *matchImage in self.matchView.matchImageArray) {
        SMGoodsModel *model = matchImage.goodsModel;
        if (model.ID.length) {
            [goodsIdArr addObject:model.ID];
        }
    }
    SMPublishMatchController *vc = [[SMPublishMatchController alloc] init];
    vc.jsonString = [self draftString];
    //截图
    UIImage *image = [UIImage captureWithView:self.matchView.imageContainerView];
    vc.image = image;
    
    //判断是发布草稿还是发布最新的搭配
    if (self.draftId) {
        vc.publishType = SMPublishTypeDraftMatch;
        vc.matchDraftId = self.draftId;
    }else {
        vc.publishType= SMPublishTypeMatch;
    }
    vc.goodsIdArr = goodsIdArr;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -- 点击菜单
- (void)menuBtnClick {
    
#pragma mark --- 暂存
    [self cancelEditState];
    UIAlertController *alertview=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *save = [UIAlertAction actionWithTitle:@"暂存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //判断用户是否登录
        if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
            
            [self presentViewController:loginNav animated:YES completion:^{
                
            }];
            return;
        }
        [self saveMatchNet];
    }];
#pragma mark --- 打开我的草稿
    UIAlertAction *open = [UIAlertAction actionWithTitle:@"打开我的草稿" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //判断用户是否登录
        if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
            
            [self presentViewController:loginNav animated:YES completion:^{
                
            }];
            return;
        }
        __weak __typeof(&*self)weakSelf = self;
        SMMatchDraftController *draft = [[SMMatchDraftController alloc] init];
        draft.selectedDraftBlock = ^(SMMatchDraftModel *model){
            [weakSelf deleteMatch];
            weakSelf.draftId = model.ID;
            [weakSelf.matchView addImagesWithDraftModel:model];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        };
        [self.navigationController pushViewController:draft animated:YES];
        
    }];
#pragma mark --- 新建搭配
    UIAlertAction *new = [UIAlertAction actionWithTitle:@"新建搭配" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self getupCurrentOperation];
        
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertview addAction:save];
    [alertview addAction:open];
    [alertview addAction:new];
    [alertview addAction:cancel];
    
    [self presentViewController:alertview animated:YES completion:nil];
}
//弹窗。是否放弃当前操作
- (void)getupCurrentOperation {
    UIAlertController *alert =[UIAlertController alertControllerWithTitle:@"提示" message:@"是否放弃当前操作" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self deleteMatch];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:sure];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark - 生成草稿字符串
//生成草稿字符串

/**
 我给后台的
 {
 data =     (
 {
 angle = 0;
 bounds = "{{0, 0}, {150, 150}}";
 center = "{187.5, 187.5}";
 id = 2355;
 image = "http://www.ssrj.com/upload/image/201611/08ff926d-caf3-47b6-8a52-b1ea10aa1497-medium.png";
 isFlipX = 0;
 isFlipY = 0;
 scale = 1;
 scaleX = 1;
 scaleY = 1;
 screenWidth = 375;
 transform = "[1, 0, 0, 1, 0, 0]";
 type = image;
 }
 );
 }
 */
- (NSString *)draftString {
    // 位置信息，id，图片，和背景图(背景图我在每个dict中都存了一遍)
    NSMutableArray *draftArr = [NSMutableArray array];
    for (SMMatchImageView *matchImage in self.matchView.matchImageArray) {
        SMGoodsModel *model = matchImage.goodsModel;
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        [dict setObject:NSStringFromCGAffineTransform(matchImage.transform) forKey:@"transform"];
        [dict setObject:NSStringFromCGPoint(matchImage.center) forKey:@"center"];
        [dict setObject:NSStringFromCGRect(matchImage.bounds) forKey:@"bounds"];
        [dict setObject:@(kScreenWidth) forKey:@"screenWidth"];
        [dict setObject:@(matchImage.isFlipX) forKey:@"isFlipX"];
        [dict setObject:@(false) forKey:@"isFlipY"];
        [dict setObject:@([self getAngleFromTransform:matchImage.transform]) forKey:@"angle"];
        [dict setObject:@([self getScaleFromTransform:matchImage.transform]) forKey:@"scale"];
        [dict setObject:@([self getScaleFromTransform:matchImage.transform]) forKey:@"scaleX"];
        [dict setObject:@([self getScaleFromTransform:matchImage.transform]) forKey:@"scaleY"];
        [dict setObject:@"image" forKey:@"type"];
        [dict setObject:@(matchImage.isBgImage) forKey:@"isBgImage"];
        if (model.ID.length) {
            [dict setObject:model.ID forKey:@"id"];
        }
        [dict setObject:model.image forKey:@"image"];
        [draftArr addObject:dict];
    }
    
    NSDictionary *draftDict = @{@"data" : draftArr};
    NSData *data = [NSJSONSerialization dataWithJSONObject:draftDict options:0 error:nil];
    NSString *draftString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return draftString;
}
//根据transform 获得旋转角度
- (CGFloat)getAngleFromTransform:(CGAffineTransform)transform {
    CGFloat angle = atanf(transform.b / transform.a);
    //第一象限，角度不变
    if (transform.a > 0 && transform.b >= 0) {
    }
    //第二象限，角度加M_PI
    else if (transform.a <= 0 && transform.b > 0) {
        angle = M_PI + angle;
    }
    //第三象限，角度加M_PI
    else if (transform.a < 0 && transform.b <= 0) {
        angle = M_PI + angle;
    }
    //第四象限，角度加2 * M_PI
    else {
        angle = 2 * M_PI + angle;
    }
    if (self.matchView.selectImageView.isFlipX) {
        angle = angle - M_PI;
    }
    return angle * 180 / M_PI;
}
//根据transform 获得放大倍数
- (CGFloat)getScaleFromTransform:(CGAffineTransform)transform {
    CGFloat angle = atanf(transform.b / transform.a);
    CGFloat scale = transform.a / cos(angle);
    //翻转scale会变为负数。取绝对值
    return fabs(scale);
}
//新建搭配，清空面板
- (void)deleteMatch {
    //删除单品或素材
    for (SMMatchImageView *matchImage in self.matchView.matchImageArray) {
        [matchImage removeFromSuperview];
    }
    [self.matchView.matchImageArray removeAllObjects];
    //草稿id置空
    self.draftId = nil;
    //操作清空
    [self.matchView deleteAllRecord];
}
/** 将图片缩放到指定大小 */
- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}
#pragma mark - 保存草稿 network
//http://192.168.1.173:9999/api/v1/collocation/publish
//和发布同一个接口，status = 3 为保存草稿 id是草稿id，为空表示保存草稿，不为空表示修改草稿
// title 其实不需要传，后台要求传，所以随便传什么都可以 image 截图
/**post 参数
 appVersion	2.2.0
 draft	{"data":[{"id":"2067","scale":1,"isFlipY":0,"angle":0,"type":"image","transform":"[1, 0, 0, 1, 0, 0]","isFlipX":false,"image":"http:\/\/www.ssrj.com\/upload\/image\/201610\/ab9e36b3-ac1d-4755-8223-817f945edcc2-source.png","scaleY":1,"center":"{187.5, 187.5}","scaleX":1,"bounds":"{{0, 0}, {150, 150}}","screenWidth":375}]}
 image	/9j/4AAQSkZJRgABAQAAAAAAAAD/......
 status	3
 title	WWWW
 token	daf1a91acee1be236510cc2bd1873b49
 id
 */
/** response 返回搭配id
 "data": {
    "collocation": 7061
	}
 */
/** 保存草稿 */
- (void)saveMatchNet{
    BOOL shouldAddGoods = YES;
    for (SMMatchImageView *matchImage in self.matchView.matchImageArray) {
        if (matchImage.goodsModel.ID.length) {
            shouldAddGoods = NO;
        }
    }
    if (shouldAddGoods) {
        [HTUIHelper addHUDToView:self.view withString:@"至少添加一个单品" hideDelay:1];
        return;
    }
    
    
    //截图
    UIImage *image = [UIImage captureWithView:self.matchView.imageContainerView];
    image = [self imageWithImageSimple:image scaledToSize:CGSizeMake(600, 600)];
    NSData *imagedata = UIImageJPEGRepresentation(image, 0.5);
    NSString *base64Str = [imagedata base64EncodedStringWithOptions:0];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"WWWW" forKey:@"title"];
    [dict setObject:@"3" forKey:@"status"];
    [dict setObject:[self draftString] forKey:@"draft"];
    [dict setObject:base64Str forKey:@"image"];
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = SaveDraftUrl;
    requestInfo.postParams = dict;
    if (self.draftId) {
        [requestInfo.postParams addEntriesFromDictionary:@{@"id" : self.draftId}];
    }
    [[HTUIHelper shareInstance] addHUDToView:self.view withString:nil xOffset:0 yOffset:0];
    [[ZHNetworkManager sharedInstance] postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"state"] intValue] == 0) {
            if (weakSelf.draftId) {
                [HTUIHelper addHUDToView:weakSelf.view withString:@"修改成功" hideDelay:1];
            }else {
                [HTUIHelper addHUDToView:weakSelf.view withString:@"已保存" hideDelay:1];
                weakSelf.draftId = [NSString stringWithFormat:@"%@",responseObject[@"data"][@"collocation"]];
            }
        }else {
             [HTUIHelper addHUDToView:weakSelf.view withString:responseObject[@"msg"] hideDelay:1];
        }
        [[HTUIHelper shareInstance] removeHUD];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance] removeHUD];
         [HTUIHelper addHUDToView:weakSelf.view withString:@"error" hideDelay:1];
    }];
}

#pragma mark - <UIGestureRecognizerDelegate>
//点击单图
- (void)didTapMatchImage:(SMMatchView *)matchView {
    _coverView.hidden = NO;
}
//点击matchView
- (void)didTapMatchView:(SMMatchView *)matchView {
    _coverView.hidden = YES;
}
#pragma mark - 点击底部蒙版
- (void)coverViewTap:(UITapGestureRecognizer *)recognizer {
    [self cancelEditState];
}
- (void)cancelEditState {
    self.matchView.selectImageView = nil;
    _coverView.hidden = YES;
    _bottomView.hidden = NO;
}
#pragma mark -- 点击或滑动底部条，都要向上滚动
- (void)bottomViewTap:(UITapGestureRecognizer *)recognizer {
    [self scrollToTop:YES];
}
- (void)bottomViewPan:(UIPanGestureRecognizer *)recognizer {
    [self scrollToTop:YES];
}

//- (void)setupMatchBgNotification:(NSNotification *)notification {
//    NSString *urlString = notification.object;
//    [self.matchView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"placeHodler"]];
//    [self scrollToTop:NO];
//}
@end
