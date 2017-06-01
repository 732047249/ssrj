//
//  SMGoodsDetailController.m
//  ssrj
//
//  Created by 夏亚峰 on 16/11/18.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMGoodsDetailController.h"
#import "SMGoodsDetailHeader.h"
#import "ZanModel.h"
#import "SMCreateMatchController.h"
#import "XHImageViewer.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Masonry.h"

static NSString *const StarNetUrl = @"/b82/api/v5/thumb?type=goods";
static NSString *const GoodsDetailUrl = @"/api/v5/product/view.jhtml";
@interface SMGoodsDetailController ()<SMGoodsDetailScrollViewDelegate,XHImageViewerDelegate,UMSocialUIDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) SMGoodsDetailHeader *header;
@property (strong, nonatomic)RJGoodDetailModel *datamodel;
@property (strong,nonatomic)NSMutableArray *productImagesArr;
@property (nonatomic, strong) MPMoviePlayerViewController *moviePlayer;
@end

@implementation SMGoodsDetailController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [MobClick beginLogPageView:@"创建搭配-查看单品详情页面"];
    [TalkingData trackPageBegin:@"创建搭配-查看单品详情页面"];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"创建搭配-查看单品详情页面"];
    [TalkingData trackPageEnd:@"创建搭配-查看单品详情页面"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self addBackButton];
    [self addBarButtonItem:RJNavShareButtonItem onSide:RJNavRightSide];
    self.title = self.model.name;
    _productImagesArr = [NSMutableArray array];
    // Do any additional setup after loading the view.
    [self configTableView];
    [self configHeader];
    [self getNetData];
}
#pragma mark - UI
- (void)configTableView {
    _tableView = [[UITableView alloc]initWithFrame:self.view.bounds];
    _tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_tableView];
    _tableView.tableFooterView = [UIView new];
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];


}
- (void)configHeader {
    //screenWidth + 20 + addBtnWidth(80) + 10 + 1 + 20 + 18 + 8 + 15 + 8 + 18 + 20 + 1
    _header = [[SMGoodsDetailHeader alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth + 219)];
    [_header.starButton addTarget:self action:@selector(clickZanBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_header.addGoodsButton addTarget:self action:@selector(clickAddBtn) forControlEvents:UIControlEventTouchUpInside];
    _header.goodsDetailScrollView.delegate = self;
    _tableView.tableHeaderView = _header;
    
}
#pragma mark - event
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
- (void)clickAddBtn {
        if ([self.navigationController.parentViewController isKindOfClass:[SMCreateMatchController class]]) {
            SMCreateMatchController *createMatchVC = (SMCreateMatchController *)self.navigationController.parentViewController;
            SMGoodsModel *goodsModel = [[SMGoodsModel alloc] init];
            goodsModel.name = _model.name;
            goodsModel.ID = _model.goodId;
            goodsModel.image = _model.source;
            [createMatchVC addGoodsOrSourceWithModel:goodsModel];
            [self.navigationController popViewControllerAnimated:NO];
        }
}
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

#pragma mark - CCScrollBannerViewDelegate
- (void)didSelectImageWithTag:(NSInteger)tag andImageViews:(NSMutableArray *)imageViews hasVideo:(BOOL)flag{
    RJGoodDetailProductImagesModel *model = self.productImagesArr[tag];
    if (model.videoPath.length) {
//        self.moviePlayer = nil;
//        self.moviePlayer = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:model.videoPath]];
//        [self presentMoviePlayerViewControllerAnimated:self.moviePlayer];
        //http://www.ssrj.cn/static/JFP106.mp4
        //http://211.94.114.44/v.cctv.com/flash/mp4video6/TMS/2011/01/05/cf752b1c12ce452b3040cab2f90bc265_h264818000nero_aac32-1.mp4
        //http://192.168.1.106/czj/12.mp4
        //        self.moviePlayer.moviePlayer.shouldAutoplay = YES;
        //        [self presentViewController:self.moviePlayer animated:YES completion:^{
        //            [self.moviePlayer.moviePlayer play];
        //        }];
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

#pragma mark - zanNetRequest
- (void)zanNetRequest:(UIButton *)sender{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = StarNetUrl;
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    if (self.goodsId) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"id":self.goodsId}];
    }
    
    __weak __typeof(&*self)weakSelf = self;

    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if ([responseObject objectForKey:@"state"]) {
            
             NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                NSNumber *thumbCount = [responseObject[@"data"] objectForKey:@"thumbCount"];
                
                BOOL thumb = [[responseObject[@"data"] objectForKey:@"thumb"] boolValue];
                
                sender.selected = thumb;
                
                if (thumb) {
                    [sender setTitle:[NSString stringWithFormat:@"%@",thumbCount] forState:UIControlStateNormal];
                }
            }
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:weakSelf.view withString:responseObject[@"msg"] hideDelay:1];
            }

            
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
        
    }];
    
}
#pragma mark - data
- (void)getNetData{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    //测试接口
    //    requestInfo.URLString = @"http://192.168.1.19/api/v4/product/view.jhtml";
    
    //线上接口
    requestInfo.URLString = GoodsDetailUrl;
    
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
            if (model.state.intValue == 0) {
                NSDictionary *dic = (NSDictionary *)model.data;
                RJGoodDetailModel *dataModel = [[RJGoodDetailModel alloc]initWithDictionary:dic error:nil];
                if (!dataModel) {
                    [HTUIHelper addHUDToView:self.view withString:@"解析数据失败，请稍后再试" hideDelay:1];
                    return;
                }
                weakSelf.datamodel = dataModel;
                
                [weakSelf.productImagesArr removeAllObjects];
                [weakSelf.productImagesArr addObjectsFromArray:[dataModel.productImages copy]];
//                weakSelf.goodsPage.numberOfPages = weakSelf.productImagesArr.count;
                
                [weakSelf.header setDataModel:dataModel];
                [weakSelf updateHeaderScrollView];
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
/**
 *  Banner 轮播图
 */
- (void)updateHeaderScrollView{
    if (self.productImagesArr.count) {
        /**
         *  传对象过去
         */
        NSMutableArray *imageArr = [NSMutableArray arrayWithArray:[self.productImagesArr copy]];
        
        [self.header.goodsDetailScrollView uploadScrollBannerViewWithDataArray:imageArr];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
