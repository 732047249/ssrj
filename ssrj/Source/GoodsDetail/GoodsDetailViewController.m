//
//  GoodsDetailViewController.m
//  ssrj
//
//  Created by MFD on 16/5/31.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "GoodsDetailViewController.h"
#import "MoreGoodsCell.h"
#import "GoodsInfoCell.h"
#import "RelatedGoodsCell.h"
#import "RecommendedGoodsCollectionViewCell.h"
#import "GoodsDetailScrollBannerView.h"
#import "CartOrBuyViewController.h"
#import "RJGoodDetailModel.h"
#import "CollectionsViewController.h"
#import "RelationGoodsTableViewCell.h"
#import "HomeGoodListViewController.h"
#import "cartOrBuyModel.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Masonry.h"
#import "ZanModel.h"
#import "XHImageViewer.h"
#import "RJBrandDetailRootViewController.h"
#import "RJAnswerOneViewController.h"

#define SCREEN_BOUNDS    [UIScreen mainScreen].bounds

@interface GoodsDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UIWebViewDelegate,GoodsInfoCellDelegate,UICollectionViewDataSource,UICollectionViewDelegate,GoodsDetailScrollBannerViewDelegate,UMSocialUIDelegate,XHImageViewerDelegate,RJTapedUserViewDelegate, CartOrBuyViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
//header价格下方分割线的高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerBottomLineHeightConstraint;
@property (copy, nonatomic) NSMutableDictionary *heightDic;
@property (weak, nonatomic) IBOutlet UIView *footerView;
//搭配推荐下边框横行高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *footerViewHeaderLineHeightConstraint;


@property (weak, nonatomic) IBOutlet UIButton *addCartBtn;
@property (weak, nonatomic) IBOutlet UIButton *buyBtn;
@property (weak, nonatomic) IBOutlet GoodsDetailScrollBannerView *goodsDetailScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *goodsPage;




@property (weak, nonatomic) IBOutlet UICollectionView *recommendedGoodsCollectionView;

@property (strong,nonatomic)NSMutableArray *productImagesArr;

@property (assign, nonatomic) CGFloat webViewHeight;

@property (strong, nonatomic)RJGoodDetailModel *datamodel;

@property (weak, nonatomic) IBOutlet UILabel *goodsName;
@property (weak, nonatomic) IBOutlet UILabel *goodsBrandName;

@property (weak, nonatomic) IBOutlet UILabel *currentPrice;
@property (weak, nonatomic) IBOutlet UILabel *marketPrice;
@property (weak, nonatomic) IBOutlet UILabel *discount;
@property (weak, nonatomic) IBOutlet UILabel *isSpecialprice;

@property (strong, nonatomic)CartOrBuyViewController *cartOrBuyVC;


@property (nonatomic, strong) MPMoviePlayerViewController *moviePlayer;
@property (weak, nonatomic) IBOutlet CCButton *zanBtn;

/**
 *  选择颜色button的父视图 scrollview
 */

@property (weak, nonatomic) IBOutlet UIScrollView *colorScrollView;
@property (nonatomic,strong) MPMoviePlayerController *mpPlayer;

@end

@implementation GoodsDetailViewController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.isSpecialprice.hidden = YES;

    [MobClick beginLogPageView:@"单品详情页面"];
    [TalkingData trackPageBegin:@"单品详情页面"];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    if (self.goodsDetailScrollView.timer) {
//        [self.goodsDetailScrollView startTimer];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.goodsDetailScrollView.timer) {
        [self.goodsDetailScrollView stopTimer];
    }
    
    [MobClick endLogPageView:@"单品详情页面"];
    [TalkingData trackPageEnd:@"单品详情页面"];

}

- (void)viewDidLoad {

    [super viewDidLoad];
//    if (self.fomeCollectionId) {
//        [HTUIHelper addHUDToView:self.view withString:self.fomeCollectionId.stringValue hideDelay:1];
//    }
    self.view.trackingId = [NSString stringWithFormat:@"GoodsDetailViewController&goodsId=%@",self.goodsId];
    [self setTitle:@"单品详情" tappable:NO];
    self.webViewHeight = SCREEN_HEIGHT;
    [self addBackButton];
    NSArray * arr = @[@1,@2];
    [self addBarButtonItems:arr onSide:RJNavRightSide];

    self.productImagesArr = [NSMutableArray array];
    
    self.discount.layer.cornerRadius = 4;
    self.discount.clipsToBounds = YES;
    self.isSpecialprice.layer.cornerRadius = 4;
    self.isSpecialprice.clipsToBounds = YES;
    
    CGFloat hei = SCREEN_WIDTH+15+85 +48;
    self.headerView.height = hei;
    self.tableView.tableHeaderView = self.headerView;
    self.headerBottomLineHeightConstraint.constant = 0.7;
    self.hasClickZanBtn = NO;
    self.recommendedGoodsCollectionView.showsVerticalScrollIndicator = NO;
    
    self.footerView.height = 34+ 2*(5+15+SCREEN_WIDTH/320*160+70);
    self.footerViewHeaderLineHeightConstraint.constant = 0.7;
    self.tableView.tableFooterView = self.footerView;
    self.recommendedGoodsCollectionView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 2*(5+15+SCREEN_WIDTH/320*160+70));
    [self.tableView reloadData];
    [self.recommendedGoodsCollectionView reloadData];
    
    __weak __typeof(&*self)weakSelf = self;

    [self.buyBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.addCartBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.zanBtn addTarget:self action:@selector(clickZanBtn:) forControlEvents:UIControlEventTouchUpInside];
    /**
     *  统计
     */
    if (self.goodsId) {
        self.buyBtn.trackingId = [NSString stringWithFormat:@"%@&buyButton&id=%@",NSStringFromClass(self.class),self.goodsId];
        self.addCartBtn.trackingId = [NSString stringWithFormat:@"%@&addCartButton&id=%@",NSStringFromClass(self.class),self.goodsId];
        self.zanBtn.trackingId = [NSString stringWithFormat:@"%@&zanBtn&id=%@",NSStringFromClass(self.class),self.goodsId];
    }
    self.goodsDetailScrollView.delegate = self;
    [self updateHeaderScrollView];
    
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
        
    }];

    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - 立即购买或者加入购物车的cover代理方法，让单品详情弹回选择尺码&数量的cover
-(void)reloadGoodsDetailCloseCoverWithisReload:(BOOL)isReload {
    [self getNetData];
}

/**
 *  Banner 轮播图
 */
- (void)updateHeaderScrollView{
    if (self.productImagesArr.count) {
        /**
         *  传对象过去
         */
        NSMutableArray *imageArr = [NSMutableArray arrayWithArray:[self.productImagesArr copy]];
        
        [self.goodsDetailScrollView uploadScrollBannerViewWithDataArray:imageArr];
    }
}

#pragma mark - CCScrollBannerViewDelegate
- (void)didSelectImageWithTag:(NSInteger)tag andImageViews:(NSMutableArray *)imageViews hasVideo:(BOOL)flag{
    RJGoodDetailProductImagesModel *model = self.productImagesArr[tag];
    if (model.videoPath.length) {
//        self.moviePlayer = nil;
//        self.moviePlayer = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:model.videoPath]];
//        [self presentMoviePlayerViewControllerAnimated:self.moviePlayer];
    }else{
        XHImageViewer *imageViewer = [[XHImageViewer alloc] init];
        imageViewer.delegate = self;
        if (flag) {
            [imageViewer showWithImageViews:imageViews selectedView:imageViews[tag-1]];

        }else{
            [imageViewer showWithImageViews:imageViews selectedView:imageViews[tag]];

        }

    }
}

#pragma mark - XHImageViewerDelegate

- (void)imageViewer:(XHImageViewer *)imageViewer willDismissWithSelectedView:(UIImageView *)selectedView {
//    NSInteger index = [self.productImagesArr indexOfObject:selectedView];
//    NSLog(@"index : %ld", (long)index);
}


- (void)getNetData{
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    //线上接口
    requestInfo.URLString = @"/api/v5/product/detail.jhtml";
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    if (self.goodsId) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"goodsId":self.goodsId}];
    }
    __weak __typeof(&*self)weakSelf = self;
    requestInfo.modelClass = [RJBasicModel class];
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) {
            RJBasicModel *model = responseObject;
            if (model.state.boolValue == 0) {
                NSDictionary *dic = (NSDictionary *)model.data;
                RJGoodDetailModel *dataModel = [[RJGoodDetailModel alloc]initWithDictionary:dic error:nil];
                if (!dataModel) {
                    [HTUIHelper addHUDToView:weakSelf.view withString:@"请求数据错误，请稍后再试" hideDelay:1];
                    [weakSelf.tableView.mj_header endRefreshing];
                    return;
                }
                weakSelf.datamodel = dataModel;
                
                [weakSelf.productImagesArr removeAllObjects];
                [weakSelf.productImagesArr addObjectsFromArray:[dataModel.productImages copy]];
                weakSelf.goodsPage.numberOfPages = weakSelf.productImagesArr.count;
                
                weakSelf.goodsName.text = dataModel.name;
                weakSelf.goodsBrandName.text = dataModel.brandName;
                weakSelf.currentPrice.text = [NSString stringWithFormat:@"¥ %@",dataModel.effectivePrice];
                NSDictionary *attributDic = @{NSStrikethroughStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle]};
                NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"¥ %@",dataModel.marketPrice] attributes:attributDic];
                weakSelf.marketPrice.attributedText = attribtStr;
                weakSelf.discount.text = [NSString stringWithFormat:@"%.1f折",[dataModel.discount floatValue]];
                
                if (dataModel.isThumbsup.integerValue == 0) {

                    weakSelf.zanBtn.selected = NO;
                }else{
                    weakSelf.zanBtn.selected = YES;

                }
                
                weakSelf.zanBtn.titleLabel.text = dataModel.thumbsupCount.stringValue;
                [weakSelf loadColorBtnsData];
                if (dataModel.isSpecialPrice.intValue) {
                    weakSelf.isSpecialprice.hidden = NO;
                }
                [weakSelf updateHeaderScrollView];
                [weakSelf.recommendedGoodsCollectionView reloadData];
                [weakSelf.tableView reloadData];
            }else{
                [HTUIHelper addHUDToView:self.view withString:model.msg hideDelay:2];
            }
        }
        [weakSelf.tableView.mj_header endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
        [weakSelf.tableView.mj_header endRefreshing];
        
    }];
}

- (void)loadColorBtnsData{
    for (UIView *view in self.colorScrollView.subviews) {
        if ([view isKindOfClass:[CCButton class]]) {
            [view removeFromSuperview];
        }
    }
    self.colorScrollView.showsHorizontalScrollIndicator = NO;
    CGFloat xPositon = 10;
    RJGoodDetailColorButton *firstButton = [[[NSBundle mainBundle]loadNibNamed:@"RJGoodDetailColorButton" owner:self options:nil]firstObject];
    [firstButton.icon sd_setImageWithURL:[NSURL URLWithString:self.datamodel.colorPicture] placeholderImage:GetImage(@"default_1x1")];
    firstButton.titleLabel.text = self.datamodel.colorName;
    [firstButton setNeedsLayout];
    [firstButton setNeedsUpdateConstraints];
    firstButton.size = [firstButton systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];

    /**
     *  统计ID
     */
    firstButton.trackingId = [NSString stringWithFormat:@"%@&colorButton&id=%@",NSStringFromClass(self.class),self.datamodel.dataId.stringValue];
    
    firstButton.center = self.colorScrollView.center;
    [firstButton setOrigin:CGPointMake(xPositon, firstButton.yPosition)];
    [firstButton showSelected];
    xPositon += firstButton.width +10;
    [self.colorScrollView addSubview:firstButton];
    
    NSArray *colorArr = self.datamodel.colorGoods;
    
    for (int i =0; i<colorArr.count; i++) {
        /**
         *  后台貌似一个颜色 这个数组是空的  多个颜色 所有颜色都在这个数组里面。。。
         */
        if (i == 0) {
            continue;
        }
        RJGoodDetailColorGoodModel *model = colorArr[i];
        RJGoodDetailColorButton *button = [[[NSBundle mainBundle]loadNibNamed:@"RJGoodDetailColorButton" owner:self options:nil]firstObject];
        button.layer.cornerRadius = 4;
        button.clipsToBounds = YES;
        [button.icon sd_setImageWithURL:[NSURL URLWithString:model.colorPicture] placeholderImage:GetImage(@"default_1x1")];
        button.titleLabel.text = model.colorName;
        [button setNeedsLayout];
        [button setNeedsUpdateConstraints];
        button.size = [button systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
        button.center = self.colorScrollView.center;
        [button setOrigin:CGPointMake(xPositon, firstButton.yPosition)];
        xPositon += button.width +10;
        [self.colorScrollView addSubview:button];
        button.tag = i;
        [button addTarget:self action:@selector(colorButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        button.trackingId = [NSString stringWithFormat:@"%@&colorButton&id=%@",NSStringFromClass(self.class),model.goodsId.stringValue];
        
    }
    [self.colorScrollView setContentSize:CGSizeMake(xPositon, self.colorScrollView.height)];
    
}

- (void)clickBtn:(UIButton *)btn{
    [MobClick event:@"add_shopCart"];
    
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:^{

        }];
        return;
    }
    if (self.datamodel) {
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
        CartOrBuyViewController *vc = [sb instantiateViewControllerWithIdentifier:@"CartOrBuyViewController"];
        vc.cartOrBuy = btn.tag;
        vc.delegate = self;
        vc.fromGoodsId = _goodsId;
        if (self.fomeCollectionId) {
            vc.fomeCollectionId = self.fomeCollectionId;
        }
        self.cartOrBuyVC = vc;
        
        vc.datamodel = self.datamodel;
        vc.detailView.backgroundColor = [UIColor colorWithRed:1.000 green:0.988 blue:0.960 alpha:1.000];
        [vc addViewToKeyWindow];
        for (UIViewController *vc in self.childViewControllers) {
            if ([vc isKindOfClass:[CartOrBuyViewController class]]) {
                [vc removeFromParentViewController];
            }
        }
        [self addChildViewController:vc];
    }
} 
// 动画1
- (CATransform3D)firstStepTransform {
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0 / -500.0;
    transform = CATransform3DScale(transform, 0.98, 0.98, 1.0);
    transform = CATransform3DRotate(transform, 5.0 * M_PI / 180.0, 1, 0, 0);
    transform = CATransform3DTranslate(transform, 0, 0, -30.0);
    return transform;
}

// 动画2
- (CATransform3D)secondStepTransform {
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = [self firstStepTransform].m34;
    transform = CATransform3DTranslate(transform, 0, SCREEN_HEIGHT * -0.08, 0);
    transform = CATransform3DScale(transform, 0.8, 0.8, 1.0);
    return transform;
}

#pragma mark --tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        if (!self.datamodel.relationGoods.count) {
            return 0;
        }
        return 121;
    }
    if (indexPath.row == 1) {

        return 10 +32 +SCREEN_WIDTH*27/64 +10;
    }
    if (indexPath.row == 2) {
        if (!self.datamodel.sizePath) {
            return 0;
        }
        return self.webViewHeight+15;
    }
    if (indexPath.row == 3) {
        if (!self.datamodel.collocations.count) {
            return 0;
        }
        return SCREEN_WIDTH/320*118 +40 +55 +15 +22;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        RelationGoodsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RelationGoodsTableViewCell"];
        cell.dataArray = self.datamodel.relationGoods;        
        [cell.RelationGoodsCollectionView reloadData];
        return cell;
    }
    if (indexPath.row == 1) {
        MoreGoodsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MoreGoodsCell" forIndexPath:indexPath];
        
        [cell.brandImage sd_setImageWithURL:[NSURL URLWithString:self.datamodel.brandAppImage2] placeholderImage:[UIImage imageNamed:@"640X200"]
         ];
        cell.trackingId = [NSString stringWithFormat:@"%@/MoreGoodsCell&id=%@",NSStringFromClass([self class]),self.datamodel.dataId];
        return cell;
    }
    if(indexPath.row == 2){
        GoodsInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GoodsInfoCell"];
        cell.delegate = self;

        cell.contentStr = self.datamodel.sizePath;
        return cell;
    }
    if (indexPath.row == 3) {
        RelatedGoodsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RelatedGoodsCell" forIndexPath:indexPath];
        cell.dataArray = self.datamodel.recommendGoods;
        //不及时刷新，可能导致cell出不来
        [cell.relatedGoodsCollectionView reloadData];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {

        /**
         *  去新的品牌界面
         */
        if (self.datamodel.brandId) {
            NSDictionary *dic = @{@"brands":self.datamodel.brandId};
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
            RJBrandDetailRootViewController *rootVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJBrandDetailRootViewController"];
            rootVc.parameterDictionary = dic;
            rootVc.brandId = self.datamodel.brandId;
            [self.navigationController pushViewController:rootVc  animated:YES];
        }

    }
    
}

#pragma mark RecommendGoodscollectionView
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
        CollectionsViewController *collectionViewController = [sb instantiateViewControllerWithIdentifier:@"CollectionsViewController"];
        RJGoodDetailRelationCollocationModel *model= self.datamodel.collocations[indexPath.row];
        collectionViewController.collectionId = model.collocationId;
        collectionViewController.zanBlock = ^(NSInteger buttonState){
            RJGoodDetailRelationCollocationModel *model= self.datamodel.collocations[indexPath.row];
            model.isThumbsup = [NSNumber numberWithInteger:buttonState];
            [self.recommendedGoodsCollectionView reloadItemsAtIndexPaths:@[indexPath]];
        };
        [self.navigationController pushViewController:collectionViewController animated:YES];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
        NSInteger count = self.datamodel.collocations.count;
        self.footerView.height = 40+ (count+1)/2*(5+15+SCREEN_WIDTH/320*160+70);
        self.tableView.tableFooterView = self.footerView;
        self.recommendedGoodsCollectionView.frame = CGRectMake(0, 0, SCREEN_WIDTH, (count+1)/2*(5+15+SCREEN_WIDTH/320*160+70));
        return self.datamodel.collocations.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
        RecommendedGoodsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RecommendedGoodsCollectionViewCell" forIndexPath:indexPath];
        [cell hideRightLine];
        if (indexPath.row %2 == 0) {
            [cell showRightLine];
        }
        /**
         *  点击去用户中心
         */
        cell.userDelegate = self;
        RJGoodDetailRelationCollocationModel *model = self.datamodel.collocations[indexPath.row];
        /**
         *  统计ID
         */
        cell.trackingId = [NSString stringWithFormat:@"%@RecommendedGoodsCollectionViewCell&id:%d",NSStringFromClass([self class]),model.collocationId.intValue];
        
        cell.model = model;
        [cell.recommendGoodsImage sd_setImageWithURL:[NSURL URLWithString:model.picture] placeholderImage:nil];
        [cell.authorImg sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:nil];
        cell.recomendName.text = model.name;
        cell.recommendAuthor.text = model.autherName;
        cell.shoucangMaskBtn.tag = indexPath.row;
        cell.hasClickShouCang = NO;
        cell.colloctionId = model.collocationId;
        cell.changeStateBlock = ^(NSNumber * number){
            RJGoodDetailRelationCollocationModel *model = self.datamodel.collocations[indexPath.row];
            model.isThumbsup = number;
        };
        cell.colloctionId = model.collocationId;
        if (model.isThumbsup.integerValue == 0) {
            cell.zanBtn.selected = NO;
        }else{
            cell.zanBtn.selected = YES;
        }
    
        cell.addToThemeBtn.trackingId = [NSString stringWithFormat:@"%@RecommendedGoods&addToThemeBtn&id:%d",NSStringFromClass([self class]),model.collocationId.intValue];
        cell.zanBtn.trackingId = [NSString stringWithFormat:@"%@RecommendedGoods&zanBtn&id:%d",NSStringFromClass([self class]),model.collocationId.intValue];

        return cell;

}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
        return CGSizeMake(SCREEN_WIDTH/320*160, 20 +SCREEN_WIDTH/320*160  +70);
}


#pragma mark -GoodsInfoCellDelegate刷新webView
- (void)cellFinishLoadedWithWebViewHeight:(CGFloat)height{
  
    self.webViewHeight = height;
    [self.tableView reloadData];
    
}


- (void)clickZanBtn:(UIButton *)sender {
    //判断用户是否登录
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
        return;
    }
    
    [self zanNetRequest:sender];
    
  
}


#pragma zanNetRequest
- (void)zanNetRequest:(UIButton *)sender{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"/b82/api/v5/thumb?type=goods";
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    if (self.goodsId) {
        
        [requestInfo.getParams addEntriesFromDictionary:@{@"id":self.goodsId}];
    }
    __weak __typeof(&*self)weakSelf = self;
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {

            NSNumber *state = [responseObject objectForKey:@"state"];

            
            if (state.intValue == 0) {
                
                NSNumber *thumbCount = [responseObject[@"data"] objectForKey:@"thumbCount"];
                
                BOOL thumb = [[responseObject[@"data"] objectForKey:@"thumb"] boolValue];
                
                sender.selected = thumb;
                
                sender.titleLabel.text = [NSString stringWithFormat:@"%@",thumbCount];
           
                //单品列表传的block
                if (weakSelf.zanBlock) {
                    weakSelf.zanBlock(sender.selected);
                }
            }
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
            
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        
    }];

}


- (void)colorButtonAction:(UIButton *)sender {
    RJGoodDetailColorGoodModel *colorGoods = self.datamodel.colorGoods[sender.tag];
    self.goodsId = colorGoods.goodsId;
    [self getNetData];
}

#pragma mark - 分享
- (void)share:(id)sender{
    if (self.datamodel) {
        
        NSArray *shareType = [NSArray arrayWithObjects:UMShareToSina,UMShareToQQ,UMShareToQzone,UMShareToWechatSession,UMShareToWechatTimeline,nil];
        [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ, UMShareToQzone, UMShareToWechatSession, UMShareToWechatTimeline]];
        NSString *imageUrl = self.datamodel.thumbnail;
        NSString *comment = self.datamodel.productDesc;
        NSString *shareUrl = self.datamodel.mobilePath;
        [UMSocialData defaultData].extConfig.wechatSessionData.url = shareUrl;
        [UMSocialData defaultData].extConfig.wechatSessionData.title = self.datamodel.name;
        
        [UMSocialData defaultData].extConfig.wechatTimelineData.url = shareUrl;
        [UMSocialData defaultData].extConfig.qqData.url = shareUrl;
        [UMSocialData defaultData].extConfig.qqData.title = self.datamodel.name;
        
        [UMSocialData defaultData].extConfig.qzoneData.url = shareUrl;
        [UMSocialData defaultData].extConfig.qzoneData.title = self.datamodel.name;
        
        [UMSocialData defaultData].extConfig.sinaData.shareText =[NSString stringWithFormat:@"%@%@",comment,shareUrl];
        
        //调用快速分享接口
        [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:imageUrl];
        
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:UmengAppkey
                                          shareText:comment
                                         shareImage:nil
                                    shareToSnsNames:shareType
                                           delegate:self];

    }
}

-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        ZHRequestInfo *requestInfo = [ZHRequestInfo new];
        requestInfo.URLString =[NSString stringWithFormat:@"/b180/api/v1/point/variation?type=33&id=%d",self.datamodel.dataId.intValue];
        
        [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        }];
    }
}


-(void)didFinishShareInShakeView:(UMSocialResponseEntity *)response
{
    
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
        
}
#pragma mark -
#pragma mark RJTapedUserViewDelegate
- (void)didTapedUserViewWithUserId:(NSNumber *)userId userName:(NSString*)userName{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    RJUserCenteRootViewController *rootVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJUserCenteRootViewController"];
    if (!userId) {
        return;
    }
    rootVc.userId = userId;
    rootVc.userName = userName;
    
    [self.navigationController pushViewController:rootVc animated:YES];
}


@end


@implementation RJGoodDetailColorButton
- (void)awakeFromNib{
    [super awakeFromNib];
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor colorWithHexString:@"#c6c6c6"].CGColor;
}
- (void)showSelected{
    self.layer.borderColor = APP_BASIC_COLOR2.CGColor;

}
- (void)showNormal{
    self.layer.borderColor = [UIColor colorWithHexString:@"#c6c6c6"].CGColor;
    
}
@end
