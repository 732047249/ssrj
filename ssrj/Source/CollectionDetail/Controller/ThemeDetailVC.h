//
//  ThemeDetailVC.h
//  ssrj
//
//  Created by MFD on 16/6/29.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"
#import "RJHomeItemTypeFourModel.h"
#import "CCButton.h"
@protocol ThemeDetailVCDelegate <NSObject>
@optional
- (void)reloadHomeZanMessageNetDataWithBtnstate:(BOOL)btnSelected;
- (void)reloadUserCenterPublishTableViewData;
@end


@interface ThemeDetailVC : RJBasicViewController
//@property (nonatomic,strong)NSDictionary * parameterDictionary;//传值themeItemId
@property (weak, nonatomic) IBOutlet UICollectionView *themesCollectionView;
//给上级UI（HomeViewController的RJHomeSubjectAndCollectionCell）发送更新数据的代理
@property (weak, nonatomic) id<ThemeDetailVCDelegate>delegate;

@property (strong, nonatomic) NSNumber *themeItemId;

/**
 *  3.0.0
 */
//add 12.28 记录是否进入了用户自己的用户中心
@property (assign, nonatomic) BOOL isSelf;
@property (assign, nonatomic) BOOL isPublished;

/**
 * 3.0.1 新增发布列表cell来源类型
 */
@property (strong, nonatomic) NSNumber <Optional> *event;


@end



typedef NS_ENUM(NSUInteger, FooterButtonState) {
    FooterNormal = 0,
    FooterLoading,
    FooterNoMore,
};

/**
 *  2.2.0 点击按钮加载更多搭配 can
 */
@interface RJThemeDetailMatchListFooterView :UICollectionReusableView
@property (nonatomic,weak)IBOutlet CCButton * button;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic, assign) FooterButtonState  state;
- (void)setNormalState;
- (void)setLoadingState;
- (void)setNomoreState;
@end