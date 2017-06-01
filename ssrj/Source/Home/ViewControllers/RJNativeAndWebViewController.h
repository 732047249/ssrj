//
//  RJPushWebViewController.h
//  ssrj
//
//  Created by CC on 16/12/7.
//  Copyright © 2016年 ssrj. All rights reserved.
//
/**
 *  上方是H5 下面是原生的商品列表
 *
 */
#import "RJBasicViewController.h"
#import "CCGoodOrderWithOutFilterView.h"

@interface RJNativeAndWebViewController : RJBasicViewController
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong) NSNumber * activeId;
@end


@interface RJNativeAndWebCollectionHeaderView : UICollectionReusableView
@property (nonatomic,weak) IBOutlet UIWebView * webView;
@end


@interface RJNativeAndWebCollectionOrderHeaderView : UICollectionReusableView
@property (nonatomic,weak) IBOutlet CCGoodOrderWithOutFilterView *orderView;
@end